//
//  DefaultHorizonKinAccountCreationApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public class DefaultHorizonKinAccountCreationApi: KinAccountCreationApi {

    public init() {}

    /**
    * Developers are expected to call their back-end's to register
    * this address with the main-net Kin Blockchain
    */
    public func createAccount(request: CreateAccountRequest,
                              completion: @escaping (CreateAccountResponse) -> Void) {
        let response = CreateAccountResponse(result: .unavailable,
                                             error: nil,
                                             account: nil)
        completion(response)
    }
}
