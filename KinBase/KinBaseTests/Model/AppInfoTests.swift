//
//  AppInfoTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class AppInfoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDummyAppInfoProviderCreds() {
        let provider = DummyAppInfoProvider()
        let creds = provider.getPassthroughAppUserCredentials()
        XCTAssertFalse(creds.appUserId.isEmpty)
        XCTAssertFalse(creds.appUserPasskey.isEmpty)
    }

    func testDummyAppInfoProviderAppInfo() {
        let provider = DummyAppInfoProvider()
        let appInfo = provider.appInfo
        XCTAssertEqual(appInfo.appIdx.value, AppInfo.testApp.appIdx.value)
    }
}
