//
//  KinTestServiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class KinTestServiceTests: XCTestCase {
    var mockFriendBotApi: MockFriendBotApi!
    var sut: KinTestService!

    override func setUp() {
        mockFriendBotApi = MockFriendBotApi()
        sut = KinTestService(friendBotApi: mockFriendBotApi,
                             networkOperationHandler: NetworkOperationHandler())
    }

    func testFundAccountOk() {
        mockFriendBotApi.stubFundAccountResponse = CreateAccountResponse(result: .ok,
                                                                         error: nil,
                                                                         account: nil)
        let expect = expectation(description: "callback")
        sut.fundAccount(StubObjects.accountId1)
            .then {
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testFundAccountError() {
        mockFriendBotApi.stubFundAccountResponse = CreateAccountResponse(result: .transientFailure,
                                                                         error: nil,
                                                                         account: nil)
        let expect = expectation(description: "callback")
        sut.fundAccount(StubObjects.accountId1)
            .catch { _ in
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }
}
