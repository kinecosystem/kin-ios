//
//  DefaultHorizonKinAccountCreationApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class DefaultHorizonKinAccountCreationApiTests: XCTestCase {

    var sut: DefaultHorizonKinAccountCreationApi!

    override func setUp() {
        sut = DefaultHorizonKinAccountCreationApi()
    }

    func testCreateAccountUnavailable() {
        let request = CreateAccountRequest(accountId: "id")
        sut.createAccount(request: request) { response in
            XCTAssertEqual(response.result, CreateAccountResponse.Result.unavailable)
            XCTAssertNil(response.account)
            XCTAssertNil(response.error)
        }
    }
}
