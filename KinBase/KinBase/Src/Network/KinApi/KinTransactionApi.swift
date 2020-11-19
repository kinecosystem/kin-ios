//
//  KinTransactionApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol KinTransactionApi {
    func getTransactionHistory(request: GetTransactionHistoryRequest,
                               completion: @escaping (GetTransactionHistoryResponse) -> Void)

    func getTransaction(request: GetTransactionRequest,
                        completion: @escaping (GetTransactionResponse) -> Void)

    func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponse) -> Void)

    func submitTransaction(request: SubmitTransactionRequest,
                           completion: @escaping (SubmitTransactionResponse) -> Void)
}

// MARK: - Request & Response
public struct GetTransactionHistoryRequest {
    public let accountId: KinAccount.Id
    public let cursor: String?
    public let order: TransactionOrder

    public init(accountId: KinAccount.Id, cursor: String?, order: TransactionOrder) {
        self.accountId = accountId
        self.cursor = cursor
        self.order = order
    }
}

public struct GetTransactionHistoryResponse {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let kinTransactions: [KinTransaction]?

    public init(result: GetTransactionHistoryResponse.Result, error: Error?, kinTransactions: [KinTransaction]?) {
        self.result = result
        self.error = error
        self.kinTransactions = kinTransactions
    }
}

public struct GetTransactionRequest {
    public let transactionHash: KinTransactionHash

    public init(transactionHash: KinTransactionHash) {
        self.transactionHash = transactionHash
    }
}

public struct GetTransactionResponse {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?

    public init(result: GetTransactionResponse.Result, error: Error?, kinTransaction: KinTransaction?) {
        self.result = result
        self.error = error
        self.kinTransaction = kinTransaction
    }
}

public struct GetMinFeeForTransactionResponse {
    public enum Result: Int {
        case upgradeRequired = -3
        case ok = 0
        case error = 1
    }

    public let result: Result
    public let error: Error?
    public let fee: Quark?

    public init(result: GetMinFeeForTransactionResponse.Result, error: Error?, fee: Quark?) {
        self.result = result
        self.error = error
        self.fee = fee
    }
}

public struct SubmitTransactionRequest {
    public let transactionEnvelopeXdr: String
    public let invoiceList: InvoiceList?

    public init(transactionEnvelopeXdr: String,
                invoiceList: InvoiceList? = nil) {
        self.transactionEnvelopeXdr = transactionEnvelopeXdr
        self.invoiceList = invoiceList
    }
}

public struct SubmitTransactionResponse {
    internal init(result: SubmitTransactionResponse.Result, error: Error?, kinTransaction: KinTransaction?) {
        self.result = result
        self.error = error
        self.kinTransaction = kinTransaction
    }

    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case insufficientBalance = 1
        case insufficientFee = 2
        case badSequenceNumber = 3
        case noAccount = 4
        case webhookRejected = 5
        case invoiceError = 6
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?
}

public struct GetMinimumKinVersionRequestV4 {
    
}

public struct GetMinimumKinVersionResponseV4 {
    
    internal init(result: GetMinimumKinVersionResponseV4.Result, error: Error?, version: Int) {
        self.result = result
        self.error = error
        self.version = version
    }
    
    public enum Result: Int {
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
    }

    public let result: Result
    public let error: Error?
    public let version: Int
}

public protocol KinTransactionApiV4 {
    
    func getMinKinVersion(request: GetMinimumKinVersionRequestV4,
                          completion: @escaping (GetMinimumKinVersionResponseV4) -> Void)
    
    func getServiceConfig(request: GetServiceConfigRequestV4,
                          completion: @escaping (GetServiceConfigResponseV4) -> Void)
    
    func getRecentBlockHash(request: GetRecentBlockHashRequestV4,
                            completion: @escaping (GetRecentBlockHashResonseV4) -> Void)
    
    func getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4,
                                           completion: @escaping (GetMinimumBalanceForRentExemptionResponseV4) -> Void)
    
    func getTransactionHistory(request: GetTransactionHistoryRequestV4,
                               completion: @escaping (GetTransactionHistoryResponseV4) -> Void)

    func getTransaction(request: GetTransactionRequestV4,
                        completion: @escaping (GetTransactionResponseV4) -> Void)

    func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponseV4) -> Void)

    func submitTransaction(request: SubmitTransactionRequestV4,
                           completion: @escaping (SubmitTransactionResponseV4) -> Void)
}

// MARK: - Request & Response

/**
* subsidizerAccount  The public key of the account that the service will use to sign transactions for funding.
*                                If not specified, the service is _not_ configured to fund transactions.
*/

public struct GetServiceConfigRequestV4 { }

public struct GetServiceConfigResponseV4 {
    public let result: Result
    public let subsidizerAccount: SolanaPublicKey?
    
     /** TODO: remove these two after we've locked in some tokens **/
    public let tokenProgram: SolanaPublicKey?
    public let token: SolanaPublicKey?
    
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
    }
}

public struct GetRecentBlockHashRequestV4 { }

public struct GetRecentBlockHashResonseV4 {
    public let result: Result
    public let blockHash: Hash?
    
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
    }
}

public struct GetMinimumBalanceForRentExemptionRequestV4 {
    public let size: UInt64
    
    init(size: UInt64) {
        self.size = size
    }
}

public struct GetMinimumBalanceForRentExemptionResponseV4 {
    public let result: Result
    public let lamports: UInt64
    
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
    }
}

public struct GetTransactionHistoryRequestV4 {
    public let accountId: KinAccount.Id
    public let cursor: String?
    public let order: TransactionOrder

    public init(accountId: KinAccount.Id, cursor: String?, order: TransactionOrder) {
        self.accountId = accountId
        self.cursor = cursor
        self.order = order
    }
}

public struct GetTransactionHistoryResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let kinTransactions: [KinTransaction]?

    public init(result: GetTransactionHistoryResponseV4.Result, error: Error?, kinTransactions: [KinTransaction]?) {
        self.result = result
        self.error = error
        self.kinTransactions = kinTransactions
    }
}

public struct GetTransactionRequestV4 {
    public let transactionHash: KinTransactionHash

    public init(transactionHash: KinTransactionHash) {
        self.transactionHash = transactionHash
    }
}

public struct GetTransactionResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?

    public init(result: GetTransactionResponseV4.Result, error: Error?, kinTransaction: KinTransaction?) {
        self.result = result
        self.error = error
        self.kinTransaction = kinTransaction
    }
}

public struct GetMinFeeForTransactionResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case ok = 0
        case error = 1
    }

    public let result: Result
    public let error: Error?
    public let fee: Quark?

    public init(result: GetMinFeeForTransactionResponseV4.Result, error: Error?, fee: Quark?) {
        self.result = result
        self.error = error
        self.fee = fee
    }
}

public struct SubmitTransactionRequestV4 {
    public let transaction: SolanaTransaction
    public let invoiceList: InvoiceList?

    public init(transaction: SolanaTransaction,
                invoiceList: InvoiceList? = nil) {
        self.transaction = transaction
        self.invoiceList = invoiceList
    }
}

public struct SubmitTransactionResponseV4 {
    internal init(result: SubmitTransactionResponseV4.Result, error: Error?, kinTransaction: KinTransaction?) {
        self.result = result
        self.error = error
        self.kinTransaction = kinTransaction
    }

    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case insufficientBalance = 1
        case insufficientFee = 2
        case badSequenceNumber = 3
        case noAccount = 4
        case webhookRejected = 5
        case invoiceError = 6
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?
}
