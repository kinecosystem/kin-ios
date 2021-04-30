//
//  ShortVecTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class ShortVecTests: XCTestCase {

    func testEncode() {
        var encoded = ShortVec.encodeLength(0)
        XCTAssertEqual([UInt8](encoded), [0])

        encoded = ShortVec.encodeLength(5)
        XCTAssertEqual([UInt8](encoded), [5])

        encoded = ShortVec.encodeLength(0x7f)
        XCTAssertEqual([UInt8](encoded), [0x7f])

        encoded = ShortVec.encodeLength(0x80)
        XCTAssertEqual([UInt8](encoded), [0x80, 0x01])

        encoded = ShortVec.encodeLength(0xff)
        XCTAssertEqual([UInt8](encoded), [0xff, 0x01])

        encoded = ShortVec.encodeLength(0x100)
        XCTAssertEqual([UInt8](encoded), [0x80, 0x02])

        encoded = ShortVec.encodeLength(0x7fff)
        XCTAssertEqual([UInt8](encoded), [0xff, 0xff, 0x01])
    }
    
    func testEncodeComponents() {
        let components = [
            Data([1, 2, 3, 4]),
            Data([5, 6, 7, 8]),
            Data([9, 8, 7, 6]),
            Data([4, 3, 2, 1]),
        ]
        
        let data = ShortVec.encode(components)
        
        XCTAssertEqual(data.count, 17)
        XCTAssertEqual(data[0], 4)
        
        let (length, remaining) = ShortVec.decodeLength(data)
        
        XCTAssertEqual(length, 4)
        XCTAssertEqual(remaining[0..<4],   components[0])
        XCTAssertEqual(remaining[4..<8],   components[1])
        XCTAssertEqual(remaining[8..<12],  components[2])
        XCTAssertEqual(remaining[12..<16], components[3])
    }

    func testDecode() {
        var decoded = ShortVec.decodeLength(Data([0]))
        XCTAssertEqual(decoded.length, 0)

        decoded = ShortVec.decodeLength(Data([5]))
        XCTAssertEqual(decoded.length, 5)

        decoded = ShortVec.decodeLength(Data([0x7f]))
        XCTAssertEqual(decoded.length, 0x7f)

        decoded = ShortVec.decodeLength(Data([0x80, 0x01]))
        XCTAssertEqual(decoded.length, 0x80)

        decoded = ShortVec.decodeLength(Data([0xff, 0x01]))
        XCTAssertEqual(decoded.length, 0xff)

        decoded = ShortVec.decodeLength(Data([0x80, 0x02]))
        XCTAssertEqual(decoded.length, 0x100)

        decoded = ShortVec.decodeLength(Data([0xff, 0xff, 0x01]))
        XCTAssertEqual(decoded.length, 0x7fff)

        decoded = ShortVec.decodeLength(Data([0x80, 0x80, 0x80, 0x01]))
        XCTAssertEqual(decoded.length, 0x200000)
    }
    
    func testValidity() {
        for i in 0..<UInt8.max {
            let input = ShortVec.encodeLength(UInt16(i))
            let actual = ShortVec.decodeLength(input)
            XCTAssertEqual(i, UInt8(actual.length))
        }
    }
    
    func testCrossImplementation() {
        [
            Container(0x0,    [0x0]),
            Container(0x7f,   [0x7f]),
            Container(0x80,   [0x80, 0x01]),
            Container(0xff,   [0xff, 0x01]),
            Container(0x100,  [0x80, 0x02]),
            Container(0x7fff, [0xff, 0xff, 0x01]),
            Container(0xffff, [0xff, 0xff, 0x03]),
        ].forEach {
            let output = ShortVec.encodeLength($0.value)
            XCTAssertEqual($0.encoded.count, [Byte](output).count)
            XCTAssertTrue($0.encoded.elementsEqual([Byte](output)))
        }
    }
}

private struct Container {
    var value: UInt16
    var encoded: [Byte]
    
    init(_ value: UInt16, _ encoded: [Byte]) {
        self.value = value
        self.encoded = encoded
    }
}
