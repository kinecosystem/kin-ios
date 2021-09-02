//
//  KinAccountContext.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-07.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

/// Describes the mode by which updates are presented to an `Observer`
public enum ObservationMode {
    /// Updates are only based on local actions or via calling `Observer.requestInvalidation`
    /// A current value will always be emitted (which may fault to network) followed by only values as a result of local actions.
    case passive

    /// Updates are pushed from the network. Includes all `.passive` updates.
    /// - Note: Active updates require a persistent network connection to stream data from a remote service.
    case active

    /// Exclusively new updates from actions taken after starting to listen to this `Observer`.
    /// No current value will be emitted.
    case activeNewOnly
}

public enum AccountSpec {
    case preferred
    case exact
}

public protocol KinAccountReadOperations {
    /**
     Returns the account info
     - Parameter forceUpdate: set to `true` to force an update from network
     - Returns: a `Promise` containing the `KinAccount` or an error
    */
    func getAccount(forceUpdate: Bool) -> Promise<KinAccount>

    /**
     Returns the current balance and listens to future account balance changes.

     `ObservationMode.passive` - will return the current balance and any balance updates as a result of actions performed locally.

     `ObservationMode.active` - will return the current balance and any balance updates.

     `ObservationMode.ActiveNewOnly` - will *not* return the current balance, but only new updates from now onwards.

     - Note: Running with `ObservationMode.passive` is suggested unless higher data freshness is required.
     - Parameter mode: will change the frequency of updates according to the rules set in `ObservationMode`
     - Returns: a `Observable` with `KinBalance` updates or error
    */
    func observeBalance(mode: ObservationMode) -> Observable<KinBalance>

    /**
     Deletes the storage associated with the `accountId`
     - Returns: a `Promise` which resolves when the operation completes
    */
    func clearStorage() -> Promise<Void>
}

public protocol KinPaymentReadOperations {
    /**
     Retrieves the last N `KinPayment`s sent or received by the account and listens for future payments over time.

     `ObservationMode.passive` - will return the full recorded history and new `KinTransaction`s as a result of actions performed locally.

     `ObservationMode.active` - will return the full recorded history and all new `KinTransaction`s.

     `ObservationMode.activeNewOnly` - will *not* return the recorded history, but only new updates from now onwards.

     - Note: Running with `ObservationMode.passive` is suggested unless higher data freshness is required.
     - Parameter mode: will change the frequency of updates according to the rules set in `ObservationMode`.
     - Returns: a `ListObserver` to listen to the payment history.
    */
    func observePayments(mode: ObservationMode) -> ListObservable<KinPayment>

    /**
     Retrieves the `KinPayment`s that were processed in the referred `KinTransaction`
     - Parameter transactionHash: is the referencing hash for a `KinTransaction` that contain a list of the given `KinPayment`s.
     - Returns: a `Promise` containing the list of `KinPayment`s in the referencing `KinTransaction` or an error
    */
    func getPaymentsForTransactionHash(_ transactionHash: KinTransactionHash) -> Promise<[KinPayment]>
}

public protocol KinPaymentWriteOperations {
    
    /**
     Merge existing Kin token accounts into the associated token account. The associated token is created if it doesn't exist.
     - Parameter account: The owner account which own the token accounts to merge
     - Parameter appIndex: App index of your app
     - Returns: a `Promise` with a `Void` return value
    */
    func mergeTokenAccounts(for account: KinAccount, appIndex: AppIndex?) -> Promise<Void>
    
    /**
     Send a `paymentItem` to the Kin Blockchain for processing.
     - Parameter paymentItem: a `KinPaymentItem` which contains the amount of Kin to be sent and the account the Kin is to be transferred to
     - Parameter memo: a memo can be provided to reference what the payment was for., if no memo is desired, then set it to `KinMemo.none`
     - Returns: a `Promise` with the blockchain confirmed `KinPayment`
    */
    func sendKinPayment(_ paymentItem: KinPaymentItem, memo: KinMemo) -> Promise<KinPayment>

    /**
     Sends a batch of payments, each corresponding to `KinPaymentItem` in a single `KinTransaction` to be processed together.
     - Note: If any one payment's data is invalid, all payments will fail.
     - Parameter payments: array of `KinPaymentItem`s to be sent
     - Parameter memo: a memo can be provided to reference what thes batch of payments were for. If no memo is desired, then set it to `KinMemo.none`
     - Returns: a `Promise` with the blockchain confirmed `KinPayment`s or an error
     */
    func sendKinPayments(_ payments: [KinPaymentItem], memo: KinMemo, sourceAccountSpec: AccountSpec, destinationAccountSpec: AccountSpec) -> Promise<[KinPayment]>

    func payInvoice(processingAppIdx: AppIndex, destinationAccount: PublicKey, invoice: Invoice, type: KinBinaryMemo.TransferType) -> Promise<KinPayment>
}

/**
 Instantiate a `KinAccountContext` to operate on a `KinAccount` when you have a private key.

 Can be used to:
    - create an account
    - get account data, payment history, and listen to changes over time
    - send payments
*/
public class KinAccountContext {
    public enum Errors: Error {
        case unknown
    }

    /// Provides different ways to build a `KinAccountContext`. Initialize the `Builder` with a `KinEnvironment` to start.
    public struct Builder {
        private let env: KinEnvironment

        public init(env: KinEnvironment) {
            self.env = env
        }

        /**
         Creates a new `KinAccount`
         - Returns: a `NewAccountBuilder`, call `.build()` on it to get an instance of KinAccountContext with a new account.
        */
        public func createNewAccount() -> NewAccountBuilder {
            return NewAccountBuilder(env: env)
        }

        /**
         Let's you access the specified `KinAccount`
         - Parameter accountId: denoting the `KinAccount` to get information from
         - Returns: an `ExistingAccountBuilder`, call `.build()` on it to get an instance of KinAccountContext with the specified account.
        */
        public func useExistingAccount(_ account: PublicKey) -> ExistingAccountBuilder {
            return ExistingAccountBuilder(env: env, account: account)
        }

        /**
         Let's you access the `KinAccount` from a private key
         - Parameter key: a `KinAccount.Key` that contains the private key
         - Returns: an `ExistingAccountBuilder`, call `.build()` on it to get an instance of KinAccountContext with the specified account.
         - Throws: an error if `key` doesn't contain a private key
        */
        public func importExistingPrivateKey(_ key: KeyPair) throws -> ExistingAccountBuilder {
            try env.importPrivateKey(key)
            return ExistingAccountBuilder(env: env, account: key.publicKey)
        }
    }

    public struct NewAccountBuilder {
        private let env: KinEnvironment

        init(env: KinEnvironment) {
            self.env = env
        }

        public func build() throws -> KinAccountContext {
            let newAccount = try createNewAccount()
            return KinAccountContext(environment: env, account: newAccount.publicKey)
        }

        private func createNewAccount() throws -> KinAccount {
            guard let key = KeyPair.generate() else {
                throw Errors.unknown
            }
            
            let newAccount = KinAccount(publicKey: key.publicKey, privateKey: key.privateKey)
            return try env.storage.addAccount(newAccount)
        }
    }

    public struct ExistingAccountBuilder {
        let env: KinEnvironment
        let account: PublicKey

        public func build() -> KinAccountContext {
            return KinAccountContext(environment: env, account: account)
        }
    }
    
    public let env: KinEnvironment
    
    private lazy var log = {
        env.logger.getLogger(name: String(describing: self))
    }()

    /// A service used to retrieve all account and payment data
    public let service: KinServiceType

    /// Stores all account and payment data. See `KinFileStorage` for provided implementation.
    public let storage: KinStorageType

    /// A `DispatchQueue` to run operations on
    public let dispatchQueue: DispatchQueue

    /// Denotes the `KinAccount` to get information from
    public let accountPublicKey: PublicKey

    private lazy var balanceSubject: ValueSubject<KinBalance> = {
        let subject = ValueSubject<KinBalance>()
        return subject.setInvalidation { [weak self] in
            self?.getAccount()
                .then {  $0.balance }
                .then { subject.onNext($0) }
                .then { self?.fetchUpdatedBalance() }
                .catch { _ in }
        }.invalidate()
    }()

    private lazy var paymentsSubject: ListSubject<KinPayment> = {
        let subject = ListSubject<KinPayment>()
        subject.setFetchNextPage { [weak self] in
            self?.requestNextPage()
                .then { $0.kinPayments }
                .then { subject.onNext($0) }
                .catch { _ in }
        }

        subject.setFetchPreviousPage { [weak self] in
            self?.requestPreviousPage()
                .then { $0.kinPayments }
                .then { subject.onNext($0) }
                .catch { _ in }
        }

        subject.setInvalidation { [weak self] in
            guard let self = self else {
                return
            }
            self.storage.getStoredTransactions(account: self.accountPublicKey)
                .then { $0?.items ?? [] }
                .then { $0.kinPayments.reversed() }
                .then { subject.onNext($0) }
                .then { self.fetchUpdatedTransactionHistory() }
                .catch { _ in }
        }

        return subject.invalidate()
    }()

    private var accountObservable: Observable<KinAccount>?

    private let disposeBag = DisposeBag()

    init(environment: KinEnvironment, account: PublicKey) {
        self.env = environment
        self.service = environment.service
        self.storage = environment.storage
        self.dispatchQueue = environment.dispatchQueue
        self.accountPublicKey = account
    }

    deinit {
        disposeBag.dispose()
    }
}

// MARK: KinAccountReadOperations
extension KinAccountContext: KinAccountReadOperations {
    public func getAccount(forceUpdate: Bool = false) -> Promise<KinAccount> {
        log.info(msg: #function)
        return storage.getAccount(accountPublicKey)
            .then(on: dispatchQueue) { storedAccount -> Promise<KinAccount> in
                guard let account = storedAccount else {
                    return self.getAccountAndRecover()
                }
                
                switch account.status {
                case .unregistered:
                    return self.registerAccount(account: account)
                        .then(on: self.dispatchQueue) { _ in
                            self.getAccountAndRecover()
                        }
                    
                case .registered:
                    if forceUpdate {
                        return self.getAccountAndRecover()
                    } else {
                        return .init(account)
                    }
                }
            }
    }
    
    private func getAccountAndRecover() -> Promise<KinAccount> {
        service
            .getAccount(account: self.accountPublicKey)
            .recover { error -> Promise<KinAccount> in
                guard let serviceError = error as? KinServiceV4.Errors, serviceError == KinServiceV4.Errors.itemNotFound else {
                    return Promise(error)
                }
                
                return self.service.resolveTokenAccounts(account: self.accountPublicKey).then { accounts in
                    let maybeResolvedAccount = accounts.first?.publicKey ?? self.accountPublicKey
                    return self.service.getAccount(account: maybeResolvedAccount).then { account -> KinAccount in
                        // b/c we want to update our on hand account with the resolved accountInfo details on solana
                        
                        return account.copy(
                            publicKey: self.accountPublicKey,
                            tokenAccounts: accounts
                        )
                    }
                }
            }
            .then {
                self.storage.updateAccount($0)
            }
    }

    public func observeBalance(mode: ObservationMode = .passive) -> Observable<KinBalance> {
        log.info(msg: #function)
        switch mode {
        case .active, .activeNewOnly:
            setUpAccountStreamIfNecessary()
        default:
            break
        }

        return balanceSubject
    }

    public func clearStorage() -> Promise<Void> {
        log.info(msg: #function)
        return storage.removeAccount(account: accountPublicKey)
    }
}

// MARK: KinPaymentReadOperations
extension KinAccountContext: KinPaymentReadOperations {
    public func observePayments(mode: ObservationMode = .passive) -> ListObservable<KinPayment> {
        log.info(msg: #function)
        switch mode {
        case .passive:
            return paymentsSubject
        case .active:
            setUpAccountStreamIfNecessary()
            return paymentsSubject
        case .activeNewOnly:
            let subject = ListSubject<KinPayment>()
            let lifecycle = DisposeBag()
            service.streamNewTransactions(account: accountPublicKey)
                .subscribe { transaction in
                    subject.onNext(transaction.kinPayments)
                }
                .disposedBy(lifecycle)
            return subject.doOnDisposed {
                lifecycle.dispose()
            }
        }
    }

    public func getPaymentsForTransactionHash(_ transactionHash: KinTransactionHash) -> Promise<[KinPayment]> {
        log.info(msg: #function)
        return service.getTransaction(transactionHash: transactionHash)
            .then(on: dispatchQueue) { transaction -> Promise<[KinPayment]> in
                return .init(transaction.kinPayments)
        }
    }
}

// MARK: KinPaymentWriteOperations
extension KinAccountContext: KinPaymentWriteOperations {
    
    public func mergeTokenAccounts(for account: KinAccount, appIndex: AppIndex?) -> Promise<Void> {
        guard let privateKey = account.privateKey else {
            return Promise(Errors.unknown)
        }
        
        return service.mergeTokenAccounts(
            account: accountPublicKey,
            signer: KeyPair(publicKey: account.publicKey, privateKey: privateKey),
            appIndex: appIndex
        )
    }
    
    public func sendKinPayment(_ paymentItem: KinPaymentItem, memo: KinMemo) -> Promise<KinPayment> {
        log.info(msg: #function)
        return sendKinPayments([paymentItem], memo: memo)
            .then(on: dispatchQueue) { payments -> Promise<KinPayment> in
                return .init { fulfill, reject in
                    guard let payment = payments.first else {
                        reject(Errors.unknown)
                        return
                    }

                    fulfill(payment)
                }
        }
    }
    
    private struct SourceAccountSigningData {
        let nonce: Int64
        let ownerKey: KeyPair
        let sourceKey: PublicKey
    
        init(_ nonce: Int64, _ ownerKey: KeyPair, _ sourceKey: PublicKey) {
            self.nonce = nonce
            self.ownerKey = ownerKey
            self.sourceKey = sourceKey
        }
    }
    
    public func sendKinPayments(_ payments: [KinPaymentItem], memo: KinMemo, sourceAccountSpec: AccountSpec = .preferred, destinationAccountSpec: AccountSpec = .preferred) -> Promise<[KinPayment]> {
        log.info(msg: #function)
        let invoices = payments.compactMap { $0.invoice }
        let invoiceList = try? InvoiceList(invoices: invoices)
        var resultTransaction: KinTransaction?
        let MAX_ATTEMPTS = 10
        var attemptNumber = 0
        let invalidAccountErrorRetryStrategy = BackoffStrategy.fixed(after: 3, maxAttempts: MAX_ATTEMPTS)
        
        func buildAttempt(error: KinServiceV4.Errors? = nil) -> Promise<KinTransaction> {
            all(self.getAccount(), self.getFee())
                .then(on: self.dispatchQueue) { account, fee -> Promise<KinTransaction> in
                    var sourceAccountPromise: Promise<SourceAccountSigningData>
                    
                    if (attemptNumber == 0 && account.tokenAccounts.isEmpty) || sourceAccountSpec == .exact {
                        sourceAccountPromise = Promise {
                            SourceAccountSigningData(
                                account.sequence ?? 0,
                                KeyPair(publicKey: account.publicKey, privateKey: account.privateKey!), //FIXME:
                                account.publicKey
                            )
                        }
                    } else {
                        sourceAccountPromise = self.service.resolveTokenAccounts(account: self.accountPublicKey)
                            .then { tokenAccounts in
                                self.storage.updateAccount(account.copy(tokenAccounts: tokenAccounts))
                            }
                            .then { resolvedAccount in
                                SourceAccountSigningData(
                                    resolvedAccount.sequence ?? 0,
                                    KeyPair(publicKey: resolvedAccount.publicKey, privateKey: resolvedAccount.privateKey!), //FIXME:
                                    resolvedAccount.tokenAccounts.first?.publicKey ?? resolvedAccount.publicKey
                                )
                            }
                    }
                    
                    var paymentItemsPromise: Promise<[KinPaymentItem]>

                    var createAccountInstructions = [Instruction]()
                    var additionalSigners = [KeyPair]()
                    
                    if attemptNumber == 0 || destinationAccountSpec == .exact {
                        paymentItemsPromise = Promise { payments }
                    } else {
                        paymentItemsPromise = all(
                            payments.map { paymentItem in
                                self.service.resolveTokenAccounts(account: paymentItem.destAccount)
                                    .then {
                                        if $0.isEmpty && error == KinServiceV4.Errors.invalidAccount {
                                            return self.service.createTokenAccountForDestination(account: paymentItem.destAccount)
                                                .then { (instructions: [Instruction], newKeypair: KeyPair) in
                                                    createAccountInstructions.append(contentsOf: instructions)
                                                    additionalSigners.append(newKeypair)
                                                    return Promise(paymentItem.copy(destAccount: newKeypair.asPublicKey()))
                                                }
                                        } else {
                                            return Promise(paymentItem.copy(destAccount: $0.first?.publicKey))
                                        }
                                    }
                                    .recover { _ in Promise { paymentItem } }
                            }
                        )
                    }
                    
                    return sourceAccountPromise.then { accountData in
                        paymentItemsPromise.then { it in
                            attemptNumber = attemptNumber + 1
                            return self.getFee().then { fee in
                                self.service.buildAndSignTransaction(
                                    ownerKey: accountData.ownerKey,
                                    sourceKey: accountData.sourceKey,
                                    nonce: accountData.nonce,
                                    paymentItems: it,
                                    memo: memo,
                                    fee: fee,
                                    createAccountInstructions: createAccountInstructions,
                                    additionalSigners: additionalSigners
                                )
                            }
                        }
                    }
                }
        }
        
        func attempt(error: KinServiceV4.Errors? = nil) -> Promise<[KinPayment]> {
            func buildSignSubmit() -> Promise<KinTransaction> {
                return buildAttempt(error: error).then { signedTransaction -> Promise<KinTransaction> in
                    guard let transaction: KinTransaction = try? KinTransaction(envelopeXdrBytes: signedTransaction.envelopeXdrBytes, record: signedTransaction.record, network: signedTransaction.network, invoiceList: invoiceList) else {
                        return Promise(Errors.unknown)
                    }
                    return Promise { transaction }
                }
            }
            return self.service.buildSignAndSubmitTransaction(buildAndSignTransaction:buildSignSubmit)
                .then(on: self.dispatchQueue) { transaction -> Promise<KinAccount> in
                    resultTransaction = transaction
                    return self.storage.advanceSequence(account: self.accountPublicKey)
                }
                .then(on: self.dispatchQueue) { _ in
                    self.storage.insertNewTransaction(account: self.accountPublicKey, newTransaction: resultTransaction!)
                        .then { _ in resultTransaction }
                }
                .then(on: self.dispatchQueue) { [weak self] transaction -> [KinPayment] in
                    guard let self = self else {
                        throw Errors.unknown
                    }
                    
                    let payments = transaction!.kinPayments
                    
                    // If we have an active stream then we rely on that update for balance changes
                    if (self.accountObservable == nil) {
                        let amountToDeduct = payments.reduce(Kin.zero) { $0 + $1.amount }
                        
                        let account = try `await`(self.storage.deductFromAccountBalance(account: self.accountPublicKey, amount: amountToDeduct))
                        self.balanceSubject.onNext(account.balance)
                    }
                    
                    return payments
                }.recover { [weak self] (error: Error) -> Promise<[KinPayment]> in
                    guard let self = self else {
                        return Promise.init(Errors.unknown)
                    }
                    
                    guard attemptNumber < MAX_ATTEMPTS else {
                        return Promise.init(error)
                    }
                    if (error as? KinServiceV4.Errors) == KinServiceV4.Errors.badSequenceNumber {
                        self.service.invalidateRecentBlockHashCache()
                        return attempt(error: error as? KinServiceV4.Errors)
                    } else if (error as? KinServiceV4.Errors) == KinServiceV4.Errors.invalidAccount {
                        Thread.sleep(until: Date().addingTimeInterval((try? invalidAccountErrorRetryStrategy.nextDelay()) ?? 0))
                        return attempt(error: error as? KinServiceV4.Errors)
                    } else {
                        return Promise.init(error)
                    }
                }
        }
        
        return attempt()
    }

    public func payInvoice(processingAppIdx: AppIndex, destinationAccount: PublicKey, invoice: Invoice, type: KinBinaryMemo.TransferType = .spend) -> Promise<KinPayment> {
        log.info(msg: #function)
        do {
            let invoiceList = try InvoiceList(invoices: [invoice])
            let agoraMemo = try KinBinaryMemo(
                typeId: type.rawValue,
                appIdx: processingAppIdx.value,
                foreignKeyBytes: invoiceList.id.decode()
            )
            let paymentItem = KinPaymentItem(
                amount: invoice.total,
                destAccount: destinationAccount,
                invoice: invoice
            )
            return sendKinPayment(paymentItem, memo: agoraMemo.kinMemo)
        } catch let error {
            return .init(error)
        }
    }
}

// MARK: Private
extension KinAccountContext {
    private func unregisteredAccount() -> Promise<KinAccount> {
        Promise(on: dispatchQueue) { fulfill, reject in
            let account = KinAccount(publicKey: self.accountPublicKey)
            fulfill(account)
        }
    }

    private func registerAccount(account: KinAccount) -> Promise<KinAccount> {
        let keyPair = KeyPair(publicKey: account.publicKey, privateKey: account.privateKey!) // FIXME:
        return service.createAccount(account: account.publicKey, signer: keyPair, appIndex: AppIndex(value: 0))
            .then(on: dispatchQueue) { registeredAccount -> KinAccount in
                return account.merge(registeredAccount)
            }
            .then(on: dispatchQueue) { registeredAccount -> Promise<KinAccount> in
                return self.storage.updateAccount(registeredAccount)
            }
    }

    private func getFee() -> Promise<Quark> {
        return service.canWhitelistTransactions()
            .then { [weak self] canWhitelist -> Promise<Quark> in
                if canWhitelist {
                    return .init(Quark.zero)
                }

                guard let self = self else {
                    return .init(Errors.unknown)
                }

                if let cached = self.storage.getMinFee() {
                    return .init(cached)
                }

                return self.service.getMinFee()
                    .then { [weak self] fee in
                        self?.storage.setMinFee(fee)
                    }
        }
    }

    private func fetchUpdatedBalance() -> Promise<KinBalance> {
        return getAccount(forceUpdate: true)
            .then { self.storage.updateAccount($0) }
            .then { $0.balance }
            .then { self.balanceSubject.onNext($0) }
    }

    private func setUpAccountStreamIfNecessary() {
        guard accountObservable == nil else {
            return
        }

        accountObservable = service.streamAccount(account: self.accountPublicKey)
            .subscribe { [weak self] account in
                self?.storage.updateAccount(account)
                    // Yea...this 5s delay is gross but reads aren't
                    // deterministic with the account update events so
                    // instead of polling (worse), we delay for a
                    // 'best effort' history update.
                    .then { self?.balanceSubject.onNext($0.balance) }
                    .delay(5)
                    .then { self?.fetchUpdatedTransactionHistory() }
                    .catch { _ in }
                }
            .disposedBy(disposeBag)
    }

    private func requestNextPage() -> Promise<[KinTransaction]> {
        return storage.getStoredTransactions(account: accountPublicKey)
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                if let headPagingToken = transactions?.headPagingToken, !headPagingToken.isEmpty {
                    return self.service.getTransactionPage(account: self.accountPublicKey, pagingToken: headPagingToken, order: .descending)
                } else {
                    return self.service.getLatestTransactions(account: self.accountPublicKey)
                }
            }
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                return self.storage.upsertNewTransactions(account: self.accountPublicKey, newTransactions: transactions)
            }
    }

    private func requestPreviousPage() -> Promise<[KinTransaction]> {
        return storage.getStoredTransactions(account: accountPublicKey)
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                if let tailPagingToken = transactions?.tailPagingToken {
                    return self.service.getTransactionPage(account: self.accountPublicKey, pagingToken: tailPagingToken, order: .descending)
                } else {
                    return self.service.getLatestTransactions(account: self.accountPublicKey)
                }
            }
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                return self.storage.upsertOldTransactions(account: self.accountPublicKey, oldTransactions: transactions)
            }
    }

    private func fetchUpdatedTransactionHistory() -> Promise<[KinTransaction]> {
        return requestNextPage()
            .then { [weak self] transactions in
                self?.paymentsSubject.onNext(transactions.kinPayments)
            }
    }
}
