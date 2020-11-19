//
//  KinAccountApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol KinAccountApi {
    func getAccount(request: GetAccountRequest,
                    completion: @escaping (GetAccountResponse) -> Void)
}

// MARK: - Request & Response
public struct GetAccountRequest {
    public let accountId: KinAccount.Id

    public init(accountId: KinAccount.Id) {
        self.accountId = accountId
    }
}

public struct GetAccountResponse {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let account: KinAccount?

    public init(result: GetAccountResponse.Result, error: Error?, account: KinAccount?) {
        self.result = result
        self.error = error
        self.account = account
    }
}

public protocol KinAccountApiV4 {
    func getAccount(request: GetAccountRequestV4,
                    completion: @escaping (GetAccountResponseV4) -> Void)
    func resolveTokenAccounts(request: ResolveTokenAccountsRequestV4,
                              completion: @escaping (ResolveTokenAccountsResponseV4) -> Void)
}

// MARK: - Request & Response V4
public struct GetAccountRequestV4 {
    public let accountId: KinAccount.Id

    public init(accountId: KinAccount.Id) {
        self.accountId = accountId
    }
}

public struct GetAccountResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let account: KinAccount?

    public init(result: GetAccountResponseV4.Result, error: Error?, account: KinAccount?) {
        self.result = result
        self.error = error
        self.account = account
    }
}

public struct ResolveTokenAccountsRequestV4 {
    public let accountId: KinAccount.Id
}

public struct ResolveTokenAccountsResponseV4 {
    public enum Result: Int {
        case upgradeRequired = -3
        case undefinedError = -2
        case transientFailure = -1
        case ok = 0
        case notFound = 1
    }

    public let result: Result
    public let error: Error?
    public let accounts: [SolanaPublicKey]?

    public init(result: ResolveTokenAccountsResponseV4.Result, error: Error?, accounts: [SolanaPublicKey]?) {
        self.result = result
        self.error = error
        self.accounts = accounts
    }
}

