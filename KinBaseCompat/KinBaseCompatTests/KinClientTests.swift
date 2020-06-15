//
//  KinTestHostTests.swift
//  KinTestHostTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class KinClientTests: XCTestCase {
    var kinClient: KinClient!
    override func setUp() {
        super.setUp()

        guard let appId = try? AppId("test") else {
            XCTAssertTrue(false, "Unable to create app id")
            return
        }

        kinClient = KinClient(with: URL(string: "http://localhost:8000")!, network: .testNet, appId: appId)

    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func test_account_creation() {
        var e: Error? = nil
        var account: KinAccount? = nil

        XCTAssertNil(account, "There should not be an existing account!")

        do {
            account = try kinClient.addAccount()
        }
        catch {
            e = error
        }

        XCTAssertNotNil(account, "Creation failed: \(String(describing: e))")
    }

    func test_delete_account() {
        do {
            let account = try kinClient.addAccount()

            try kinClient.deleteAccount(at: 0)

            XCTAssertNotNil(account)
            XCTAssertNil(kinClient.accounts[0])
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_account_instance_reuse() {
        do {
            let _ = try kinClient.addAccount()

            let first = kinClient.accounts[0]
            let second = kinClient.accounts[0]

            XCTAssertNotNil(second)
            XCTAssert(first === second!)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

}
