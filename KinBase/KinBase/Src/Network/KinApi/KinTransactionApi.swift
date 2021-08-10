//
//  KinTransactionApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

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

    func signTransaction(request: SignTransactionRequestV4,
                         completion: @escaping (SignTransactionResponseV4) -> Void)

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
    public let subsidizerAccount: PublicKey?
    
     /** TODO: remove these two after we've locked in some tokens **/
    public let tokenProgram: PublicKey?
    public let token: PublicKey?
    
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
    public let account: PublicKey
    public let cursor: String?
    public let order: TransactionOrder

    public init(account: PublicKey, cursor: String?, order: TransactionOrder) {
        self.account = account
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

public struct SignTransactionRequestV4 {
    public let transaction: Transaction
    public let invoiceList: InvoiceList?

    public init(transaction: Transaction,
                invoiceList: InvoiceList? = nil) {
        self.transaction = transaction
        self.invoiceList = invoiceList
    }
}

public struct SignTransactionResponseV4 {
    internal init(result: SignTransactionResponseV4.Result, error: Error?, kinTransaction: KinTransaction?) {
        self.result = result
        self.error = error
        self.kinTransaction = kinTransaction
    }

    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case webhookRejected = 1
        case invoiceError = 2
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?
}

public struct SubmitTransactionRequestV4 {
    public let transaction: Transaction
    public let invoiceList: InvoiceList?

    public init(transaction: Transaction,
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
