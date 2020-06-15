//
//  DefaultHorizonKinTransactionWhitelistingApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class DefaultHorizonKinTransactionWhitelistingApiTests: XCTestCase {

    var sut: KinTransactionWhitelistingApi!

    override func setUp() {
        sut = DefaultHorizonKinTransactionWhitelistingApi()
    }

    func testWhitelistingAvailableFalse() {
        XCTAssertFalse(sut.isWhitelistingAvailable)
    }

    func testWhitelistTransaction() {
        let request = WhitelistTransactionRequest(transactionEnvelope: "envelope")
        sut.whitelistTransaction(request: request) { response in
            XCTAssertEqual(response.result, .ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.whitelistedTransactionEnvelope, request.transactionEnvelope)
        }
    }
}
