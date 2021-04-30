//
//  KinAccountCreationApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/// An API for the SDK to delegate `KinAccount` registration with the Kin Blockchain to developers.
public protocol KinAccountCreationApi {
    func createAccount(request: CreateAccountRequest,
                       completion: @escaping (CreateAccountResponse) -> Void)
}

// MARK: - Request & Response
public struct CreateAccountRequest {
    public let account: PublicKey

    public init(account: PublicKey) {
        self.account = account
    }
}

public struct CreateAccountResponse {
    public enum Result: Int {
        case upgradeRequired = -3
        case transientFailure = -2
        case undefinedError = -1
        case ok = 0
        case exists = 1
        case unavailable = 2
    }

    public let result: Result
    public let error: Error?
    public let account: KinAccount?

    public init(result: CreateAccountResponse.Result,
                error: Error?,
                account: KinAccount?) {
        self.result = result
        self.error = error
        self.account = account
    }
}


/// An API for the SDK to delegate `KinAccount` registration with the Kin Blockchain to developers.
public protocol KinAccountCreationApiV4 {
    func createAccount(request: CreateAccountRequestV4,
                       completion: @escaping (CreateAccountResponseV4) -> Void)
}

// MARK: - Request & Response
public struct CreateAccountRequestV4 {
    public let transaction: Transaction

    public init(transaction: Transaction) {
        self.transaction = transaction
    }
}

public struct CreateAccountResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case transientFailure = -2
        case undefinedError = -1
        case ok = 0
        case exists = 1
        case payerRequired = 2
    }

    public let result: Result
    public let error: Error?
    public let account: KinAccount?

    public init(result: CreateAccountResponseV4.Result,
                error: Error?,
                account: KinAccount?) {
        self.result = result
        self.error = error
        self.account = account
    }
}
