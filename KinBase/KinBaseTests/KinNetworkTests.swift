//
//  KinNetworkTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class KinNetworkTests: XCTestCase {
    
    func testNetworkId() {
        XCTAssertEqual(KinNetwork.mainNet.id, "Kin Mainnet ; December 2018")
        XCTAssertEqual(KinNetwork.testNet.id, "Kin Testnet ; December 2018")
    }
    
    func testAgoraURL() {
        let main = "api.agorainfra.net:443"
        let test = "api.agorainfra.dev:443"
        
        XCTAssertEqual(KinNetwork.mainNet.agoraUrl, main)
        XCTAssertEqual(KinNetwork.testNet.agoraUrl, test)
    }
}
