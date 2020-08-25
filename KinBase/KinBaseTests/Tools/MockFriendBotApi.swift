//
//  MockFriendBotApi.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
@testable import KinBase

class MockFriendBotApi: FriendBotApi {
    var stubFundAccountResponse: CreateAccountResponse!

    override func fundAccount(request: CreateAccountRequest, completion: @escaping (CreateAccountResponse) -> Void) {
        completion(stubFundAccountResponse)
    }
}
