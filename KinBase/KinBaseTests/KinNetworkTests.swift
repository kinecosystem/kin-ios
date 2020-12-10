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

    func testIssuer() {
        XCTAssertEqual(KinNetwork.mainNet.issuer, nil)
        XCTAssertEqual(KinNetwork.testNet.issuer, nil)
        XCTAssertEqual(KinNetwork.mainNetKin2.issuer?.accountId, "GDF42M3IPERQCBLWFEZKQRK77JQ65SCKTU3CW36HZVCX7XX5A5QXZIVK")
        XCTAssertEqual(KinNetwork.testNetKin2.issuer?.accountId, "GBC3SG6NGTSZ2OMH3FFGB7UVRQWILW367U4GSOOF4TFSZONV42UJXUH7")
    }
    
    func testIsKin2() {
        XCTAssertEqual(KinNetwork.mainNet.isKin2, false)
        XCTAssertEqual(KinNetwork.testNet.isKin2, false)
        XCTAssertEqual(KinNetwork.mainNetKin2.isKin2, true)
        XCTAssertEqual(KinNetwork.testNetKin2.isKin2, true)
    }
    
    func testNetworkId() {
        XCTAssertEqual(KinNetwork.mainNet.id, "Kin Mainnet ; December 2018")
        XCTAssertEqual(KinNetwork.testNet.id, "Kin Testnet ; December 2018")
        XCTAssertEqual(KinNetwork.mainNetKin2.id, "Public Global Kin Ecosystem Network ; June 2018")
        XCTAssertEqual(KinNetwork.testNetKin2.id, "Kin Playground Network ; June 2018")
    }
    
    func testAgoraURL() {
        let main = "api.agorainfra.net:443"
        let test = "api.agorainfra.dev:443"
        
        XCTAssertEqual(KinNetwork.mainNet.agoraUrl, main)
        XCTAssertEqual(KinNetwork.testNet.agoraUrl, test)
        XCTAssertEqual(KinNetwork.mainNetKin2.agoraUrl, main)
        XCTAssertEqual(KinNetwork.testNetKin2.agoraUrl, test)
    }
}
