//
//  KinEnvironmentTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
import Promises
@testable import KinBase

class KinEnvironmentTests: XCTestCase {
    override func setUp() {

    }

    func testHorizonTestNet() {
        let sut = KinEnvironment.Horizon.testNet()
        XCTAssertEqual(sut.network, KinNetwork.testNet)
    }

    func testHorizonMainNet() {
        let sut = KinEnvironment.Horizon.mainNet()
        XCTAssertEqual(sut.network, KinNetwork.mainNet)
    }

    func testAgoraTestNet() {
        let sut = KinEnvironment.Agora.testNet()
        XCTAssertEqual(sut.network, KinNetwork.testNet)
    }

    func testAgoraMainNet() {
        let sut = KinEnvironment.Agora.mainNet()
        XCTAssertEqual(sut.network, KinNetwork.mainNet)
    }

    func testImportKeyAndGetAllAccounts() {
        let sut = KinEnvironment.Horizon.testNet()
        _ = try! await(sut.storage.clearStorage())

        let key = try! KinAccount.Key(secretSeed: StubObjects.seed1)
        try! sut.importPrivateKey(key)

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
        let sut = KinEnvironment.Horizon.testNet()
        let key = try! KinAccount.Key(accountId: StubObjects.accountId1)
        XCTAssertThrowsError(try sut.importPrivateKey(key))
    }
}
