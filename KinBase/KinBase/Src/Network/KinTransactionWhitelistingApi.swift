//
//  KinTransactionWhitelistingApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/// An API for the SDK to delegate transaction whitelisting with the Kin Blockchain to developers.
public protocol KinTransactionWhitelistingApi {
    var isWhitelistingAvailable: Bool { get }

    func whitelistTransaction(request: WhitelistTransactionRequest,
                              completion: @escaping (WhitelistTransactionResponse) -> Void)
}

// MARK: - Request & Response
public struct WhitelistTransactionRequest {
    public let  transactionEnvelope: String    // base64 encoded

    public init(transactionEnvelope: String) {
        self.transactionEnvelope = transactionEnvelope
    }
}

public struct WhitelistTransactionResponse {
    public enum Result: Equatable {
        case ok
        case error
    }

    public let result: Result
    public let error: Error?
    public let whitelistedTransactionEnvelope: String?   // base64 encoded

    public init(result: WhitelistTransactionResponse.Result, error: Error?, whitelistedTransactionEnvelope: String?) {
        self.result = result
        self.error = error
        self.whitelistedTransactionEnvelope = whitelistedTransactionEnvelope
    }
}


