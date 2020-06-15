//
//  KinEnvironmentTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class KinEnvironmentTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testTestNet() {
        let sut = KinEnvironment.testNet()
        XCTAssertEqual(sut.network, KinNetwork.testNet)
    }

    func testMainNet() {
        let sut = KinEnvironment.mainNet()
        XCTAssertEqual(sut.network, KinNetwork.mainNet)
    }

    func testImportKeyAndGetAllAccounts() {
        let sut = KinEnvironment.testNet()
        let key = try! KinAccount.Key(secretSeed: StubObjects.seed1)
        _ = try! sut.importPrivateKey(key)

        let expect = expectation(description: "completion")
        sut.allAccountIds().then { ids in
            XCTAssertEqual(ids.count, 1)
            XCTAssertEqual(ids.first!, key.accountId)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)

        let expectClear = expectation(description: "clear")
        sut.storage.clearStorage().then {
            expectClear.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testImportPrivateKeyMissingKey() {
        let sut = KinEnvironment.testNet()
        let key = try! KinAccount.Key(accountId: StubObjects.accountId1)
        XCTAssertThrowsError(try sut.importPrivateKey(key))
    }
}
