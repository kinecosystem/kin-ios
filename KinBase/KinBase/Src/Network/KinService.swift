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
        case itemNotFound
        case insufficientFee
        case badSequenceNumber
        case webhookRejectedTransaction
        case invoiceErrorsInRequest(errors: [InvoiceError])

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

    private let accountApi: KinAccountApi
    private let accountCreationApi: KinAccountCreationApi
    private let transactionApi: KinTransactionApi
    private let transactionWhitelistingApi: KinTransactionWhitelistingApi
    private let streamingApi: KinStreamingApi
    private let logger: KinLoggerFactory
    private lazy var log: KinLogger = {
        logger.getLogger(name: String(describing: self))
    }()
    
    public init(network: KinNetwork,
                networkOperationHandler: NetworkOperationHandler,
                dispatchQueue: DispatchQueue,
                accountApi: KinAccountApi,
                accountCreationApi: KinAccountCreationApi,
                transactionApi: KinTransactionApi,
                transactionWhitelistingApi: KinTransactionWhitelistingApi,
                streamingApi: KinStreamingApi,
                logger: KinLoggerFactory) {
        self.network = network
        self.networkOperationHandler = networkOperationHandler
        self.dispatchQueue = dispatchQueue
        self.accountApi = accountApi
        self.accountCreationApi = accountCreationApi
        self.transactionApi = transactionApi
        self.transactionWhitelistingApi = transactionWhitelistingApi
        self.streamingApi = streamingApi
        self.logger = logger
    }
    
    private func requestPrint<RequestType : Any>(request: RequestType) {
        log.debug(msg:"[Request]:\(request)")
    }
    
    private func responsePrint<ResponseType : Any>(response: ResponseType) {
        log.debug(msg:"[Response]:\(response)")
    }
}

extension KinService: KinServiceType {
    public func createAccount(accountId: KinAccount.Id) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = CreateAccountRequest(accountId: accountId)
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
                case .unavailable:
                    respond.onError?(Errors.missingApi)
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

            let request = GetAccountRequest(accountId: accountId)
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
                }
            }
        }
    }

    public func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount> {
        return streamingApi.streamAccount(accountId).subscribe { [weak self] (account) in
            self?.log.debug(msg:"streamAccount::Update \(account)")
        }
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

            self.transactionApi.getTransactionMinFee { [weak self] response in
                self?.responsePrint(response:response)
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
                                                  memo: memo.stellarMemo ?? Memo.none,
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

            let request = SubmitTransactionRequest(transactionEnvelopeXdr: transaction.envelopeXdrString,
                                                   invoiceList: transaction.invoiceList)
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
                    respond.onError?(Errors.itemNotFound)
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

    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return streamingApi.streamNewTransactions(accountId: accountId).subscribe { [weak self] (transaction) in
            self?.log.debug(msg:"streamNewTransactions::Update \(transaction)")
        }
    }
}
