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
    func airdrop(request: AirdropRequest, completion: @escaping (AirdropResponse) -> Void)
    func airdrop(account: PublicKey, kin: Kin) -> Promise<AirdropResponse>
}

// MARK: - Request & Response
public struct AirdropRequest {
    public let account: PublicKey
    public let kin: Kin

    public init(account: PublicKey, kin: Kin) {
        self.account = account
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
