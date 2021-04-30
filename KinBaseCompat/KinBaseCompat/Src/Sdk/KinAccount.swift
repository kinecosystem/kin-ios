//
//  KinAccount.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase
import Promises

/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
public final class KinAccount {

    var kinBaseAccount: KinBase.KinAccount?
    let accountData: AccountData
    let key: KinBase.KinAccount.Key
    let network: KinNetwork
    let appId: AppId
    var deleted = false

    let kinAccountContext: KinAccountContext
    let kinService: KinServiceType

    let disposeBag = DisposeBag()

    /**
     The public address of this account. If the user wants to receive KIN by sending his address
     manually to someone, or if you want to display the public address, use this property.
     */
    public var publicAddress: String {
        return key.accountId
    }

    init(key: KinBase.KinAccount.Key,
         accountData: AccountData,
         kinAccountContext: KinAccountContext,
         kinService: KinServiceType,
         network: KinNetwork,
         appId: AppId) {
        self.key = key
        self.accountData = accountData
        self.kinAccountContext = kinAccountContext
        self.kinService = kinService
        self.network = network
        self.appId = appId
    }

    deinit {
        disposeBag.dispose()
    }

    /**
         Export the account data as a JSON string.  The seed is encrypted.

         - Parameter passphrase: The passphrase with which to encrypt the seed

         - Returns: A JSON representation of the data as a string
         */
    public func export(passphrase: String) throws -> String {
        let ad = KeyStore.exportAccount(accountData: accountData,
                                        passphrase: "",
                                        newPassphrase: passphrase)

        guard let jsonString = try String(data: JSONEncoder().encode(ad), encoding: .utf8) else {
            throw KinError.internalInconsistency
        }

        return jsonString
    }

    /**
         Query the status of the account on the blockchain.

         - Parameter completion: The completion handler function with the `AccountStatus` or an `Error.
         */
    public func status(completion: @escaping (AccountStatus?, Error?) -> Void) {
        kinAccountContext.getAccount(forceUpdate: true)
            .then { [weak self] account in
                self?.kinBaseAccount = account
                completion(account.status.accountStatus, nil)
            }
            .catch { error in
                completion(nil, error)
            }
    }

    /**
         Query the status of the account on the blockchain using promises.

         - Returns: A promise which will signal the `AccountStatus` value.
         */
    public func status() -> Promise<AccountStatus> {
        return promise(status)
    }

    /**
         Build a Kin transaction for a specific address.

         The completion block is called after the transaction is posted on the network, which is prior
         to confirmation.

         - Attention: The completion block **is not dispatched on the main thread**.

         - Parameter recipient: The recipient's public address.
         - Parameter kin: The amount of Kin to be sent.
         - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
         - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.
         - Parameter completion: A completion with the `TransactionEnvelope` or an `Error`.
         */
    public func generateTransaction(to recipient: String,
                                        kin: Kin,
                                        memo: String? = nil,
                                        fee: Stroop = 0,
                                        completion: @escaping GenerateTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        guard kin > Kin.zero else {
            completion(nil, KinError.invalidAmount)
            return
        }

        // Set up memo
        let prefixedMemo = Memo.prependAppIdIfNeeded(appId, to: memo ?? "")

        guard prefixedMemo.utf8.count <= Memo.maxMemoLength else {
            completion(nil, StellarError.memoTooLong(prefixedMemo))
            return
        }

        let kinMemo = KinBase.KinMemo(text: prefixedMemo)

        // Set up payment items
        let paymentItems = [
                            KinPaymentItem(amount: kin as KinBase.Kin,
                                           destAccountId: recipient)
                            ]

        // Build transaction
        if let account = kinBaseAccount {
            kinService.buildAndSignTransaction(ownerKey: account.key,
                                               sourceKey: account.key,
                                               nonce: account.sequenceNumber,
                                               paymentItems: paymentItems,
                                               memo: kinMemo,
                                               fee: KinBase.Quark(fee))
                .then { completion(Transaction(transaction: $0).envelope(), nil) }
                .catch { completion(nil, $0) }
        } else {
            kinAccountContext.getAccount(forceUpdate: true)
                .then { [weak self] account -> Promises.Promise<KinTransaction> in
                    guard let self = self else {
                        return .init(KinError.unknown)
                    }

                    self.kinBaseAccount = account
                    return self.kinService.buildAndSignTransaction(ownerKey: account.key,
                                                                   sourceKey: account.key,
                                                                   nonce: account.sequenceNumber,
                                                                   paymentItems: paymentItems,
                                                                   memo: kinMemo,
                                                                   fee: KinBase.Quark(fee))
                }
                .then { completion(Transaction(transaction: $0).envelope(), nil) }
                .catch { completion(nil, $0) }
        }
    }

    /**
         Build a Kin transaction for a specific address.

         - Parameter recipient: The recipient's public address.
         - Parameter kin: The amount of Kin to be sent.
         - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
         - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.

         - Returns: A promise which is signalled with the `TransactionEnvelope` or an `Error`.
         */
    public func generateTransaction(to recipient: String,
                                        kin: Kin,
                                        memo: String? = nil,
                                        fee: Quark) -> Promise<TransactionEnvelope> {
        let txClosure = { (txComp: @escaping GenerateTransactionCompletion) in
            self.generateTransaction(to: recipient, kin: kin, memo: memo, fee: fee, completion: txComp)
        }

        return promise(txClosure)
    }

    /**
         Send a Kin transaction.

         The completion block is called after the transaction is posted on the network, which is prior
         to confirmation.

         - Attention: The completion block **is not dispatched on the main thread**.

         - Parameter envelope: The `TransactionEnvelope` to send.
         - Parameter completion: A completion with the `TransactionId` or an `Error`.
         */
    public func sendTransaction(_ envelope: TransactionEnvelope, completion: @escaping SendTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }
            
        let paymentItems = envelope.transaction.paymentOperations.map { it in KinPaymentItem(amount: it.amount, destAccountId: it.destination) }
        kinAccountContext.sendKinPayments(paymentItems, memo: envelope.transaction.memo)
            .then { it in completion(it.first?.id.transactionHash.description, nil) }
            .catch { error in
                if let kinServiceError = error as? KinService.Errors,
                    case .insufficientBalance = kinServiceError {
                    completion(nil, KinError.insufficientFunds)
                } else {
                    completion(nil, error)
                }
        }
    }

    /**
         Send a Kin transaction.

         - Parameter envelope: The `TransactionEnvelope` to send.

         - Returns: A promise which is signalled with the `TransactionId` or an `Error`.
         */
    public func sendTransaction(_ envelope: TransactionEnvelope) -> Promise<TransactionId> {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            self.sendTransaction(envelope, completion: txComp)
        }

        return promise(txClosure)
    }

    /**
         Retrieve the current Kin balance.

         - Note: The closure is invoked on a background thread.

         - Parameter completion: A closure to be invoked once the request completes.
         */
    public func balance(completion: @escaping BalanceCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        kinAccountContext.getAccount(forceUpdate: true)
            .then { [weak self] account in
                self?.kinBaseAccount = account
                completion(account.balance.amount as Kin, nil)
            }
            .catch { error in
                completion(nil, error)
            }
    }

    /**
         Retrieve the current Kin balance.

         - returns: A `Promise` which is signalled with the current balance.
         */
    public func balance() -> Promise<Kin> {
        return promise(balance)
    }

    /**
         Watch for changes on the account balance.

         - Parameter balance: An optional `Kin` balance that the watcher will be notified of first.

         - Returns: A `BalanceWatch` object that will notify of any balance changes.
         */
    public func watchBalance(_ balance: Kin?) throws -> BalanceWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        let emitter = StatefulObserver<Kin>()

        if let balance = balance {
            emitter.next(balance)
        }

        kinAccountContext.observeBalance(mode: .active)
            .subscribe { newBalance in
                emitter.next(newBalance.amount as Kin)
            }
            .disposedBy(disposeBag)

        return BalanceWatch(emitter: emitter)
    }

    /**
         Watch for changes of account payments.

         - Parameter cursor: An optional `cursor` that specifies the id of the last payment after which the watcher will be notified of the new payments.

         - Returns: A `PaymentWatch` object that will notify of any payment changes.
         */
    public func watchPayments(cursor: String?) throws -> PaymentWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        let emitter = StatefulObserver<PaymentInfo>()
        let accountId = key.accountId
        var distinctPayments = [KinPayment]()
        kinAccountContext.observePayments(mode: .active)
            .subscribe { kinPayments in
                kinPayments.forEach { new in 
                    guard !distinctPayments.contains(new) else {
                        return
                    }

                    distinctPayments.append(new)

                    emitter.next(PaymentInfo(kinPayment: new,
                                             account: accountId))
                }
            }
            .disposedBy(disposeBag)

        return PaymentWatch(emitter: emitter)
    }

    /**
         Watch for the creation of an account.

         - Returns: A `Promise` that signals when the account is detected to have the `.created` `AccountStatus`.
         */
    public func watchCreation() throws -> Promise<Void> {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        if let account = kinBaseAccount, account.status == .registered {
            return .init(())
        }

        let promise = Promise<Void>()
        kinAccountContext.getAccount(forceUpdate: true)
            .then { [weak self] account in
                self?.kinBaseAccount = account
                promise.signal(())
            }
            .catch { error in
                promise.signal(error)
            }
        return promise
    }
}

extension KinBase.KinAccount.Status {
    var accountStatus: AccountStatus {
        switch self {
        case .registered:
            return .created
        default:
            return .notCreated
        }
    }
}
