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

    func streamAccount(_ accountId: KinAccount.Id) -> Observable<KinAccount>
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
        case ok = 0
        case error = 1
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
