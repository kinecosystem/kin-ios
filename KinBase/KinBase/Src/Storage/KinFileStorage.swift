//
//  KinFileStorage.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-07.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public class KinFileStorage  {
    public enum Errors: Error {
        case unknown
        case malformattedInput
        case missingAccount
        case unregisteredAccount
    }

    private struct Constants {
        static let accountInfoFileName = "account_info"
        static let transactionsFileName = "transactions"
        static let invoicesFileName = "invoices"
        static let minFeeUserDefaultsKey = "KinBase.MinFee"
        static let cidUserDefaultsKey = "KinBase.CID"
        static let minApiVersionUserDefaultsKey = "KinBase.minApiVersion"
    }

    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    private let rootDirectory: URL
    private let keyStore: SecureKeyStorage = KeyChainStorage()
    private let network: KinNetwork
    private let fileAccessQueue: DispatchQueue = DispatchQueue(label: "KinBase.KinFileStorage")

    /// - Parameters:
    ///   - directory: the directory where the storage locates, use document directory if icloud backup is desired
    ///   - network: the Kin network envrionment of the contents in this storage instance
    public init(directory: URL = URL(fileURLWithPath: NSTemporaryDirectory()),
                network: KinNetwork) {
        self.rootDirectory = directory
        self.network = network
    }
}

// MARK: Public - KinStorageType
extension KinFileStorage: KinStorageType {

    // MARK: Account Operations
    public func addAccount(_ account: KinAccount) throws -> KinAccount {
        try addKeyToSecureStore(publicKey: account.publicKey, privateKey: account.privateKey)
        try writeAccountInfo(account)
        return account
    }

    public func addAccount(_ account: KinAccount) -> Promise<KinAccount> {
        let promise = addKeyToSecureStoreAsync(publicKey: account.publicKey, privateKey: account.privateKey)
        return promise.then(on: fileAccessQueue) { [weak self] _ -> Promise<KinAccount> in
            guard let self = self else {
                return .init(Errors.unknown)
            }

            return self.writeAccountInfoAsync(account)
        }
    }
    
    public func hasPrivateKey(_ account: PublicKey) -> Bool {
        getKeyFromSecureStore(account: account) != nil
    }

    public func getAccount(_ account: PublicKey) -> Promise<KinAccount?> {
        guard let privateKey = getKeyFromSecureStore(account: account) else {
            return Promise { false }
        }
        
        let localAccount = readAccountInfoSync(account)
        return self.merge(privateKey: privateKey, publicKey: account, with: localAccount)
    }

    public func updateAccount(_ account: KinAccount) -> Promise<KinAccount> {
        return getAccount(account.publicKey)
            .then(on: fileAccessQueue) { [weak self] storedAccount -> Promise<KinAccount> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                guard let storedAccount = storedAccount else {
                    return self.addAccount(account)
                }

//                let key = storedAccount.key.privateKey != nil ? storedAccount.key : account.key
                let updatedAccount = storedAccount.copy(balance: account.balance,
                                                        status: account.status,
                                                        sequence: account.sequence,
                                                        tokenAccounts: account.tokenAccounts)
                return self.addAccount(updatedAccount)
            }
    }

    public func removeAccount(account: PublicKey) -> Promise<Void> {
        let promise = removeKeyFromSecureStore(account: account)
        return promise.then { [weak self] _ -> Promise<Void> in
            guard let self = self else {
                return .init(Errors.unknown)
            }

            let accountDirectory = self.directoryForAccount(account)
            return self.removeFileOrDirectory(accountDirectory)
        }
    }

    public func advanceSequence(account: PublicKey) -> Promise<KinAccount> {
        return getAccount(account)
            .then(on: fileAccessQueue) { account -> Promise<KinAccount> in
                guard let account = account else {
                    return .init(Errors.missingAccount)
                }

                guard let sequence = account.sequence,
                    account.status == .registered
                    else {
                        return .init(Errors.unregisteredAccount)
                }

                let updatedAccount = account.copy(sequence: sequence + 1)

                return self.updateAccount(updatedAccount)
            }
    }

    public func deductFromAccountBalance(account: PublicKey, amount: Kin) -> Promise<KinAccount> {
        return getAccount(account)
            .then(on: fileAccessQueue) { account -> Promise<KinAccount> in
                guard let account = account else {
                    return .init(Errors.missingAccount)
                }

                guard account.status == .registered else {
                    return .init(Errors.unregisteredAccount)
                }

                let deductedBalance = KinBalance(max(0, account.balance.amount - amount))
                let updatedAccount = account.copy(balance: deductedBalance)

                return self.updateAccount(updatedAccount)
        }
    }

    public func getAllAccountIds() -> Promise<[PublicKey]> {
        guard let contents = try? fileManager.contentsOfDirectory(at: directoryForAllAccounts, includingPropertiesForKeys: nil) else {
            return Promise([])
        }

        let promises = contents
            .map { $0.appendingPathComponent(Constants.accountInfoFileName) }
            .map { readAccountInfo($0) }

        return any(promises).then { accountsOrError in
            let accountIds = accountsOrError.compactMap { $0.value??.publicKey }
            return Promise(accountIds)
        }
    }

    // MARK: Transaction Operations
    public func storeTransactions(account: PublicKey, transactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        var headPagingToken: PagingToken?
        for item in transactions {
            if item.record.recordType == .historical {
                headPagingToken = item.record.pagingToken
                break
            }
        }

        var tailPagingToken: PagingToken?
        for item in transactions.reversed() {
            if item.record.recordType == .historical {
                tailPagingToken = item.record.pagingToken
                break
            }
        }

        let invoiceLists = transactions.compactMap { $0.invoiceList }

        let kinTransactions = KinTransactions(
            items: transactions,
            headPagingToken: headPagingToken,
            tailPagingToken: tailPagingToken
        )

        return addInvoiceLists(account: account, invoiceLists: invoiceLists)
            .then { _ in
                self.writeTransactions(account: account, transactions: kinTransactions)
            }
    }

    public func getStoredTransactions(account: PublicKey) -> Promise<KinTransactions?> {
        var invoiceListsMap = [InvoiceList.Id: InvoiceList]()
        return getInvoiceListsMapForAccountId(account: account)
            .then { storedMap -> Promise<KinTransactions?> in
                invoiceListsMap = storedMap
                return self.readTransactions(account: account)
            }
            .then { kinTransactions -> KinTransactions? in
                guard let kinTransactions = kinTransactions else {
                    return nil
                }

                // Attach invoices to retrieved transactions
                let itemsWithInvoice = kinTransactions.items.map { item -> KinTransaction in
                    guard let agoraMemo = item.memo.agoraMemo else {
                        return item
                    }

                    let invoiceListId = agoraMemo.foreignKeySHA224

                    guard let transaction = try? KinTransaction(
                        envelopeXdrBytes: item.envelopeXdrBytes,
                        record: item.record,
                        network: item.network,
                        invoiceList: invoiceListsMap[invoiceListId]
                    ) else {
                        return item
                    }

                    return transaction
                }

                let transactionsWithInvoice = KinTransactions(
                    items: itemsWithInvoice,
                    headPagingToken: kinTransactions.headPagingToken,
                    tailPagingToken: kinTransactions.tailPagingToken
                )

                return transactionsWithInvoice
            }
    }

    public func insertNewTransaction(account: PublicKey, newTransaction: KinTransaction) -> Promise<[KinTransaction]> {
        return getStoredTransactions(account: account)
            .then(on: fileAccessQueue) { transactions -> [KinTransaction] in
                return (transactions?.items ?? []) + [newTransaction]
            }
            .then(on: fileAccessQueue) { transactionsToStore in
                self.storeTransactions(account: account, transactions: transactionsToStore)
            }
    }

    public func upsertNewTransactions(account: PublicKey, newTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return getStoredTransactions(account: account)
            .then { transactions -> [KinTransaction] in
                var storedTransactions = transactions?.items ?? []
                storedTransactions = storedTransactions.filter { stored -> Bool in
                    return !newTransactions.contains { new -> Bool in
                        return new.transactionHash == stored.transactionHash
                    }
                }

                return newTransactions + storedTransactions
            }
            .then {
                self.storeTransactions(account: account, transactions: $0)
            }
    }

    public func upsertOldTransactions(account: PublicKey, oldTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return getStoredTransactions(account: account)
        .then { transactions -> [KinTransaction] in
            var storedTransactions = transactions?.items ?? []
            storedTransactions = storedTransactions.filter { stored -> Bool in
                return !oldTransactions.contains { new -> Bool in
                    return new.transactionHash == stored.transactionHash
                }
            }

            return storedTransactions + oldTransactions
        }
        .then {
            self.storeTransactions(account: account, transactions: $0)
        }
    }

    public func addInvoiceLists(account: PublicKey, invoiceLists: [InvoiceList]) -> Promise<[InvoiceList]> {
        guard !invoiceLists.isEmpty else {
            return .init([])
        }

        return getInvoiceListsMapForAccountId(account: account)
            .then { (invoicesMap: [InvoiceList.Id : InvoiceList]) -> [InvoiceList.Id : InvoiceList] in
                var updatedMap = invoicesMap

                invoiceLists.forEach { invoiceList in
                    updatedMap[invoiceList.id] = invoiceList
                }

                return updatedMap
            }
            .then { _ = self.writeInvoices(account: account, invoices: $0) }
            .then { invoiceLists }
    }

    public func getInvoiceListsMapForAccountId(account: PublicKey) -> Promise<[InvoiceList.Id : InvoiceList]> {
        return readInvoices(account: account).then { $0 ?? [:] }
    }

    public func setMinFee(_ fee: Quark) {
        userDefaults.set(fee, forKey: Constants.minFeeUserDefaultsKey)
    }

    public func getMinFee() -> Quark? {
        return userDefaults.value(forKey: Constants.minFeeUserDefaultsKey) as? Quark
    }
    
    public func getOrCreateCID() -> String {
        let exisingCID = userDefaults.value(forKey: Constants.cidUserDefaultsKey) as? String
        if (exisingCID != nil) {
            return exisingCID!
        } else {
            let newCid = UUID().uuidString
            userDefaults.set(newCid, forKey: Constants.cidUserDefaultsKey)
            return newCid
        }
    }
    
    public func setMinApiVersion(apiVersion: Int) -> Promise<Int> {
        return Promise { [weak self] fulfill, reject in
            self?.userDefaults.set(apiVersion, forKey: Constants.minApiVersionUserDefaultsKey)
           fulfill(apiVersion)
        }
    }

    public func getMinApiVersion() -> Promise<Int?> {
        return Promise { [weak self] fulfill, reject in
            let minApiVer = self?.userDefaults.integer(forKey: Constants.minApiVersionUserDefaultsKey)
            fulfill(minApiVer)
        }
    }

    public func clearStorage() -> Promise<Void> {
        userDefaults.removeObject(forKey: Constants.minFeeUserDefaultsKey)
        userDefaults.removeObject(forKey: Constants.minApiVersionUserDefaultsKey)
        userDefaults.removeObject(forKey: Constants.cidUserDefaultsKey)
        return removeFileOrDirectory(kinStorageDirectory)
    }
}

// MARK: Private - File Location
private extension KinFileStorage {
    var kinStorageDirectory: URL {
        return rootDirectory.appendingPathComponent("kin_storage", isDirectory: true)
    }

    var directoryForAllAccounts: URL {
        return kinStorageDirectory.appendingPathComponent("kin_accounts", isDirectory: true)
    }

    func directoryForAccount(_ account: PublicKey) -> URL {
        return directoryForAllAccounts.appendingPathComponent(account.stellarID, isDirectory: true)
    }

    func pathForAccountInfoFile(_ account: PublicKey) -> URL {
        return directoryForAccount(account).appendingPathComponent(Constants.accountInfoFileName)
    }

    func pathForTransactionsFile(for account: PublicKey) -> URL {
        return directoryForAccount(account).appendingPathComponent(Constants.transactionsFileName)
    }

    func pathForInvoicesFile(for account: PublicKey) -> URL {
        return directoryForAccount(account).appendingPathComponent(Constants.invoicesFileName)
    }
}

// MARK: Private - Account Operations
private extension KinFileStorage {
    func writeAccountInfo(_ account: KinAccount) throws {
        guard let data = account.storableObject.data() else {
            throw Errors.malformattedInput
        }

        // Make sure directory exists
        let accountDirectory = directoryForAccount(account.publicKey)
        try fileManager.createDirectory(at: accountDirectory,
                                        withIntermediateDirectories: true)

        let accountInfoFile = pathForAccountInfoFile(account.publicKey)

        try data.write(to: accountInfoFile,
                       options: .atomic)
    }

    func writeAccountInfoAsync(_ account: KinAccount) -> Promise<KinAccount> {
        return Promise<KinAccount>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            do {
                try self.writeAccountInfo(account)
                fulfill(account)
            } catch let error {
                reject(error)
            }
        }
    }

    func merge(privateKey: PrivateKey?, publicKey: PublicKey, with account: KinAccount?) -> Promise<KinAccount?> {
        return Promise<KinAccount?>.init(on: fileAccessQueue) { fulfill, reject in
            // If private key is stored, merge with account info, otherwise return an account without private key
            guard let account = account else {
                let unregistedAccount = KinAccount(publicKey: publicKey, privateKey: privateKey)
                fulfill(unregistedAccount)
                return
            }

            if let privateKey = privateKey {
                let mergedAccount = KinAccount(
                    publicKey: account.publicKey,
                    privateKey: privateKey,
                    balance: account.balance,
                    status: account.status,
                    sequence: account.sequence,
                    tokenAccounts: account.tokenAccounts
                )
                fulfill(mergedAccount)
                return
            }

            fulfill(account)
        }
    }

    func readAccountInfo(_ account: PublicKey) -> Promise<KinAccount?> {
        let accountInfoFile = self.pathForAccountInfoFile(account)
        return readAccountInfo(accountInfoFile)
    }

    func readAccountInfo(_ filePath: URL) -> Promise<KinAccount?> {
        return Promise<KinAccount?>.init(on: fileAccessQueue) { fulfill, reject in
            do {
                guard let data = try? Data(contentsOf: filePath) else {
                    fulfill(nil)
                    return
                }

                let storageObject = try KinStorageKinAccount(data: data)
                let kinAccount = storageObject.kinAccount
                fulfill(kinAccount)

            } catch let error {
                reject(error)
            }
        }
    }

    func readAccountInfoSync(_ account: PublicKey) -> KinAccount? {
        let accountInfoFile = pathForAccountInfoFile(account)
        return readAccountInfoSync(accountInfoFile)
    }

    func readAccountInfoSync(_ filePath: URL) -> KinAccount? {
        guard let data = try? Data(contentsOf: filePath) else {
            return nil
        }

        let storageObject = try? KinStorageKinAccount(data: data)
        return storageObject?.kinAccount
    }

    func writeTransactions(account: PublicKey, transactions: KinTransactions) -> Promise<[KinTransaction]> {
        return Promise<[KinTransaction]>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            guard let data = transactions.storableObject.data() else {
                reject(Errors.malformattedInput)
                return
            }

            do {
                // Make sure directory exists
                let accountDirectory = self.directoryForAccount(account)
                try self.fileManager.createDirectory(at: accountDirectory, withIntermediateDirectories: true)

                let transactionsFile = self.pathForTransactionsFile(for: account)

                try data.write(to: transactionsFile, options: .atomic)
                fulfill(transactions.items)
            } catch let error {
                reject(error)
            }
        }
    }

    func readTransactions(account: PublicKey) -> Promise<KinTransactions?> {
        return Promise<KinTransactions?>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            let transactionsFile = self.pathForTransactionsFile(for: account)

            guard let data = try? Data(contentsOf: transactionsFile) else {
                fulfill(nil)
                return
            }

            let storageObject = try KinStorageKinTransactions(data: data)
            let kinTransactions = storageObject.kinTransactions(network: self.network)
            fulfill(kinTransactions)
        }
    }

    func readInvoices(account: PublicKey) -> Promise<[InvoiceList.Id : InvoiceList]?> {
        return Promise<[InvoiceList.Id : InvoiceList]?>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            let invoicesFile = self.pathForInvoicesFile(for: account)

            guard let data = try? Data(contentsOf: invoicesFile) else {
                fulfill(nil)
                return
            }

            let storageObject = try KinStorageInvoices(data: data)
            fulfill(storageObject.invoicesMap)
        }
    }

    func writeInvoices(account: PublicKey, invoices: [InvoiceList.Id : InvoiceList]) -> Promise<[InvoiceList.Id : InvoiceList]> {
        return Promise<[InvoiceList.Id : InvoiceList]>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            guard let data = invoices.storableObject.data() else {
                reject(Errors.malformattedInput)
                return
            }

            // Make sure directory exists
            let accountDirectory = self.directoryForAccount(account)
            try self.fileManager.createDirectory(at: accountDirectory, withIntermediateDirectories: true)

            let invoicesFile = self.pathForInvoicesFile(for: account)

            try data.write(to: invoicesFile, options: .atomic)

            fulfill(invoices)
        }
    }

    func removeFileOrDirectory(_ url: URL) -> Promise<Void> {
        return Promise<Void>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            do {
                if self.fileManager.fileExists(atPath: url.path) {
                    try self.fileManager.removeItem(at: url)
                }

                fulfill(())
            } catch let error {
                reject(error)
            }
        }
    }
}

// MARK: Private - Key Store Access
private extension KinFileStorage {
    func addKeyToSecureStore(publicKey: PublicKey, privateKey: PrivateKey?) throws {
        guard let privateKey = privateKey else {
            return
        }
        try keyStore.add(account: publicKey.stellarID, key: privateKey.data)
    }

    func addKeyToSecureStoreAsync(publicKey: PublicKey, privateKey: PrivateKey?) -> Promise<Void> {
        return Promise<Void>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            do {
                try self.addKeyToSecureStore(publicKey: publicKey, privateKey: privateKey)
                fulfill(())
            } catch let error {
                reject(error)
            }
        }
    }

    func getKeyFromSecureStore(account: PublicKey) -> PrivateKey? {
        guard let secretData = keyStore.retrieve(account: account.stellarID) else {
            return nil
        }

        if let privateKey = PrivateKey(secretData) {
            return privateKey
        } else {
            if let secretSeed = String(data: secretData, encoding: .utf8), let seed = Seed(stellarID: secretSeed) {
                return KeyPair(seed: seed).privateKey
            }
        }
        
        return nil
    }

    func removeKeyFromSecureStore(account: PublicKey) -> Promise<Void> {
        return Promise<Void>.init(on: fileAccessQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            do {
                try self.keyStore.delete(account: account.stellarID)
                fulfill(())
            } catch let error {
                reject(error)
            }
        }
    }
}


