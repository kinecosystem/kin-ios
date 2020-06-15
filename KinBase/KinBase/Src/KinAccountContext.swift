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
                         memo: KinMemo)
        -> Promise<[KinPayment]>
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
            let importedAccount = try env.importPrivateKey(key)
            return ExistingAccountBuilder(env: env,
                                          accountId: importedAccount.id)
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
        return storage.getAccount(accountId)
            .then(on: dispatchQueue) { account -> Promise<KinAccount> in
                guard let account = account else {
                    return self.service.getAccount(accountId: self.accountId)
                }

                switch account.status {
                case .unregistered:
                    return self.service.getAccount(accountId: self.accountId)
                        .then(on: self.dispatchQueue) { self.storage.updateAccount($0) }
                        .recover(on: self.dispatchQueue) { _ in self.registerAccount(account: account) }
                case .registered:
                    if forceUpdate {
                        return self.service.getAccount(accountId: self.accountId)
                            .then(on: self.dispatchQueue) { self.storage.updateAccount($0) }
                    } else {
                        return .init(account)
                    }
                }
            }
    }

    public func observeBalance(mode: ObservationMode = .passive) -> Observable<KinBalance> {
        switch mode {
        case .active, .activeNewOnly:
            setUpAccountStreamIfNecessary()
        default:
            break
        }

        return balanceSubject
    }

    public func clearStorage() -> Promise<Void> {
        return storage.removeAccount(accountId: accountId)
    }
}

// MARK: KinPaymentReadOperations
extension KinAccountContext: KinPaymentReadOperations {
    public func observePayments(mode: ObservationMode = .passive) -> ListObservable<KinPayment> {
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
        return service.getTransaction(transactionHash: transactionHash)
            .then(on: dispatchQueue) { transaction -> Promise<[KinPayment]> in
                return .init(transaction.kinPayments)
        }
    }
}

// MARK: KinPaymentWriteOperations
extension KinAccountContext: KinPaymentWriteOperations {
    public func sendKinPayment(_ paymentItem: KinPaymentItem, memo: KinMemo) -> Promise<KinPayment> {
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

    public func sendKinPayments(_ payments: [KinPaymentItem], memo: KinMemo) -> Promise<[KinPayment]> {
        return all(getAccount(), getFee())
            .then(on: dispatchQueue) { account, fee -> Promise<KinTransaction> in
                self.service.buildAndSignTransaction(sourceKinAccount: account,
                                                     paymentItems: payments,
                                                     memo: memo,
                                                     fee: fee)
            }
            .then(on: dispatchQueue) { transaction -> Promise<KinTransaction> in
                self.service.submitTransaction(transaction: transaction)
            }
            .then(on: dispatchQueue) { [weak self] transaction -> [KinPayment] in
                guard let self = self else {
                    throw Errors.unknown
                }

                _ = try await(self.storage.advanceSequence(accountId: self.accountId))
                _ = try await(self.storage.insertNewTransaction(accountId: self.accountId,
                                                                newTransaction: transaction))
                let payments = transaction.kinPayments
                let amountToDeduct = payments.reduce(Kin.zero) { $0 + $1.amount }

                let account = try await(self.storage.deductFromAccountBalance(accountId: self.accountId,
                                                                              amount: amountToDeduct))
                self.balanceSubject.onNext(account.balance)

                return payments
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
        return service.createAccount(accountId: account.id)
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
        return service.getAccount(accountId: accountId)
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
                    .then { self?.balanceSubject.onNext($0.balance) }
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

                if let headPagingToken = transactions?.headPagingToken {
                    return self.service.getTransactionPage(accountId: self.accountId,
                                                           pagingToken: headPagingToken,
                                                           order: .ascending)
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
