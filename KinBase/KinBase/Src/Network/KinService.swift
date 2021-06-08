//
//  KinService.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-07.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public enum TransactionOrder {
    case ascending
    case descending
}

public protocol KinServiceType {
    func mergeTokenAccounts(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<Void>
    
    func createAccount(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<KinAccount>

    func getAccount(account: PublicKey) -> Promise<KinAccount>
    
    func resolveTokenAccounts(account: PublicKey) -> Promise<[AccountDescription]>

    func streamAccount(account: PublicKey) -> Observable<KinAccount>

    func getLatestTransactions(account: PublicKey) -> Promise<[KinTransaction]>

    func getTransactionPage(account: PublicKey, pagingToken: String, order: TransactionOrder) -> Promise<[KinTransaction]>

    func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction>

    func getMinFee() -> Promise<Quark>

    func canWhitelistTransactions() -> Promise<Bool>

    func buildAndSignTransaction(ownerKey: KeyPair, sourceKey: PublicKey, nonce: Int64, paymentItems: [KinPaymentItem], memo: KinMemo, fee: Quark) -> Promise<KinTransaction>

    func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction>
    
    func buildSignAndSubmitTransaction(buildAndSignTransaction: @escaping () -> Promise<KinTransaction>) -> Promise<KinTransaction>

    func streamNewTransactions(account: PublicKey) -> Observable<KinTransaction>
    
    func invalidateRecentBlockHashCache()
    
    func invalidateTokenAccountsCache(account: PublicKey)
}

public class KinServiceV4 {
    public enum Errors: Error, Equatable {
        case unknown
        case transientFailure(error: Error)
        case invalidAccount
        case missingApi
        case insufficientBalance
        /// It is expected that this error is handled gracefully by notifying users
        /// to upgrade to a newer version of the software that should contain a more
        /// recent version of this SDK.
        case upgradeRequired
        case itemNotFound
        case insufficientFee
        case badSequenceNumber
        case webhookRejectedTransaction
        case invoiceErrorsInRequest(errors: [InvoiceError])

        public static func == (lhs: KinServiceV4.Errors, rhs: KinServiceV4.Errors) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown):
                return true
            case (.transientFailure(_), .transientFailure(_)):
                return true
            case (.invalidAccount, .invalidAccount):
                return true
            case (.missingApi, .missingApi):
                return true
            case (.insufficientBalance, .insufficientBalance):
                return true
            case (.upgradeRequired, .upgradeRequired):
                return true
            case (.itemNotFound, .itemNotFound):
                return true
            case (.insufficientFee, .insufficientFee):
                return true
            case (.badSequenceNumber, .badSequenceNumber):
                return true
            case (.webhookRejectedTransaction, .webhookRejectedTransaction):
                return true
            case (.invoiceErrorsInRequest(_), .invoiceErrorsInRequest(_)):
                return true
            default:
                return false
            }
        }
    }

    private let network: KinNetwork
    private let networkOperationHandler: NetworkOperationHandler
    private let dispatchQueue: DispatchQueue

    private let accountApi: KinAccountApiV4
    private let accountCreationApi: KinAccountCreationApiV4
    private let transactionApi: KinTransactionApiV4
    private let streamingApi: KinStreamingApiV4
    private let logger: KinLoggerFactory
    private lazy var log: KinLogger = {
        logger.getLogger(name: String(describing: self))
    }()
    private let cache = Cache<String>()
    
    private func warmCache() {
        let serviceConfigPromise: Promise<Any> = self.cache.warm(key: "serviceConfig") { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getServiceConfig(request: GetServiceConfigRequestV4()) { it in respond.onSuccess(it)}
            }
        }
        let recentBlockHashPromise: Promise<Any> = self.cache.warm(key: "recentBlockHash") { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getRecentBlockHash(request: GetRecentBlockHashRequestV4()) { it in respond.onSuccess(it) }
            }
        }
        let minRentExemptionPromise: Promise<Any> = self.cache.warm(key: "minRentExemption") { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4(size: TokenProgram.accountSize)) { it in respond.onSuccess(it) }
            }
        }
        
        all(serviceConfigPromise, recentBlockHashPromise, minRentExemptionPromise).then {_ in }
    }
    
    public func invalidateRecentBlockHashCache() {
        cache.invalidate(key: "recentBlockHash")
    }
    
    public func invalidateTokenAccountsCache(account: PublicKey) {
        cache.invalidate(key: "resolvedAccounts:\(account.base58)")
    }
    
    public init(network: KinNetwork,
                networkOperationHandler: NetworkOperationHandler,
                dispatchQueue: DispatchQueue,
                accountApi: KinAccountApiV4,
                accountCreationApi: KinAccountCreationApiV4,
                transactionApi: KinTransactionApiV4,
                streamingApi: KinStreamingApiV4,
                logger: KinLoggerFactory) {
        self.network = network
        self.networkOperationHandler = networkOperationHandler
        self.dispatchQueue = dispatchQueue
        self.accountApi = accountApi
        self.accountCreationApi = accountCreationApi
        self.transactionApi = transactionApi
        self.streamingApi = streamingApi
        self.logger = logger
    }
    
     private func requestPrint<RequestType : Any>(request: RequestType) {
           log.debug(msg:"[Request][V4]====\n\(request)\n=====[Request][V4]")
       }
       
       private func responsePrint<ResponseType : Any>(response: ResponseType) {
           log.debug(msg:"[Response][V4]====\n\(response)\n=====[Response][V4]")
       }
}

public protocol MetaServiceType {
    var configuredMinApi: Int { get }
    func getMinApiVersion() -> Promise<Int>
}

public class MetaServiceApi : MetaServiceType {
    
    public var configuredMinApi: Int
    public let opHandler : NetworkOperationHandler
    public let api: KinTransactionApiV4
    public let storage: KinStorageType
    
    public func postInit() -> Promise<Bool> {
        return storage.getMinApiVersion().then { it in
            guard let it = it else {
                return Promise { false }
            }
            if (it >= self.configuredMinApi) {
                self.configuredMinApi = it
            }
            return Promise { true }
        }
    }
    
    public func getMinApiVersion() -> Promise<Int> {
        return opHandler.queueWork { [weak self] respond in
            self?.api.getMinKinVersion(request: GetMinimumKinVersionRequestV4(), completion: { response in
                switch response.result {
                    case .ok:
                        respond.onSuccess(response.version)
                        break
                    default:
                        var error = KinServiceV4.Errors.unknown
                        if let transientError = response.error {
                            error = KinServiceV4.Errors.transientFailure(error: transientError)
                        }
                        respond.onError?(error)
                    }
                })
        }.then { it in self.storage.setMinApiVersion(apiVersion: it) }
            .recover {_ in Promise { self.configuredMinApi } }
            .then { it in
                self.configuredMinApi = it
            }
    }
    
    init(configuredMinApi: Int, opHandler: NetworkOperationHandler, api: KinTransactionApiV4, storage: KinStorageType) {
        self.configuredMinApi = configuredMinApi
        self.opHandler = opHandler
        self.api = api
        self.storage = storage
    }
}

extension KinServiceV4 : KinServiceType {
    
    private func cachedServiceConfig() -> Promise<GetServiceConfigResponseV4>{
        return self.cache.resolve(key: "serviceConfig", timeoutOverride: 1000*60*20 /* 30 Minutes */) { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getServiceConfig(request: GetServiceConfigRequestV4()) { it in respond.onSuccess(it)}
            }
        }
    }
    
    private func cachedRecentBlockHash() -> Promise<GetRecentBlockHashResonseV4> {
        return self.cache.resolve(key: "recentBlockHash", timeoutOverride: 1000*60*2 /* 2 Minutes */) { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getRecentBlockHash(request: GetRecentBlockHashRequestV4()) { it in respond.onSuccess(it) }
            }
        }
    }
    
    private func cachedMinRentExemption() -> Promise<GetMinimumBalanceForRentExemptionResponseV4> {
        return self.cache.resolve(key: "minRentExemption", timeoutOverride: 1000*60*20 /* 30 Minutes */) { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                self?.transactionApi.getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4(size: TokenProgram.accountSize)) { it in respond.onSuccess(it) }
            }
        }
    }
    
    public func mergeTokenAccounts(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<Void> {
        networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }
            
            self.resolveTokenAccounts(account: account).then { tokenAccounts in
                guard !tokenAccounts.isEmpty else {
                    respond.onError?(Errors.itemNotFound)
                    return
                }
                
                all(self.cachedServiceConfig(), self.cachedRecentBlockHash()).then { serviceConfig, recentBlockHash in
                    
                    let subsidizer = serviceConfig.subsidizerAccount!
                    let owner = signer.publicKey
                    let programKey = serviceConfig.tokenProgram!
                    let mint = serviceConfig.token!
                    
                    var instructions: [Instruction] = []
                    var rootTokenAccount = tokenAccounts.first?.publicKey
                    
                    let (createInstruction, associatedAccountAddress) = AssociatedTokenProgram.createAssociatedAccountInstruction(
                        subsidizer: subsidizer,
                        owner: owner,
                        mint: mint
                    )
                    
                    let shouldCreateAssociatedAccount = tokenAccounts.firstIndex { $0.publicKey == associatedAccountAddress } == nil
                    if shouldCreateAssociatedAccount {
                        
                        // Create associated account instructions
                        instructions.append(contentsOf: [
                            createInstruction,
                            TokenProgram.setAuthority(
                                account: associatedAccountAddress,
                                currentAuthority: owner,
                                newAuthority: subsidizer,
                                authorityType: .authorityCloseAccount,
                                programKey: programKey
                            ),
                        ])
                        
                        // Add memo if app index is provided
                        if let appIndex = appIndex {
                            let memo = try! KinBinaryMemo(typeId: KinBinaryMemo.TransferType.none.rawValue, appIdx: appIndex.value)
                            instructions.append(
                                MemoProgram.memoInsutruction(with: memo.encode().base64EncodedData())
                            )
                        }
                        
                        rootTokenAccount = associatedAccountAddress
                    }
                    
                    let accountsToClose = tokenAccounts.filter { $0.publicKey != rootTokenAccount }
                    
                    // Add instructions to transfer balances of all token
                    // accounts to the root account.
                    
                    let transferInstructions: [Instruction] = accountsToClose.compactMap { tokenAccount in
                        guard let balance = tokenAccount.balance, let destination = rootTokenAccount else {
                            return nil
                        }
                        
                        return TokenProgram.transferInstruction(
                            source: tokenAccount.publicKey,
                            destination: destination,
                            owner: owner,
                            amount: balance,
                            programKey: .tokenProgram
                        )
                    }
                    
                    instructions.append(contentsOf: transferInstructions)
                    
                    // For accounts where the `closeAuthority` is either the
                    // the owner account or the subsidizer, we want to provide
                    // close instructions.
                    
                    let closeInstructions: [Instruction] = accountsToClose.compactMap { tokenAccount in
                        guard let closeAuthority = tokenAccount.closeAuthority, closeAuthority == account || closeAuthority == subsidizer else {
                            return nil
                        }
                        
                        return TokenProgram.closeAccount(
                            account: tokenAccount.publicKey,
                            destination: closeAuthority,
                            owner: closeAuthority
                        )
                    }
                    
                    instructions.append(contentsOf: closeInstructions)
                    
                    if instructions.isEmpty {
                        respond.onSuccess(())
                    } else {
                        let transaction = try! Transaction(payer: subsidizer, instructions: instructions)
                            .updatingBlockhash(recentBlockHash.blockHash!)
                            .signing(using: signer)
                        
                        let kinTransaction = try! KinTransaction(
                            envelopeXdrBytes: transaction.encode().bytes,
                            record: .inFlight(ts: Date().timeIntervalSince1970),
                            network: self.network
                        )
                        
                        self.submitTransaction(transaction: kinTransaction).then { _ in
                            self.invalidateTokenAccountsCache(account: account)
                            respond.onSuccess(())
                        }
                    }
                }
                .catch {
                    respond.onError?($0)
                }
            }
        }
    }
    
    public func createAccount(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<KinAccount> {
        networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }
            
            all(self.cachedServiceConfig(), self.cachedRecentBlockHash()).then { serviceConfig, recentBlockHash in
                guard
                    serviceConfig.result == GetServiceConfigResponseV4.Result.ok ||
                    recentBlockHash.result == GetRecentBlockHashResonseV4.Result.ok
                else {
                    respond.onError?(Errors.unknown)
                    return
                }
                
                let subsidizer = serviceConfig.subsidizerAccount!
                let owner = signer.publicKey
                let programKey = serviceConfig.tokenProgram!
                let mint = serviceConfig.token!
                
                let (createInstruction, associatedAccountAddress) = AssociatedTokenProgram.createAssociatedAccountInstruction(
                    subsidizer: subsidizer,
                    owner: owner,
                    mint: mint
                )
                
                var instructions: [Instruction] = [
                    createInstruction,
                    TokenProgram.setAuthority(
                        account: associatedAccountAddress,
                        currentAuthority: owner,
                        newAuthority: subsidizer,
                        authorityType: .authorityCloseAccount,
                        programKey: programKey
                    ),
                ]
                
                // Add memo if app index is provided
                if let appIndex = appIndex {
                    let memo = try! KinBinaryMemo(typeId: KinBinaryMemo.TransferType.none.rawValue, appIdx: appIndex.value)
                    instructions.append(
                        MemoProgram.memoInsutruction(with: memo.encode().base64EncodedData())
                    )
                }
                
                let transaction = try! Transaction(
                    payer: subsidizer,
                    instructions: instructions
                )
                .updatingBlockhash(recentBlockHash.blockHash!)
                .signing(using: signer)
                
                let request = CreateAccountRequestV4(transaction: transaction)
                self.requestPrint(request: request)
                self.accountCreationApi.createAccount(request: request) { [weak self] response in
                    self?.responsePrint(response:response)
                    switch response.result {
                    case .ok:
                        if let account = response.account {
                            respond.onSuccess(account)
                            break
                        }
                        fallthrough
                    default:
                        var error = Errors.unknown
                        if let transientError = response.error {
                            error = Errors.transientFailure(error: transientError)
                        }
                        respond.onError?(error)
                    }
                }
            }
            .catch {
                respond.onError?($0)
            }
        }
    }
    
    public func getAccount(account: PublicKey) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetAccountRequestV4(account: account)
            self.requestPrint(request: request)
            self.accountApi.getAccount(request: request) { [weak self] response in
                self?.responsePrint(response:response)
                switch response.result {
                case .ok:
                    if let account = response.account {
                        respond.onSuccess(account)
                        break
                    }
                    fallthrough
                case .notFound:
                    respond.onError?(Errors.itemNotFound)
                case .transientFailure:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                case .undefinedError:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
    
    public func resolveTokenAccounts(account: PublicKey) -> Promise<[AccountDescription]> {
        let cacheKey = "resolvedAccounts:\(account.base58)"
        let resolve: Promise<[AccountDescription]> = cache.resolve(key: cacheKey) { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                guard let self = self else {
                    respond.onError?(Errors.unknown)
                    return
                }
                
                let request = ResolveTokenAccountsRequestV4(account: account)
                self.requestPrint(request: request)
                self.accountApi.resolveTokenAccounts(request: request) { [weak self] response in
                    self?.responsePrint(response:response)
                    switch response.result {
                    case .ok:
                        let accounts = response.accounts?.compactMap { $0 } ?? []
                        respond.onSuccess(accounts)
                    case .notFound:
                        respond.onError?(Errors.itemNotFound)
                    case .transientFailure:
                        var error = Errors.unknown
                        if let transientError = response.error {
                            error = Errors.transientFailure(error: transientError)
                        }
                        respond.onError?(error)
                    case .upgradeRequired:
                        respond.onError?(Errors.upgradeRequired)
                    case .undefinedError:
                        respond.onError?(Errors.unknown)
                    }
                }
            }
        }
        
        return resolve.then { accounts -> Promise<[AccountDescription]> in
            if accounts.isEmpty {
                self.cache.invalidate(key: cacheKey)
                return resolve
            } else {
                return Promise { accounts }
            }
        }
    }
    
    public func streamAccount(account: PublicKey) -> Observable<KinAccount> {
        return streamingApi.streamAccountV4(account).subscribe { [weak self] kinAccount in
            self?.log.debug(msg:"streamAccount::Update \(kinAccount)")
        }
    }
    
    public func getLatestTransactions(account: PublicKey) -> Promise<[KinTransaction]> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetTransactionHistoryRequestV4(account: account, cursor: nil, order: .descending)
            self.requestPrint(request: request)
            self.transactionApi.getTransactionHistory(request: request) { [weak self] response in
                self?.responsePrint(response:response)
                switch response.result {
                case .ok:
                    if let transactions = response.kinTransactions {
                        respond.onSuccess(transactions)
                        break
                    }
                    fallthrough
                case .notFound:
                    respond.onError?(Errors.itemNotFound)
                case .transientFailure:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                case .undefinedError:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
    
    public func getTransactionPage(account: PublicKey, pagingToken: String, order: TransactionOrder) -> Promise<[KinTransaction]> {
         return networkOperationHandler.queueWork { [weak self] respond in
                   guard let self = self else {
                       respond.onError?(Errors.unknown)
                       return
                   }

                   let request = GetTransactionHistoryRequestV4(account: account, cursor: pagingToken, order: order)
                   self.requestPrint(request: request)
                   self.transactionApi.getTransactionHistory(request: request) { [weak self] response in
                       self?.responsePrint(response:response)
                       switch response.result {
                       case .ok:
                           if let transactions = response.kinTransactions {
                               respond.onSuccess(transactions)
                               break
                           }
                           fallthrough
                       case .notFound:
                           respond.onError?(Errors.itemNotFound)
                       case .transientFailure:
                           var error = Errors.unknown
                           if let transientError = response.error {
                               error = Errors.transientFailure(error: transientError)
                           }
                           respond.onError?(error)
                       case .upgradeRequired:
                           respond.onError?(Errors.upgradeRequired)
                       case .undefinedError:
                           respond.onError?(Errors.unknown)
                       }
                   }
               }
    }
    
    public func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetTransactionRequestV4(transactionHash: transactionHash)
            self.requestPrint(request: request)
            self.transactionApi.getTransaction(request: request) { [weak self] response in
                self?.responsePrint(response:response)
                switch response.result {
                case .ok:
                    if let transaction = response.kinTransaction {
                        respond.onSuccess(transaction)
                        break
                    }
                    fallthrough
                case .notFound:
                    respond.onError?(Errors.itemNotFound)
                case .transientFailure:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                case .undefinedError:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
    
    public func getMinFee() -> Promise<Quark> {
        return Promise.init(Quark(0))
    }
    
    public func canWhitelistTransactions() -> Promise<Bool> {
        return Promise.init(true)
    }
    
    public func buildAndSignTransaction(ownerKey: KeyPair, sourceKey: PublicKey, nonce: Int64, paymentItems: [KinPaymentItem], memo: KinMemo, fee: Quark) -> Promise<KinTransaction> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            all(self.cachedServiceConfig(), self.cachedRecentBlockHash(), Promise.init({})).then { (serviceConfig, recentBlockHash, empty) in
                guard (serviceConfig.result == GetServiceConfigResponseV4.Result.ok
                        || recentBlockHash.result == GetRecentBlockHashResonseV4.Result.ok
                ) else {
                    respond.onError?(Errors.unknown)
                    return
                }
                
                let signer = ownerKey
                let subsidizer: PublicKey = serviceConfig.subsidizerAccount!
                let programKey = serviceConfig.tokenProgram!
                self.log.debug(msg: "ownerKey: \(ownerKey)")
                self.log.debug(msg: "sourceKey: \(sourceKey)")
                self.log.debug(msg: "paymentItems: \(paymentItems)")
                
                var instructions: [Instruction] = []
                
                if memo != .none {
                    switch memo.type {
                    case .bytes:
                        if memo.agoraMemo != nil {
                            instructions.append(
                                MemoProgram.memoInsutruction(with: memo.agoraMemo!.encode().base64EncodedData())
                            )
                        }
                        
                    case .text:
                        instructions.append(
                            MemoProgram.memoInsutruction(with: memo.bytes.data)
                        )
                    }
                }
                
                instructions.append(contentsOf: paymentItems.map { paymentItem in
                    TokenProgram.transferInstruction(
                        source: sourceKey,
                        destination: paymentItem.destAccount,
                        owner: ownerKey.publicKey,
                        amount: paymentItem.amount,
                        programKey: programKey
                    )
                })
                
                let transaction = try! Transaction(
                    payer: subsidizer,
                    instructions: instructions
                )
                .updatingBlockhash(recentBlockHash.blockHash!)
                .signing(using: signer)
                
                print(transaction)
                
                let kinTransaction = try! KinTransaction(
                    envelopeXdrBytes: transaction.encode().bytes,
                    record: .inFlight(ts: Date().timeIntervalSince1970),
                    network: self.network
                )
                
                respond.onSuccess(kinTransaction)
            }.catch { it in respond.onError?(it) }
        }
    }
    
    public func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = SubmitTransactionRequestV4(
                transaction: Transaction(data: Data(transaction.envelopeXdrBytes))!,
                invoiceList: transaction.invoiceList
            )
            self.requestPrint(request: request)
            self.transactionApi.submitTransaction(request: request) { [weak self] response in
                self?.responsePrint(response:response)
                switch response.result {
                case .ok:
                    if let transaction = response.kinTransaction {
                        respond.onSuccess(transaction)
                        break
                    }
                    fallthrough
                case .insufficientBalance:
                    respond.onError?(Errors.insufficientBalance)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                case .badSequenceNumber:
                    respond.onError?(Errors.badSequenceNumber)
                case .insufficientFee:
                    respond.onError?(Errors.insufficientFee)
                case .noAccount:
                    respond.onError?(Errors.invalidAccount)
                case .webhookRejected:
                    respond.onError?(Errors.webhookRejectedTransaction)
                case .invoiceError:
                    guard let error = response.error as? AgoraKinTransactionsApi.Errors,
                        case let .invoiceErrors(invoiceErrors) = error else {
                        fallthrough
                    }

                    respond.onError?(Errors.invoiceErrorsInRequest(errors: invoiceErrors))
                default:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                }
            }
        }
    }
    
    public func buildSignAndSubmitTransaction(buildAndSignTransaction: @escaping () -> Promise<KinTransaction>) -> Promise<KinTransaction> {
        buildAndSignTransaction().then { it in self.submitTransaction(transaction: it) }
    }
    
    public func streamNewTransactions(account: PublicKey) -> Observable<KinTransaction> {
        return streamingApi.streamNewTransactionsV4(account: account).subscribe { [weak self] (transaction) in
            self?.log.debug(msg:"streamNewTransactions::Update \(transaction)")
        }
    }
}
