//
//  ProgramsTest.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class ProgramsTests: XCTestCase {
    func testCreateAccount() {
        let keys = generateKeys(3)
        
        let instruction = SystemProgram.createAccountInstruction(
            subsidizer: keys[0].asPublicKey(),
            address: keys[1].asPublicKey(),
            owner: keys[2].asPublicKey(),
            lamports: 12345,
            size: 67890
        )
        
        let command = [Byte](repeating: 0, count: 4)
        let lamports = UInt64(12345).bytes
            
        let size = UInt64(67890).bytes
        
        NSLog("\(instruction.data)")
        
        XCTAssertEqual(command, [Byte](instruction.data[0..<4]))
        XCTAssertEqual(lamports, [Byte](instruction.data[4..<12]))
        XCTAssertEqual(size, [Byte](instruction.data[12..<20]))
        XCTAssertEqual(keys[2].publicKey.bytes, [Byte](instruction.data[20..<52]))
        
        let tx = Transaction(
            data: Transaction(payer: keys[0].publicKey, instructions: instruction).encode()
        )
        
        XCTAssertNotNil(tx)
        
        //        decompiled, err : = DecompileCreateAccount(tx.Message, 0)
        //        require.NoError(t, err)
        //        assertEquals(t, decompiled.Funder, keys[0])
        //        assertEquals(t, decompiled.Address, keys[1])
        //        assertEquals(t, decompiled.Owner, keys[2])
        //        assertEqualsValues(t, decompiled.Lamports, 12345)
        //        assertEqualsValues(t, decompiled.Size, 67890)
    }
    
    func testInitializeAccount() {
        let keys = generateKeys(3)

        let instruction = TokenProgram.initializeAccountInstruction(
            account: keys[0].asPublicKey(),
            mint: keys[1].asPublicKey(),
            owner: keys[2].asPublicKey(),
            programKey: TokenProgram.publicKey
        )

        XCTAssertEqual(Byte(1), instruction.data[0])
        XCTAssertTrue(instruction.accounts[0].isSigner)
        XCTAssertTrue(instruction.accounts[0].isWritable)
        for i in 1..<4 {
            XCTAssertFalse(instruction.accounts[i].isSigner)
            XCTAssertFalse(instruction.accounts[i].isWritable)
        }
    }
    
    func testTransfer() {
        let keys = generateKeys(3)

        let instruction = TokenProgram.transferInstruction(
            source: keys[0].asPublicKey(),
            destination: keys[1].asPublicKey(),
            owner: keys[2].asPublicKey(),
            amount: Quark(UInt64(123456789)).kin,
            programKey: TokenProgram.publicKey
        )

        let expectedAmount = UInt64(123456789).bytes

        XCTAssertEqual(Byte(3), instruction.data[0])
        XCTAssertEqual(expectedAmount, [Byte](instruction.data[1..<instruction.data.count]))

        XCTAssertFalse(instruction.accounts[0].isSigner)
        XCTAssertTrue(instruction.accounts[0].isWritable)
        XCTAssertFalse(instruction.accounts[0].isSigner)
        XCTAssertTrue(instruction.accounts[0].isWritable)

        XCTAssertTrue(instruction.accounts[2].isSigner)
        XCTAssertTrue(instruction.accounts[2].isWritable)
    }
    
    
    func testMemos() {
        let keys = generateKeys(3)

        let textMemo = KinMemo(text: "1-kek-suffix")
        let binaryMemo = try! KinBinaryMemo(magicByteIndicator: 1,
                                       version: 2,
                                       typeId: KinBinaryMemo.TransferType.p2p.rawValue,
                                       appIdx: 10,
                                       foreignKeyBytes: [Byte](UUID().uuidString.data(using: .utf8)!))

        let instructionWithTextMemo = MemoProgram.memoInsutruction(with: textMemo.data)
        let instructionWithBinaryMemo = MemoProgram.memoInsutruction(with: binaryMemo.encode().base64EncodedData())

        let txTextMemo = Transaction(
            payer: keys[0].publicKey,
            instructions: instructionWithTextMemo
        )

        XCTAssertEqual("1-kek-suffix", String(bytes: txTextMemo.memo.data, encoding: .utf8))

        let txBinaryMemo = Transaction(
            payer: keys[0].publicKey,
            instructions: instructionWithBinaryMemo
        )

        XCTAssertEqual(binaryMemo.encode(), txBinaryMemo.memo.agoraMemo?.encode())
    }

    
    func generateKeys(_ amount: Int) -> [KeyPair] {
        (0..<amount).map { _ in
           KeyPair.generate()!
        }
    }
}
