//
//  KinBinaryMemoTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class KinBinaryMemoTests: XCTestCase {

    func testEncodingSpecificFK() {
        let agoraMemo = try! KinBinaryMemo(magicByteIndicator: 1,
                                           version: 2,
                                           typeId: 3,
                                           appIdx: 10,
                                           foreignKeyBytes: [0xAE, 0xFD])
        let encoded: Data = agoraMemo.encode()
        let decoded = try! KinBinaryMemo(data: encoded)!
        XCTAssertEqual(agoraMemo.foreignKeyBytes, decoded.foreignKeyBytes)
    }

    func testEncodingValidFKLessThanMax() {
        for _ in 0...500 {
            let agoraMemo = try! KinBinaryMemo(magicByteIndicator: 1,
                                           version: 2,
                                           typeId: 3,
                                           appIdx: 10,
                                           foreignKeyBytes: [Byte](UUID().uuidString.data(using: .utf8)!))
            let encoded: Data = agoraMemo.encode()
            let decoded = try! KinBinaryMemo(data: encoded)!
            XCTAssertEqual(agoraMemo.foreignKeyBytes, decoded.foreignKeyBytes)
        }
    }

    func testEncodingValidFKAtOrLargerThanMax() {
        for _ in 0...500 {
            let foreignKeyBytes =
                [Byte](UUID().uuidString.data(using: .utf8)!) +
                [Byte](UUID().uuidString.data(using: .utf8)!)

            let agoraMemo = try! KinBinaryMemo(magicByteIndicator: 1,
                                           version: 2,
                                           typeId: 3,
                                           appIdx: 10,
                                           foreignKeyBytes: foreignKeyBytes)
            let encoded: Data = agoraMemo.encode()
            let decoded = try! KinBinaryMemo(data: encoded)!
            XCTAssertEqual(agoraMemo.foreignKeyBytes, decoded.foreignKeyBytes)
        }
    }

    func testEncodingAppIdxValidRange() {
        for i: UInt16 in 0...65535 {
            let foreignKeyBytes = [Byte](UUID().uuidString.data(using: .utf8)!)

            let agoraMemo = try! KinBinaryMemo(magicByteIndicator: 3,
                                           version: 7,
                                           typeId: 3,
                                           appIdx: i,
                                           foreignKeyBytes: foreignKeyBytes)
            let encoded: Data = agoraMemo.encode()
            let decoded = try! KinBinaryMemo(data: encoded)!

            XCTAssertEqual(decoded.magicByteIndicator, 3)
            XCTAssertEqual(decoded.version, 7)
            XCTAssertEqual(decoded.typeId, KinBinaryMemo.TransferType.p2p)
            XCTAssertEqual(decoded.appIdx, i)
            XCTAssertEqual(decoded.foreignKeyBytes, agoraMemo.foreignKeyBytes)
        }
    }

    func testInitMagicByteTooLarge() {
        let foreignKeyBytes = [Byte](UUID().uuidString.data(using: .utf8)!)

        XCTAssertThrowsError(try KinBinaryMemo(magicByteIndicator: 4,
                                           version: 7,
                                           typeId: 2,
                                           appIdx: 65535,
                                           foreignKeyBytes: foreignKeyBytes))
        { error in
            XCTAssertEqual(error as! KinBinaryMemo.AgoraMemoFormatError, KinBinaryMemo.AgoraMemoFormatError.invalidMagicByteIndicator)
        }
    }

    func testInitTypeIdUnknown() {
        let foreignKeyBytes = [Byte](UUID().uuidString.data(using: .utf8)!)

        XCTAssertThrowsError(try KinBinaryMemo(magicByteIndicator: 1,
                                           version: 7,
                                           typeId: -1,
                                           appIdx: 65535,
                                           foreignKeyBytes: foreignKeyBytes))
        { error in
            XCTAssertEqual(error as! KinBinaryMemo.AgoraMemoFormatError, KinBinaryMemo.AgoraMemoFormatError.invalidTypeId)
        }
    }

    func testInitEmptyForeignKeyBytes() {
        let memo = try! KinBinaryMemo(magicByteIndicator: 1,
                                  version: 7,
                                  typeId: 1,
                                  appIdx: 65535,
                                  foreignKeyBytes: [])
        let expectForeignKeyBytes = [Byte](repeating: 0, count: 29)

        XCTAssertEqual(memo.foreignKeyBytes, expectForeignKeyBytes)
    }

    func testForeignKeyString() {
        let foreignKeyBytes = [Byte](UUID().uuidString.data(using: .utf8)!)
        let memo = try! KinBinaryMemo(magicByteIndicator: 1,
                                  version: 7,
                                  typeId: 3,
                                  appIdx: 65535,
                                  foreignKeyBytes: foreignKeyBytes)
        XCTAssertEqual(memo.foreignKeyString, Data(memo.foreignKeyBytes).base64EncodedString())
    }
}
