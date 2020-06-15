//
//  DefaultHorizonKinTransactionWhitelistingApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public class DefaultHorizonKinTransactionWhitelistingApi: KinTransactionWhitelistingApi {
    public var isWhitelistingAvailable: Bool = false

    public init() {}

    /**
     Developers are expected to call their back-end's to whitelist a transaction.
     We just return the original transaction since this implementation does not support whitelisting.
     */
    public func whitelistTransaction(request: WhitelistTransactionRequest, completion: @escaping (WhitelistTransactionResponse) -> Void) {
        let response = WhitelistTransactionResponse(result: .ok,
                                                    error: nil,
                                                    whitelistedTransactionEnvelope: request.transactionEnvelope)
        completion(response)
    }
}
