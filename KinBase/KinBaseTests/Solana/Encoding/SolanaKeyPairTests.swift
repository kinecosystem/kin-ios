//
//  SolanaKeyPairTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Sodium
@testable import KinBase

class SolanaKeyPairTests: XCTestCase {

    func testKeyPairEncoding() {
        let newKeyPair = SolanaKeyPair(Sodium().sign.keyPair()!)
        let encoded = newKeyPair.encode()
        let decoded = SolanaKeyPair(data: encoded)
        XCTAssertEqual(newKeyPair, decoded)
    }
}
