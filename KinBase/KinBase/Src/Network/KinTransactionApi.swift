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

    func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction>
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
        case ok = 0
        case error = 1
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
        case ok = 0
        case error = 1
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

    public init(transactionEnvelopeXdr: String) {
        self.transactionEnvelopeXdr = transactionEnvelopeXdr
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
    }

    public let result: Result
    public let error: Error?
    public let kinTransaction: KinTransaction?
}
