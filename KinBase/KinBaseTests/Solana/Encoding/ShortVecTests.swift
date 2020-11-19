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

    func testShortVecEncode() {
        var encoded = try? ShortVec.encodeLength(0)
        XCTAssertEqual([UInt8](encoded!), [0])

        encoded = try? ShortVec.encodeLength(5)
        XCTAssertEqual([UInt8](encoded!), [5])

        encoded = try? ShortVec.encodeLength(0x7f)
        XCTAssertEqual([UInt8](encoded!), [0x7f])

        encoded = try? ShortVec.encodeLength(0x80)
        XCTAssertEqual([UInt8](encoded!), [0x80, 0x01])

        encoded = try? ShortVec.encodeLength(0xff)
        XCTAssertEqual([UInt8](encoded!), [0xff, 0x01])

        encoded = try? ShortVec.encodeLength(0x100)
        XCTAssertEqual([UInt8](encoded!), [0x80, 0x02])

        encoded = try? ShortVec.encodeLength(0x7fff)
        XCTAssertEqual([UInt8](encoded!), [0xff, 0xff, 0x01])
    }

    func testShortVecDecode() {
        var decoded = try? ShortVec.decodeLength(Data([0]))
        XCTAssertEqual(decoded!.length, 0)

        decoded = try? ShortVec.decodeLength(Data([5]))
        XCTAssertEqual(decoded!.length, 5)

        decoded = try? ShortVec.decodeLength(Data([0x7f]))
        XCTAssertEqual(decoded!.length, 0x7f)

        decoded = try? ShortVec.decodeLength(Data([0x80, 0x01]))
        XCTAssertEqual(decoded!.length, 0x80)

        decoded = try? ShortVec.decodeLength(Data([0xff, 0x01]))
        XCTAssertEqual(decoded!.length, 0xff)

        decoded = try? ShortVec.decodeLength(Data([0x80, 0x02]))
        XCTAssertEqual(decoded!.length, 0x100)

        decoded = try? ShortVec.decodeLength(Data([0xff, 0xff, 0x01]))
        XCTAssertEqual(decoded!.length, 0x7fff)

        decoded = try? ShortVec.decodeLength(Data([0x80, 0x80, 0x80, 0x01]))
        XCTAssertEqual(decoded!.length, 0x200000)
    }
    
    func testShortVec_Valid() {
        for i in 0..<UInt8.max {
            let input = try! ShortVec.encodeLength(Int(i))
            let actual = try! ShortVec.decodeLength(input)
            XCTAssertEqual(i, UInt8(actual.length))
        }
    }
    
    func testShortVec_CrossImpl() {

        struct test {
            var value: Int
            var encoded: [Byte]
            
            init(_ value: Int, _ encoded: [Byte]) {
                self.value = value
                self.encoded = encoded
            }
        }

        [test](arrayLiteral:
            test(0x0, [Byte](arrayLiteral: 0x0)),
            test(0x7f, [Byte](arrayLiteral: 0x7f)),
            test(0x80, [Byte](arrayLiteral: 0x80, 0x01)),
            test(0xff, [Byte](arrayLiteral: 0xff, 0x01)),
            test(0x100, [Byte](arrayLiteral: 0x80, 0x02)),
            test(0x7fff, [Byte](arrayLiteral: 0xff, 0xff, 0x01)),
            test(0xffff, [Byte](arrayLiteral: 0xff, 0xff, 0x03))
        ).forEach { it in
            let output = try! ShortVec.encodeLength(it.value)
            XCTAssertEqual(it.encoded.count, [Byte](output).count)
            XCTAssertTrue(it.encoded.elementsEqual([Byte](output)))
        }
    }
}
