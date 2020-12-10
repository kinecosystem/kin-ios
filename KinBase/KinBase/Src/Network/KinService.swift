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
    func createAccount(accountId: KinAccount.Id, signer: KeyPair) -> Promise<KinAccount>

    func getAccount(accountId: KinAccount.Id) -> Promise<KinAccount>
    
    func resolveTokenAccounts(accountId: KinAccount.Id) -> Promise<[KinAccount.Key]>

    func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount>

    func getLatestTransactions(accountId: KinAccount.Id) -> Promise<[KinTransaction]>

    func getTransactionPage(accountId: KinAccount.Id,
                            pagingToken: String,
                            order: TransactionOrder) -> Promise<[KinTransaction]>

    func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction>

    func getMinFee() -> Promise<Quark>

    func canWhitelistTransactions() -> Promise<Bool>

    func buildAndSignTransaction(ownerKey: KinAccount.Key,
                                 sourceKey: KinAccount.Key,
                                 nonce: Int64,
                                 paymentItems: [KinPaymentItem],
                                 memo: KinMemo,
                                 fee: Quark) -> Promise<KinTransaction>

    func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction>
    
    func buildSignAndSubmitTransaction(
        buildAndSignTransaction: @escaping () -> Promise<KinTransaction>
    ) -> Promise<KinTransaction>

    func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction>
    
    func invalidateRecentBlockHashCache()
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
        log.debug(msg:"[Request][V3]====\n\(request)\n=====[Request][V3]")
    }
    
    private func responsePrint<ResponseType : Any>(response: ResponseType) {
        log.debug(msg:"[Response][V3]====\n\(response)\n=====[Response][V3]")
    }
}

extension KinService: KinServiceType {
    
    public func createAccount(accountId: KinAccount.Id, signer: KeyPair) -> Promise<KinAccount> {
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
                case .undefinedError:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
    
    public func resolveTokenAccounts(accountId: KinAccount.Id) -> Promise<[KinAccount.Key]> {
        return Promise { resolve, _ in resolve([KinAccount.Key]()) }
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
                case .undefinedError:
                    respond.onError?(Errors.unknown)
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
                case .undefinedError:
                    respond.onError?(Errors.unknown)
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

    public func buildAndSignTransaction(ownerKey: KinAccount.Key,
                                        sourceKey: KinAccount.Key,
                                        nonce: Int64,
                                        paymentItems: [KinPaymentItem],
                                        memo: KinMemo,
                                        fee: Quark) -> Promise<KinTransaction> {
        let promise = Promise<KinTransaction>(on: dispatchQueue) { [weak self] fulfill, reject in
            guard let self = self else {
                reject(Errors.unknown)
                return
            }

            let isKin2 = self.network.isKin2
            let issuer = self.network.issuer
            let paymentOperations = paymentItems.compactMap { item -> PaymentOperation? in
                guard let dest = try? KeyPair(accountId: item.destAccountId) else {
                    return nil
                }
                
                if isKin2 {
                    let asset = Asset(
                        type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4,
                        code: "KIN",
                        issuer: issuer
                    )!
                    return PaymentOperation(sourceAccount: sourceKey,
                                            destination: dest,
                                            asset: asset,
                                            amount: item.amount * 100)
                } else {
                    guard let asset = Asset(type: AssetType.ASSET_TYPE_NATIVE) else {
                        return nil
                    }
                    
                    return PaymentOperation(sourceAccount: sourceKey,
                                            destination: dest,
                                            asset: asset,
                                            amount: item.amount)
                }
            }

            do {
                let nonZeroFee: UInt32
                if isKin2 {
                    // Kin 2 will always pay fee of 100 quarks,
                    // inflated by 100 because of decimal scaling,
                    // times the number of payment operations
                    // and in the base currency: XLM
                    nonZeroFee = Transaction.defaultOperationFee * 100
                } else {
                    nonZeroFee = fee > 0 ? UInt32(fee) : Transaction.defaultOperationFee
                }
                
                let transaction = try Transaction(sourceAccount: KinAccount(key: ownerKey, status: .registered, sequence: nonce),
                                                  operations: paymentOperations,
                                                  memo: memo.stellarMemo ?? Memo.none,
                                                  timeBounds: nil,
                                                  maxOperationFee: nonZeroFee)

                try transaction.sign(keyPair: ownerKey,
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
    
    public func buildSignAndSubmitTransaction(buildAndSignTransaction: () -> Promise<KinTransaction>) -> Promise<KinTransaction> {
        return buildAndSignTransaction().then { it in self.submitTransaction(transaction: it) }
    }
    
    public func invalidateRecentBlockHashCache() {
        // no-op
    }

    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return streamingApi.streamNewTransactions(accountId: accountId).subscribe { [weak self] (transaction) in
            self?.log.debug(msg:"streamNewTransactions::Update \(transaction)")
        }
    }
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
//        warmCache()
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
                        var error = KinService.Errors.unknown
                        if let transientError = response.error {
                            error = KinService.Errors.transientFailure(error: transientError)
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

public class KinServiceWrapper {
    private var delegate: KinServiceType
    private let kinServiceV3 : KinServiceType
    private let kinServiceV4 : KinServiceType
    public let metaServiceApi: MetaServiceType
    
    init(kinServiceV3: KinServiceType, kinServiceV4: KinServiceType, metaServiceApi: MetaServiceType) {
        self.delegate = kinServiceV3
        self.kinServiceV3 = kinServiceV3
        self.kinServiceV4 = kinServiceV4
        self.metaServiceApi = metaServiceApi
    }
}

extension KinServiceWrapper : KinServiceType {
    
    public func createAccount(accountId: KinAccount.Id, signer: KeyPair) -> Promise<KinAccount> {
        return checkAndMaybeUpgradeApi {
            self.delegate.createAccount(accountId: accountId, signer: signer)
        }
    }
    
    public func getAccount(accountId: KinAccount.Id) -> Promise<KinAccount> {
        return checkAndMaybeUpgradeApi {
            self.delegate.getAccount(accountId: accountId)
        }
    }
    
    public func resolveTokenAccounts(accountId: KinAccount.Id) -> Promise<[KinAccount.Key]> {
        return checkAndMaybeUpgradeApi {
            self.delegate.resolveTokenAccounts(accountId: accountId)
        }
    }
    
    public func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount> {
        return checkAndMaybeUpgradeApi {
            delegate.streamAccount(accountId: accountId)
        }
    }
    
    public func getLatestTransactions(accountId: KinAccount.Id) -> Promise<[KinTransaction]> {
        return checkAndMaybeUpgradeApi {
            self.delegate.getLatestTransactions(accountId: accountId)
        }
    }
    
    public func getTransactionPage(accountId: KinAccount.Id, pagingToken: String, order: TransactionOrder) -> Promise<[KinTransaction]> {
        return checkAndMaybeUpgradeApi {
            self.delegate.getTransactionPage(accountId: accountId, pagingToken: pagingToken, order: order)
        }
    }
    
    public func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction> {
        return checkAndMaybeUpgradeApi {
            self.delegate.getTransaction(transactionHash: transactionHash)
        }
    }
    
    public func getMinFee() -> Promise<Quark> {
        return checkAndMaybeUpgradeApi {
            self.delegate.getMinFee()
        }
    }
    
    public func canWhitelistTransactions() -> Promise<Bool> {
        return checkAndMaybeUpgradeApi {
            self.delegate.canWhitelistTransactions()
        }
    }
    
    public func buildAndSignTransaction(ownerKey: KinAccount.Key, sourceKey: KinAccount.Key, nonce: Int64, paymentItems: [KinPaymentItem], memo: KinMemo, fee: Quark) -> Promise<KinTransaction> {
        return checkAndMaybeUpgradeApi {
            self.delegate.buildAndSignTransaction(ownerKey: ownerKey, sourceKey: sourceKey, nonce: nonce, paymentItems: paymentItems, memo: memo, fee: fee)
        }
    }
    
    public func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction> {
        return checkAndMaybeUpgradeApi {
            self.delegate.submitTransaction(transaction: transaction)
        }
    }
    
    public func buildSignAndSubmitTransaction(buildAndSignTransaction: @escaping () -> Promise<KinTransaction>) -> Promise<KinTransaction> {
         return checkAndMaybeUpgradeApi {
            self.delegate.buildSignAndSubmitTransaction(buildAndSignTransaction: buildAndSignTransaction)
        }
    }
    
    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return checkAndMaybeUpgradeApi {
            delegate.streamNewTransactions(accountId: accountId)
        }
    }
    
    public func invalidateRecentBlockHashCache() {
        return delegate.invalidateRecentBlockHashCache()
    }
    
    // Utils

    private func delegateCheck(_ version: Int) {
        if (version == 3) {
            delegate = kinServiceV3
        } else {
            delegate = kinServiceV4
        }
    }
    
    private func checkAndMaybeUpgradeApi<T>(execute: @escaping () -> Promise<T>) -> Promise<T> {
        delegateCheck(metaServiceApi.configuredMinApi)
        return execute().recover { error -> Promise<T> in
            guard let kinServiceError: KinService.Errors = error as? KinService.Errors, kinServiceError == .upgradeRequired else {
                return Promise(error)
            }
            return self.metaServiceApi.getMinApiVersion().then { minVersion in
                self.delegateCheck(minVersion)
                return execute()
            }
        }
    }
    
    private func checkAndMaybeUpgradeApi<T>(execute: () -> Observable<T>) -> Observable<T> {
        delegateCheck(metaServiceApi.configuredMinApi)
        return execute()
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
    
    public func createAccount(accountId: KinAccount.Id, signer: KeyPair) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self, let signerPrivateKey = signer.privateKey else {
                respond.onError?(Errors.unknown)
                return
            }
            
            all(self.cachedServiceConfig(), self.cachedRecentBlockHash(), self.cachedMinRentExemption()).then { (serviceConfig, recentBlockHash, minRentExemption) in
                guard (serviceConfig.result == GetServiceConfigResponseV4.Result.ok
                        || recentBlockHash.result == GetRecentBlockHashResonseV4.Result.ok
                        || minRentExemption.result == GetMinimumBalanceForRentExemptionResponseV4.Result.ok
                ) else {
                    respond.onError?(Errors.unknown)
                   return
                }
                
                let tokenAccountSeed = try Seed(bytes: [Byte](sha256(data: Data(signerPrivateKey.bytes))))
                let tokenAccount = KeyPair(seed: tokenAccountSeed)
                let tokenAccountPub: SolanaPublicKey = tokenAccount.asPublicKey()
                
                
                let subsidizer: SolanaPublicKey = serviceConfig.subsidizerAccount!
                let owner: SolanaPublicKey = signer.asPublicKey()
                let programKey = serviceConfig.tokenProgram!
                let mint = serviceConfig.token!
                
                let transaction = try! SolanaTransaction.newTransaction(
                    subsidizer,
                    SystemProgram.createAccountInstruction(
                        subsidizer: subsidizer,
                        address: tokenAccountPub,
                        owner: programKey,
                        lamports: minRentExemption.lamports,
                        size: TokenProgram.accountSize),
                    TokenProgram.initializeAccountInstruction(
                        account: tokenAccountPub,
                        mint: mint,
                        owner: owner,
                        programKey: programKey
                    ),
                    TokenProgram.setAuthority(
                        account: tokenAccountPub,
                        currentAuthority: owner,
                        newAuthority: subsidizer,
                        authorityType: TokenProgram.AuthorityType.AuthorityCloseAccount,
                        programKey: programKey
                    )
                ).copyAndSetRecentBlockhash(recentBlockhash: recentBlockHash.blockHash!)
                    .copyAndSign(signers: tokenAccount, signer)

                print(transaction.encode().hexEncodedString())
                
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
            }.catch { error in respond.onError?(error) }
        }
    }
    
    public func getAccount(accountId: KinAccount.Id) -> Promise<KinAccount> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetAccountRequestV4(accountId: accountId)
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
    
    public func resolveTokenAccounts(accountId: KinAccount.Id) -> Promise<[KinAccount.Key]> {
        let cacheKey = "resolvedAccounts:\(accountId)"
        let resolve: Promise<[KinAccount.Key]> = cache.resolve(key: cacheKey) { _ in
            self.networkOperationHandler.queueWork { [weak self] respond in
                guard let self = self else {
                    respond.onError?(Errors.unknown)
                    return
                }
                
                let request = ResolveTokenAccountsRequestV4(accountId: accountId)
                self.requestPrint(request: request)
                self.accountApi.resolveTokenAccounts(request: request) { [weak self] response in
                    self?.responsePrint(response:response)
                    switch response.result {
                    case .ok:
                        if let accounts = response.accounts?.map({ (it) -> KeyPair in it.keypair }) {
                            respond.onSuccess(accounts)
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
        
        return resolve.then { it -> Promise<[KinAccount.Key]> in
            if (it.isEmpty) {
                self.cache.invalidate(key: cacheKey)
                return resolve
            } else {
                return Promise { it }
            }
        }
    }
    
    public func streamAccount(accountId: KinAccount.Id) -> Observable<KinAccount> {
        return streamingApi.streamAccountV4(accountId).subscribe { [weak self] (account) in
            self?.log.debug(msg:"streamAccount::Update \(account)")
        }
    }
    
    public func getLatestTransactions(accountId: KinAccount.Id) -> Promise<[KinTransaction]> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            let request = GetTransactionHistoryRequestV4(accountId: accountId,
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
                case .undefinedError:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
    
    public func getTransactionPage(accountId: KinAccount.Id, pagingToken: String, order: TransactionOrder) -> Promise<[KinTransaction]> {
         return networkOperationHandler.queueWork { [weak self] respond in
                   guard let self = self else {
                       respond.onError?(Errors.unknown)
                       return
                   }

                   let request = GetTransactionHistoryRequestV4(accountId: accountId,
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
    
    public func buildAndSignTransaction(ownerKey: KinAccount.Key, sourceKey: KinAccount.Key, nonce: Int64, paymentItems: [KinPaymentItem], memo: KinMemo, fee: Quark) -> Promise<KinTransaction> {
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
                let subsidizer: SolanaPublicKey = serviceConfig.subsidizerAccount!
                let owner: SolanaPublicKey = signer.asPublicKey()
                let programKey = serviceConfig.tokenProgram!
                self.log.debug(msg: "ownerKey: \(ownerKey)")
                self.log.debug(msg: "sourceKey: \(sourceKey)")
                self.log.debug(msg: "paymentItems: \(paymentItems)")
                
                if (signer.seed == nil) {
                    respond.onError?(KinServiceV4.Errors.invalidAccount)
                }
                
                var instructions = paymentItems.map { it in
                    TokenProgram.transferInstruction(source: sourceKey.asPublicKey(),
                                                     destination: it.destAccountId.asPublicKey(),
                                                     owner: owner,
                                                     amount: it.amount,
                                                     programKey: programKey)
                }
                
                if (memo != .none) {
                        switch memo.type {
                        case .bytes:
                            if (memo.agoraMemo != nil) {
                                instructions.insert(MemoProgram.memoInsutructionFromBytes(bytes: memo.agoraMemo!.encode().base64EncodedString().bytes), at: 0)
                                break
                            }
                        case .text:
                            instructions.insert(MemoProgram.memoInsutructionFromBytes(bytes: memo.rawValue), at: 0)
                            break
                        }
                }
                
                let transaction = try! SolanaTransaction.newTransaction(
                        subsidizer,
                        instructions
                    ).copyAndSetRecentBlockhash(recentBlockhash: recentBlockHash.blockHash!)
                        .copyAndSign(signers: signer)
                
                print(transaction.encode().hexEncodedString())
                
                let kinTransaction = try! KinTransaction(
                        envelopeXdrBytes: [Byte](transaction.encode()),
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

            let request = SubmitTransactionRequestV4(transaction: SolanaTransaction(data: Data(transaction.envelopeXdrBytes))!,
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
    
    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return streamingApi.streamNewTransactionsV4(accountId: accountId).subscribe { [weak self] (transaction) in
            self?.log.debug(msg:"streamNewTransactions::Update \(transaction)")
        }
    }
}
