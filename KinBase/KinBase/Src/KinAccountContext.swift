//
//  KinAccountContext.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-07.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
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
     Send a `paymentItem` to the Kin Blockchain for processing.
     - Parameter paymentItem: a `KinPaymentItem` which contains the amount of Kin to be sent and the account the Kin is to be transferred to
     - Parameter memo: a memo can be provided to reference what the payment was for., if no memo is desired, then set it to `KinMemo.none`
     - Returns: a `Promise` with the blockchain confirmed `KinPayment`
    */
    func sendKinPayment(_ paymentItem: KinPaymentItem,
                        memo: KinMemo)
        -> Promise<KinPayment>

    /**
     Sends a batch of payments, each corresponding to `KinPaymentItem` in a single `KinTransaction` to be processed together.
     - Note: If any one payment's data is invalid, all payments will fail.
     - Parameter payments: array of `KinPaymentItem`s to be sent
     - Parameter memo: a memo can be provided to reference what thes batch of payments were for. If no memo is desired, then set it to `KinMemo.none`
     - Returns: a `Promise` with the blockchain confirmed `KinPayment`s or an error
     */
    func sendKinPayments(_ payments: [KinPaymentItem],
                         memo: KinMemo,
                         sourceAccountSpec: AccountSpec,
                         destinationAccountSpec: AccountSpec)
        -> Promise<[KinPayment]>

    func payInvoice(processingAppIdx: AppIndex,
                    destinationAccount: KinAccount.Id,
                    invoice: Invoice,
                    type: KinBinaryMemo.TransferType)
        -> Promise<KinPayment>
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
        public func useExistingAccount(_ accountId: KinAccount.Id) -> ExistingAccountBuilder {
            return ExistingAccountBuilder(env: env,
                                          accountId: accountId)
        }

        /**
         Let's you access the `KinAccount` from a private key
         - Parameter key: a `KinAccount.Key` that contains the private key
         - Returns: an `ExistingAccountBuilder`, call `.build()` on it to get an instance of KinAccountContext with the specified account.
         - Throws: an error if `key` doesn't contain a private key
        */
        public func importExistingPrivateKey(_ key: KinAccount.Key) throws -> ExistingAccountBuilder {
            try env.importPrivateKey(key)
            return ExistingAccountBuilder(env: env, accountId: key.accountId)
        }
    }

    public struct NewAccountBuilder {
        private let env: KinEnvironment

        init(env: KinEnvironment) {
            self.env = env
        }

        public func build() throws -> KinAccountContext {
            let newAccount = try createNewAccount()
            return KinAccountContext(environment: env, accountId: newAccount.id)
        }

        private func createNewAccount() throws -> KinAccount {
            let key = try KeyPair.generateRandomKeyPair()
            let newAccount = KinAccount(key: key)
            return try env.storage.addAccount(newAccount)
        }
    }

    public struct ExistingAccountBuilder {
        let env: KinEnvironment
        let accountId: KinAccount.Id

        public func build() -> KinAccountContext {
            return KinAccountContext(environment: env, accountId: accountId)
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
    public let accountId: KinAccount.Id

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
            self.storage.getStoredTransactions(accountId: self.accountId)
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

    init(environment: KinEnvironment,
         accountId: KinAccount.Id) {
        self.env = environment
        self.service = environment.service
        self.storage = environment.storage
        self.dispatchQueue = environment.dispatchQueue
        self.accountId = accountId
    }

    deinit {
        disposeBag.dispose()
    }
}

// MARK: KinAccountReadOperations
extension KinAccountContext: KinAccountReadOperations {
    public func getAccount(forceUpdate: Bool = false) -> Promise<KinAccount> {
        log.info(msg: #function)
        return storage.getAccount(accountId)
            .then(on: dispatchQueue) { storedAccount -> Promise<KinAccount> in
                func getAccountAndRecover() -> Promise<KinAccount> {
                    return self.service.getAccount(accountId: self.accountId)
                    .recover { error -> Promise<KinAccount> in
                        guard let serviceError = error as? KinServiceV4.Errors, serviceError == KinServiceV4.Errors.itemNotFound else {
                            return Promise(error)
                        }
                        return self.service.resolveTokenAccounts(accountId: self.accountId).then { accounts in
                            let maybeResolvedAccountId = accounts.first?.accountId ?? self.accountId
                            return self.service.getAccount(accountId: maybeResolvedAccountId).then { it -> KinAccount in
                                // b/c we want to update our on hand account with the resolved accountInfo details on solana
                                return it.copy(
                                    key: try! KinAccount.Key(accountId: self.accountId),
                                    tokenAccounts: accounts
                                )
                            }
                        }
                    }.then { it in self.storage.updateAccount(it) }
                }
                guard let account = storedAccount else {
                    return getAccountAndRecover()
                }

                switch account.status {
                case .unregistered:
                    return self.registerAccount(account: account)
                        .then(on: self.dispatchQueue) { _ in getAccountAndRecover() }
//                    return getAccountAndRecover()
//                        .then(on: self.dispatchQueue) { self.storage.updateAccount($0) }
//                        .recover(on: self.dispatchQueue) { _ in self.registerAccount(account: account) }
//                        .recover(on: self.dispatchQueue) { _ in return account }
                case .registered:
                    if forceUpdate {
                        return getAccountAndRecover()
                    } else {
                        return .init(account)
                    }
                }
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
        return storage.removeAccount(accountId: accountId)
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
            service.streamNewTransactions(accountId: accountId)
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
        let ownerKey: KinAccount.Key // Private Key
        let sourceKey: KinAccount.Key // Public Key
    
        init(_ nonce: Int64, _ ownerKey: KinAccount.Key, _ sourceKey: KinAccount.Key) {
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
        
        func buildAttempt() -> Promise<KinTransaction> {
            return all(self.getAccount(), self.getFee())
                .then(on: self.dispatchQueue) { account, fee -> Promise<KinTransaction> in
                    var sourceAccountPromise: Promise<SourceAccountSigningData>
                    
                    if ((attemptNumber == 0 && account.tokenAccounts.isEmpty) || sourceAccountSpec == .exact) {
                        sourceAccountPromise = Promise {
                            SourceAccountSigningData(
                                account.sequence ?? 0,
                                account.key,
                                account.key
                            )
                        }
                    } else {
                        sourceAccountPromise = self.service.resolveTokenAccounts(accountId: self.accountId)
                            .then { it in self.storage.updateAccount(account.copy(tokenAccounts: it)) }
                            .then { resolvedAccount in
                                SourceAccountSigningData(
                                    resolvedAccount.sequence ?? 0,
                                    resolvedAccount.key,
                                    resolvedAccount.tokenAccounts.first ?? resolvedAccount.key
                                )
                            }
                    }
                    
                    var paymentItemsPromise: Promise<[KinPaymentItem]>
                    
                    if (attemptNumber == 0 || destinationAccountSpec == .exact) {
                        paymentItemsPromise = Promise { payments }
                    } else {
                        paymentItemsPromise = all(
                            payments.map { paymentItem in
                                self.service.resolveTokenAccounts(accountId: paymentItem.destAccountId)
                                    .then { (it:[KinAccount.Key]) -> KinPaymentItem in
                                        paymentItem.copy(destAccountId: it.first?.accountId)
                                    }
                                    .recover { _ in Promise { paymentItem } }
                            }
                        )
                    }
                    
                    return sourceAccountPromise.then { accountData in
                        paymentItemsPromise.then { it in
                            attemptNumber = attemptNumber + 1
                            return self.getFee()
                                .then { fee in
                                    self.service.buildAndSignTransaction(
                                        ownerKey: accountData.ownerKey,
                                        sourceKey: accountData.sourceKey,
                                        nonce: accountData.nonce,
                                        paymentItems: it,
                                        memo: memo,
                                        fee: fee // feeOverride ?: fee
                                    )
                            }
//                            .then { it in
//                                    if (it is StellarKinTransaction) {
//                                        let tx = org.kin.stellarfork.Transaction.fromEnvelopeXdr(Base64.encodeBase64String(it.bytesValue), it.networkEnvironment.getNetwork())
//                                        if (signaturesOverride.isNotEmpty()) {
//                                            tx.signatures = signaturesOverride
//                                        }
//
//                                        it.copy(bytesValue = Base64.decodeBase64(tx.toEnvelopeXdrBase64())!!)
//                                    } else it
//                                }
//                            }
                        }
                    }
                }
        }
        
        func attempt() -> Promise<[KinPayment]> {
            func buildSignSubmit() -> Promise<KinTransaction> {
                return buildAttempt().then { signedTransaction -> Promise<KinTransaction> in
                    guard let transaction: KinTransaction = try? KinTransaction(envelopeXdrBytes: signedTransaction.envelopeXdrBytes, record: signedTransaction.record, network: signedTransaction.network, invoiceList: invoiceList) else {
                        return Promise(Errors.unknown)
                    }
                    return Promise { transaction }
                }
            }
            return self.service.buildSignAndSubmitTransaction(buildAndSignTransaction:buildSignSubmit)
                .then(on: self.dispatchQueue) { transaction -> Promise<KinAccount> in
                        resultTransaction = transaction
                        return self.storage.advanceSequence(accountId: self.accountId)
                }
                .then(on: self.dispatchQueue) { _ in
                        self.storage.insertNewTransaction(accountId: self.accountId,
                                                          newTransaction: resultTransaction!)
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

                            let account = try await(self.storage.deductFromAccountBalance(accountId: self.accountId,
                                                                                          amount: amountToDeduct))
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
                        
                        if (error as? KinServiceV4.Errors == KinServiceV4.Errors.badSequenceNumber) {
                            self.service.invalidateRecentBlockHashCache()
                            return attempt()
                        } else if (error as? KinService.Errors == KinService.Errors.badSequenceNumber) {
                            if ((self.service as? KinServiceWrapper)?.metaServiceApi.configuredMinApi == 4) {
                                self.service.invalidateRecentBlockHashCache()
                                return attempt()
                            } else {
                                return self.getAccount(forceUpdate: true).then { _ in
                                    return attempt()
                                }
                            }
                        } else if (error as? KinServiceV4.Errors == KinServiceV4.Errors.invalidAccount) {
                            Thread.sleep(until: Date().addingTimeInterval((try? invalidAccountErrorRetryStrategy.nextDelay()) ?? 0))
                            return attempt()
                        } else {
                            return Promise.init(error)
                        }
                }
        }
        
        return attempt()
    }

    public func payInvoice(processingAppIdx: AppIndex,
                           destinationAccount: KinAccount.Id,
                           invoice: Invoice,
                           type: KinBinaryMemo.TransferType = .spend) -> Promise<KinPayment> {
        log.info(msg: #function)
        do {
            let invoiceList = try InvoiceList(invoices: [invoice])
            let agoraMemo = try KinBinaryMemo(typeId: type.rawValue,
                                          appIdx: processingAppIdx.value,
                                          foreignKeyBytes: invoiceList.id.decode())
            let paymentItem = KinPaymentItem(amount: invoice.total,
                                             destAccountId: destinationAccount,
                                             invoice: invoice)
            return sendKinPayment(paymentItem,
                                  memo: agoraMemo.kinMemo)
        } catch let error {
            return .init(error)
        }
    }
}

// MARK: Private
extension KinAccountContext {
    private func unregisteredAccount() -> Promise<KinAccount> {
        return .init(on: dispatchQueue) { fulfill, reject in
            do {
                let account = try KinAccount(key: KinAccount.Key(accountId: self.accountId))
                fulfill(account)
            } catch let error {
                reject(error)
            }
        }
    }

    private func registerAccount(account: KinAccount) -> Promise<KinAccount> {
        return service.createAccount(accountId: account.id, signer: account.key)
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

        accountObservable = service.streamAccount(accountId: self.accountId)
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
        return storage.getStoredTransactions(accountId: accountId)
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                if let headPagingToken = transactions?.headPagingToken, !headPagingToken.isEmpty {
                    return self.service.getTransactionPage(accountId: self.accountId,
                                                           pagingToken: headPagingToken,
                                                           order: .descending)
                } else {
                    return self.service.getLatestTransactions(accountId: self.accountId)
                }
            }
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                return self.storage.upsertNewTransactions(accountId: self.accountId,
                                                          newTransactions: transactions)
            }
    }

    private func requestPreviousPage() -> Promise<[KinTransaction]> {
        return storage.getStoredTransactions(accountId: accountId)
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                if let tailPagingToken = transactions?.tailPagingToken {
                    return self.service.getTransactionPage(accountId: self.accountId,
                                                           pagingToken: tailPagingToken,
                                                           order: .descending)
                } else {
                    return self.service.getLatestTransactions(accountId: self.accountId)
                }
            }
            .then { [weak self] transactions -> Promise<[KinTransaction]> in
                guard let self = self else {
                    return .init(Errors.unknown)
                }

                return self.storage.upsertOldTransactions(accountId: self.accountId,
                                                          oldTransactions: transactions)
            }
    }

    private func fetchUpdatedTransactionHistory() -> Promise<[KinTransaction]> {
        return requestNextPage()
            .then { [weak self] transactions in
                self?.paymentsSubject.onNext(transactions.kinPayments)
            }
    }
}
