//
//  MessageTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class MessageTests: XCTestCase {
    
    func testMessageHeader() throws {
        let header = MessageHeader(
            signatureCount: 2,
            readOnlySignedCount: 1,
            readOnlyCount: 3
        )
        
        let data = header.encode()
        let decodedHeader = try XCTUnwrap(MessageHeader(data: data))
        
        XCTAssertEqual(decodedHeader.signatureCount, 2)
        XCTAssertEqual(decodedHeader.readOnlySignedCount, 1)
        XCTAssertEqual(decodedHeader.readOnlyCount, 3)
    }
    
    func testEncodeDecodeCycle() throws {
        let instructions = [
            CompiledInstruction(
                programIndex: 0,
                accountIndexes: [1, 2],
                data: Data([85, 73, 81, 94, 90, 23, 54, 12])
            ),
            CompiledInstruction(
                programIndex: 1,
                accountIndexes: [2, 3],
                data: Data([81, 77, 95, 71, 86, 13, 34, 17])
            ),
        ]
        
        let header = MessageHeader(
            signatureCount: 2,
            readOnlySignedCount: 1,
            readOnlyCount: 3
        )
        
        let accounts = (0..<3).map { _ in KeyPair.generate()!.publicKey }
        let hash = KeyPair.generate()!.publicKey
        
        let message = Message(
            header: header,
            accounts: accounts,
            recentBlockhash: hash,
            instructions: instructions
        )
        
        let data = message.encode()
        let decodedMessage = try XCTUnwrap(Message(data: data))
        
        XCTAssertEqual(decodedMessage.header, header)
        XCTAssertEqual(decodedMessage.accounts, accounts)
        XCTAssertEqual(decodedMessage.recentBlockhash, hash)
        XCTAssertEqual(decodedMessage.instructions, instructions)
    }
}
