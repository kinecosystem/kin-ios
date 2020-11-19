//
//  KinAirdropApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public protocol KinAirdropApi {
    func airdrop(request: AirdropRequest,
                 completion: @escaping (AirdropResponse) -> Void)
    
    func airdrop(accountId: KinAccount.Id, kin: Kin) -> Promise<AirdropResponse>
}

// MARK: - Request & Response
public struct AirdropRequest {
    public let accountId: KinAccount.Id
    public let kin: Kin

    public init(accountId: KinAccount.Id, kin: Kin) {
        self.accountId = accountId
        self.kin = kin
    }
}

public struct AirdropResponse {
    public enum Result: Int {
        case ok = 0
        case failed = 1
        case transientFailure = 2
    }

    public let result: Result

    public init(result: AirdropResponse.Result) {
        self.result = result
    }
}
