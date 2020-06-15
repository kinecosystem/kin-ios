//
//  KinService.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-07.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
import stellarsdk

public enum TransactionOrder {
    case ascending
    case descending
}

public protocol KinServiceType {
    func createAccount(accountId: KinAccount.Id) -> Promise<KinAccount>

    func getAccount(accountId: KinAccount.Id) -> Promise<KinAccount>

    func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount>

    func getLatestTransactions(accountId: KinAccount.Id) -> Promise<[KinTransaction]>

    func getTransactionPage(accountId: KinAccount.Id,
                            pagingToken: String,
                            order: TransactionOrder) -> Promise<[KinTransaction]>

    func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction>

    func getMinFee() -> Promise<Quark>

    func canWhitelistTransactions() -> Promise<Bool>

    func buildAndSignTransaction(sourceKinAccount: KinAccount,
                                 paymentItems: [KinPaymentItem],
                                 memo: KinMemo,
                                 fee: Quark) -> Promise<KinTransaction>

    func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction>

    func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction>
}

public class KinService {
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

        public static func == (lhs: KinService.Errors, rhs: KinService.Errors) -> Bool {
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
            default:
                return false
            }
        }
    }

    private let network: KinNetwork
    private let networkOperationHandler: NetworkOperationHandler
    private let dispatchQueue: DispatchQueue

    private let accountApi: KinAccountApi
    private let accountCreationApi: KinAccountCreationApi
    private let transactionApi: KinTransactionApi
    private let transactionWhitelistingApi: KinTransactionWhitelistingApi

    public init(network: KinNetwork,
                networkOperationHandler: NetworkOperationHandler,
                dispatchQueue: DispatchQueue,
                accountApi: KinAccountApi,
                accountCreationApi: KinAccountCreationApi,
                transactionApi: KinTransactionApi,
                transactionWhitelistingApi: KinTransactionWhitelistingApi) {
        self.network = network
        self.networkOperationHandler = networkOperationHandler
        self.dispatchQueue = dispatchQueue
        self.accountApi = accountApi
        self.accountCreationApi = accountCreationApi
        self.transactionApi = transactionApi
        self.transactionWhitelistingApi = transactionWhitelistingApi
    }
}

extension KinService: KinServiceType {
    public func createAccount(accountId: KinAccount.Id) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.accountCreationApi.createAccount(request: CreateAccountRequest(accountId: accountId)) { (response) in
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
    }

    public func getAccount(accountId: KinAccount.Id) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.accountApi.getAccount(request: GetAccountRequest(accountId: accountId)) { response in
                switch response.result {
                case .ok:
                    if let account = response.account {
                        respond.onSuccess(account)
                        break
                    }
                    fallthrough
                case .error:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                }
            }
        }
    }

    public func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount> {
        return accountApi.streamAccount(accountId)
    }

    public func getLatestTransactions(accountId: KinAccount.Id) -> Promise<[KinTransaction]> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetTransactionHistoryRequest(accountId: accountId,
                                                       cursor: nil,
                                                       order: .descending)
            self.transactionApi.getTransactionHistory(request: request) { response in
                switch response.result {
                case .ok:
                    if let transactions = response.kinTransactions {
                        respond.onSuccess(transactions)
                        break
                    }
                    fallthrough
                case .error:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                }
            }
        }
    }

    public func getTransactionPage(accountId: KinAccount.Id,
                                   pagingToken: String,
                                   order: TransactionOrder) -> Promise<[KinTransaction]> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetTransactionHistoryRequest(accountId: accountId,
                                                       cursor: pagingToken,
                                                       order: order)
            self.transactionApi.getTransactionHistory(request: request) { response in
                switch response.result {
                case .ok:
                    if let transactions = response.kinTransactions {
                        respond.onSuccess(transactions)
                        break
                    }
                    fallthrough
                case .error:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
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

            let request = GetTransactionRequest(transactionHash: transactionHash)
            self.transactionApi.getTransaction(request: request) { response in
                switch response.result {
                case .ok:
                    if let transaction = response.kinTransaction {
                        respond.onSuccess(transaction)
                        break
                    }
                    fallthrough
                case .error:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                }
            }
        }
    }

    public func getMinFee() -> Promise<Quark> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.transactionApi.getTransactionMinFee { response in
                switch response.result {
                case .ok:
                    if let fee = response.fee {
                        respond.onSuccess(fee)
                        break
                    }
                    fallthrough
                case .error:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                case .upgradeRequired:
                    respond.onError?(Errors.upgradeRequired)
                }
            }
        }
    }

    public func canWhitelistTransactions() -> Promise<Bool> {
        return .init(transactionWhitelistingApi.isWhitelistingAvailable)
    }

    public func buildAndSignTransaction(sourceKinAccount: KinAccount,
                                        paymentItems: [KinPaymentItem],
                                        memo: KinMemo,
                                        fee: Quark) -> Promise<KinTransaction> {
        let promise = Promise<KinTransaction>(on: dispatchQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            let paymentOperations = paymentItems.compactMap { item -> PaymentOperation? in
                guard let dest = try? KeyPair(accountId: item.destAccountId),
                    let asset = Asset(type: AssetType.ASSET_TYPE_NATIVE) else {
                    return nil
                }

                return PaymentOperation(sourceAccount: sourceKinAccount.key,
                                        destination: dest,
                                        asset: asset,
                                        amount: item.amount)
            }

            do {
                let nonZeroFee = fee > 0 ? UInt32(fee) : Transaction.defaultOperationFee
                let transaction = try Transaction(sourceAccount: sourceKinAccount,
                                                  operations: paymentOperations,
                                                  memo: try Memo(text: memo.text),
                                                  timeBounds: nil,
                                                  maxOperationFee: nonZeroFee)

                try transaction.sign(keyPair: sourceKinAccount.key,
                                     network: self.network.stellarNetwork)

                fulfill(try transaction.toInFlightKinTransaction(network: self.network))
            } catch let error {
                reject(error)
            }
        }

        return promise
    }

    public func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = SubmitTransactionRequest(transactionEnvelopeXdr: Data(transaction.envelopeXdrBytes).base64EncodedString())
            self.transactionApi.submitTransaction(request: request) { response in
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

    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return transactionApi.streamNewTransactions(accountId: accountId)
    }
}
