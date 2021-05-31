//
//  KeyChainStorageTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc. on 2020-02-18.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class KeyChainStorageTests: XCTestCase {
    var sut: SecureKeyStorage!

    override func setUp() {
        sut = KeyChainStorage()
        try! sut.clear()
    }

    override func tearDown() {
        try! sut.clear()
    }

    func testAddAndRetrieve() {
        let keyPair = KeyPair.generate()!
        let expectKey = keyPair.seed!.data

        try! sut.add(account: keyPair.accountId, key: expectKey)

        let retrievedKey = sut.retrieve(account: keyPair.accountId)

        XCTAssertEqual(expectKey, retrievedKey)
    }

    func testAddAndDelete() {
        let keyPair = KeyPair.generate()!
        let key = keyPair.seed!.data

        try! sut.add(account: keyPair.accountId, key: key)
        try! sut.delete(account: keyPair.accountId)

        XCTAssertNil(sut.retrieve(account: keyPair.accountId))
    }

    func testAddAndReplaceExisting() {
        let keyPair = KeyPair.generate()!
        let oldKey = "oldkey".data(using: .utf8)!
        let newKey = keyPair.seed!.data

        try! sut.add(account: keyPair.accountId, key: oldKey)
        try! sut.add(account: keyPair.accountId, key: newKey)

        let retrievedKey = sut.retrieve(account: keyPair.accountId)

        XCTAssertEqual(newKey, retrievedKey)
    }

    func testAllAccounts() {
        // Empty
        XCTAssertEqual(try! sut.allAccounts().count, 0)

        // One account
        let keyPair1 = KeyPair.generate()!
        try! sut.add(account: keyPair1.accountId, key: keyPair1.seed!.data)
        XCTAssertEqual(try! sut.allAccounts(), [keyPair1.accountId])

        // More than one account
        let keyPair2 = KeyPair.generate()!
        try! sut.add(account: keyPair2.accountId, key: keyPair2.seed!.data)
        let allAccounts = try! sut.allAccounts()
        XCTAssertEqual(allAccounts.count, 2)
        XCTAssertTrue(allAccounts.contains(keyPair1.accountId))
        XCTAssertTrue(allAccounts.contains(keyPair2.accountId))

        // After clear
        try! sut.clear()
        XCTAssertEqual(try! sut.allAccounts().count, 0)
    }
}

//extension stellarsdk.Seed {
//    public var data: Data {
//        return Data(bytes: self.bytes, count: self.bytes.count)
//    }
//}
