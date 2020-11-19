//
//  SolanaTransactionEncodingTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class SolanaTransactionEncodingTests: XCTestCase {
    
    // Taken from: https://github.com/solana-labs/solana/blob/14339dec0a960e8161d1165b6a8e5cfb73e78f23/sdk/src/transaction.rs#L523
    let rustGenerated = "AUc7Cbu+gZalFSGeSFdukHhP7oSGaSdmdNEd5ZokaSysdoMWfI" +
           "OzjrAbdaBZZuDMAfyNAogAJdrhgVya+jthsgoBAAEDnON0wdcmjhYIDuXvd10F2qEjA" +
           "yEAJGSe/CGhYbk+WWMBAQEEBQYHCAkJCQkJCQkJCQkJCQkJCQkIBwYFBAEBAQICAgQF" +
           "BgcICQEBAQEBAQEBAQEBAQEBCQgHBgUEAgICAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" +
           "AAAAAAAAAAAABAgIAAQMBAgM="

    // The above example does not have the correct public key encoded in the keypair.
    // This is the above example with the correctly generated keypair.
    let rustGeneratedAdjusted =
       "ATMfBMZ8phHEheLph8K9TJhRKhnE4qNZvWiXdUdJRmlTCRsQjWmW2CkQJeRHBCcsqFm" +
               "2gynjL40M9mTe0Dxp4QIBAAEDfEya6wnC7f3Cv53qnOEywwIJ928rIdqAlfXYI1adXroBAQEEBQYHCA" +
               "kJCQkJCQkJCQkJCQkJCQkIBwYFBAEBAQICAgQFBgcICQEBAQEBAQEBAQEBAQEBCQgHBgUEAgICAAAAA" +
               "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgIAAQMBAgM=="
    

    func testTransaction_CrossImpl() {
        let signerKeyBytes = [Byte](
        arrayLiteral: 48, 83, 2, 1, 1, 48, 5, 6, 3, 43, 101, 112, 4, 34, 4, 32, 255, 101, 36, 24, 124, 23,
           167, 21, 132, 204, 155, 5, 185, 58, 121, 75, 156, 227, 116, 193, 215, 38, 142, 22, 8,
           14, 229, 239, 119, 93, 5, 218, 161, 35, 3, 33, 0, 36, 100, 158, 252, 33, 161, 97, 185,
           62, 89, 99
        )
        let keypair = KeyPair(seed: try! Seed(bytes: signerKeyBytes[0..<32].map({ it in UInt8(it) })))
        NSLog("\(keypair)")

        let programID = SolanaPublicKey([UInt8](arrayLiteral: 2, 2, 2, 4, 5, 6, 7, 8, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 8, 7, 6, 5, 4, 2, 2, 2))!

        let to = SolanaPublicKey([UInt8](arrayLiteral:1, 1, 1, 4, 5, 6, 7, 8, 9, 9, 9, 9,9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 8, 7, 6, 5, 4, 1, 1, 1))!

        let data = [Byte](arrayLiteral: 1, 2, 3)

        let tx = SolanaTransaction.newTransaction(
        SolanaPublicKey(keypair.publicKey.bytes)!,
        SolanaInstruction.newInstruction(
            programID,
            Data(data),
            AccountMeta.newAccountMeta(SolanaPublicKey(keypair.publicKey.bytes)!, isSigner: true),
            AccountMeta.newAccountMeta(to, isSigner: false)
        )
        )

        NSLog("\(programID.encode().hexEncodedString())")
        NSLog("\(to.encode().hexEncodedString())")

        NSLog("\(Data([Byte](keypair.sign([Byte](tx.message.encode())))).hexEncodedString())")

        let signedTransaction = try! tx.copyAndSign(signers: keypair)

        XCTAssertEqual(
            Data(base64Encoded: rustGeneratedAdjusted)!.hexEncodedString(),
            signedTransaction.encode().hexEncodedString()
        )
    }
    
    func testTransaction_InvalidAccounts() {
        let keys = generateKeys(2)
        var tx = SolanaTransaction.newTransaction(
            keys[0].asPublicKey(),
            SolanaInstruction.newInstruction(
                keys[1].asPublicKey(),
                Data([Byte](arrayLiteral: 5,6,7)),
                AccountMeta.newAccountMeta(keys[0].asPublicKey(), isSigner: true, isProgram: true)
            )
        )
        let modifiedInstructions = [CompiledInstruction](arrayLiteral: CompiledInstruction(programIndex: 2, accounts: tx.message.instructions[0].accounts, data: tx.message.instructions[0].data))
        tx = SolanaTransaction(message: Message(header: tx.message.header, accounts: tx.message.accounts, instructions: modifiedInstructions, recentBlockhash: tx.message.recentBlockhash), signatures: tx.signatures)
            
        let marshledTx = tx.encode()
        
        XCTAssertNil(SolanaTransaction(data: marshledTx)) // Should fail
    }
    
    
    func testTransaction_SingleInstruction() {
       var keys = generateKeys(2)
       let payer = keys[0]
       let program = keys[1]

       keys = generateKeys(4)
       let data = [Byte](arrayLiteral: 1, 2, 3)

       var tx = SolanaTransaction.newTransaction(
           payer.asPublicKey(),
           SolanaInstruction.newInstruction(
               program.asPublicKey(),
               Data(data),
               AccountMeta.newReadonlyAccountMeta(keys[0].asPublicKey(), isSigner: true),
               AccountMeta.newReadonlyAccountMeta(keys[1].asPublicKey(), isSigner: false),
               AccountMeta.newAccountMeta(keys[2].asPublicKey(), isSigner: false),
               AccountMeta.newAccountMeta(
                keys[3].asPublicKey(), isSigner: true
               )
           )
       )

       // Intentionally sign out of order to ensure ordering is fixed.
        tx = try! tx.copyAndSign(signers: keys[0], keys[3], payer)

        XCTAssertEqual(tx.signatures.count, 3)
        XCTAssertEqual(tx.message.accounts.count, 6)
        XCTAssertEqual(2, tx.message.header.numSignatures)
        XCTAssertEqual(1, tx.message.header.numReadOnlySigned)
        XCTAssertEqual(2, tx.message.header.numReadOnly)

        let message = tx.message.encode()

        XCTAssertTrue(try! payer.verify(signature: tx.signatures[0].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[3].verify(signature: tx.signatures[1].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[0].verify(signature: tx.signatures[2].value, message: [Byte](message)))

        XCTAssertEqual(payer.asPublicKey(), tx.message.accounts[0])
        XCTAssertEqual(keys[3].asPublicKey(), tx.message.accounts[1])
        XCTAssertEqual(keys[0].asPublicKey(), tx.message.accounts[2])
        XCTAssertEqual(keys[2].asPublicKey(), tx.message.accounts[3])
        XCTAssertEqual(keys[1].asPublicKey(), tx.message.accounts[4])
        XCTAssertEqual(program.asPublicKey(), tx.message.accounts[5])

        XCTAssertEqual(Byte(5), tx.message.instructions[0].programIndex)
        XCTAssertEqual(ByteArray(data), tx.message.instructions[0].data)

        NSLog("\(tx.message.instructions[0].accounts.encode().hexEncodedString())")
        
        XCTAssertTrue(
            [Byte](arrayLiteral: 2, 4, 3, 1).elementsEqual(tx.message.instructions[0].accounts.value)
        )
    }
    
    func testTransaction_DuplicateKeys() {
        var keys = generateKeys(2)
        let payer = keys[0]
        let program = keys[1]

        keys = generateKeys(4)
        let data = [Byte](arrayLiteral: 1, 2, 3)

        // Key[0]: ReadOnlySigner -> WritableSigner
        // Key[1]: ReadOnly       -> ReadOnlySigner
        // Key[2]: Writable       -> Writable       (ReadOnly,noop)
        // Key[3]: WritableSigner -> WritableSignera (ReadOnly,noop)

        var tx = SolanaTransaction.newTransaction(
            payer.asPublicKey(),
            SolanaInstruction.newInstruction(
                program.asPublicKey(),
                Data(data),
                AccountMeta.newReadonlyAccountMeta(keys[0].asPublicKey(), isSigner: true),
                AccountMeta.newReadonlyAccountMeta(keys[1].asPublicKey(), isSigner: false),
                AccountMeta.newAccountMeta(keys[2].asPublicKey(), isSigner: false),
                AccountMeta.newAccountMeta(keys[3].asPublicKey(), isSigner: true),
                // Upgrade keys [0] and [1]
                AccountMeta.newAccountMeta(keys[0].asPublicKey(), isSigner: false),
                AccountMeta.newReadonlyAccountMeta(keys[1].asPublicKey(), isSigner: true),
                // 'Downgrade' keys [2] and [3] (noop)
                AccountMeta.newReadonlyAccountMeta(keys[2].asPublicKey(), isSigner: false),
                AccountMeta.newReadonlyAccountMeta(keys[3].asPublicKey(), isSigner: false)
            )
        )

        // Intentionally sign out of order to ensure ordering is fixed.
        tx = try! tx.copyAndSign(signers: keys[0], keys[1], keys[3], payer)

        XCTAssertEqual(tx.signatures.count, 4)
        XCTAssertEqual(tx.message.accounts.count, 6)
        XCTAssertEqual(3, tx.message.header.numSignatures)
        XCTAssertEqual(1, tx.message.header.numReadOnlySigned)
        XCTAssertEqual(1, tx.message.header.numReadOnly)

        let message = tx.message.encode()

        XCTAssertTrue(try! payer.verify(signature: tx.signatures[0].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[3].verify(signature: tx.signatures[1].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[0].verify(signature: tx.signatures[2].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[1].verify(signature: tx.signatures[3].value, message: [Byte](message)))

        XCTAssertEqual(payer.asPublicKey(), tx.message.accounts[0])
        XCTAssertEqual(keys[3].asPublicKey(), tx.message.accounts[1])
        XCTAssertEqual(keys[0].asPublicKey(), tx.message.accounts[2])
        XCTAssertEqual(keys[1].asPublicKey(), tx.message.accounts[3])
        XCTAssertEqual(keys[2].asPublicKey(), tx.message.accounts[4])
        XCTAssertEqual(program.asPublicKey(), tx.message.accounts[5])

        XCTAssertEqual(Byte(5), tx.message.instructions[0].programIndex)
        XCTAssertEqual(ByteArray(data), tx.message.instructions[0].data)
        
        NSLog("\(tx.message.instructions[0].accounts.value)")
        
        XCTAssertTrue(
            [Byte](arrayLiteral: 2, 3, 4, 1, 2, 3, 4, 1).elementsEqual(tx.message.instructions[0].accounts.value)
        )
    }
    
    func testTransaction_MultiInstruction() {
        var keys = generateKeys(3)
        let payer = keys[0]
        let program = keys[1]
        let program2 = keys[2]

        keys = generateKeys(6)

        NSLog("payer: \(payer.asPublicKey())")
        NSLog("program: \(program.asPublicKey())")
        NSLog("program2: \(program2.asPublicKey())")
        NSLog("keys[0]: \(keys[0].asPublicKey())")
        NSLog("keys[1]: \(keys[1].asPublicKey())")
        NSLog("keys[2]: \(keys[2].asPublicKey())")
        NSLog("keys[3]: \(keys[3].asPublicKey())")
        NSLog("keys[4]: \(keys[4].asPublicKey())")
        NSLog("keys[5]: \(keys[5].asPublicKey())")

        let data = [Byte](arrayLiteral: 1, 2, 3)
        let data2 = [Byte](arrayLiteral: 3, 4, 5)

        // Key[0]: ReadOnlySigner -> WritableSigner
        // Key[1]: ReadOnly       -> WritableSigner
        // Key[2]: Writable       -> Writable       (ReadOnly,noop)
        // Key[3]: WritableSigner -> WritableSigner (ReadOnly,noop)
        // Key[4]: n/a            -> WritableSigner
        // Key[5]: n/a            -> ReadOnly

        var tx = SolanaTransaction.newTransaction(
            payer.asPublicKey(),
            SolanaInstruction.newInstruction(
                program.asPublicKey(),
                Data(data),
                AccountMeta.newReadonlyAccountMeta(keys[0].asPublicKey(), isSigner: true),
                AccountMeta.newReadonlyAccountMeta(keys[1].asPublicKey(), isSigner: false),
                AccountMeta.newAccountMeta(keys[2].asPublicKey(), isSigner: false),
                AccountMeta.newAccountMeta(keys[3].asPublicKey(), isSigner: true)
            ),
            SolanaInstruction.newInstruction(
                program2.asPublicKey(),
                Data(data2),
                // Ensure that keys don't get downgraded in permissions
                AccountMeta.newReadonlyAccountMeta(keys[3].asPublicKey(), isSigner: false),
                AccountMeta.newReadonlyAccountMeta(keys[2].asPublicKey(), isSigner: false),
                // Ensure we can upgrade upgrading works
                AccountMeta.newAccountMeta(keys[0].asPublicKey(), isSigner: false),
                AccountMeta.newAccountMeta(keys[1].asPublicKey(), isSigner: true),
                // Ensure accounts get added
                AccountMeta.newAccountMeta(keys[4].asPublicKey(), isSigner: true),
                AccountMeta.newReadonlyAccountMeta(keys[5].asPublicKey(), isSigner: false)
            )
        )

        NSLog("\(tx)")

        tx = try! tx.copyAndSign(signers: payer, keys[0], keys[1], keys[3], keys[4])

        XCTAssertEqual(tx.signatures.count, 5)
        XCTAssertEqual(tx.message.accounts.count, 9)

        XCTAssertEqual(5, tx.message.header.numSignatures)
        XCTAssertEqual(0, tx.message.header.numReadOnlySigned)
        XCTAssertEqual(3, tx.message.header.numReadOnly)

        let message = tx.message.encode()

        XCTAssertTrue(try! payer.verify(signature: tx.signatures[0].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[4].verify(signature: tx.signatures[1].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[0].verify(signature: tx.signatures[2].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[1].verify(signature: tx.signatures[3].value, message: [Byte](message)))
        XCTAssertTrue(try! keys[3].verify(signature: tx.signatures[4].value, message: [Byte](message)))

        XCTAssertEqual(payer.asPublicKey(), tx.message.accounts[0])
        XCTAssertEqual(keys[4].asPublicKey(), tx.message.accounts[1])
        XCTAssertEqual(keys[0].asPublicKey(), tx.message.accounts[2])
        XCTAssertEqual(keys[1].asPublicKey(), tx.message.accounts[3])
        XCTAssertEqual(keys[3].asPublicKey(), tx.message.accounts[4])
        XCTAssertEqual(keys[2].asPublicKey(), tx.message.accounts[5])
        XCTAssertEqual(keys[5].asPublicKey(), tx.message.accounts[6])
        XCTAssertEqual(program2.asPublicKey(), tx.message.accounts[7])
        XCTAssertEqual(program.asPublicKey(), tx.message.accounts[8])

        XCTAssertEqual(Byte(8), tx.message.instructions[0].programIndex)
        XCTAssertEqual(data, tx.message.instructions[0].data.value)
        XCTAssertTrue(
            [Byte](arrayLiteral: 2, 3, 5, 4)
                .elementsEqual(tx.message.instructions[0].accounts.value)
        )

        XCTAssertEqual(Byte(7), tx.message.instructions[1].programIndex)
        XCTAssertEqual(data2, tx.message.instructions[1].data.value)
        XCTAssertTrue(
            [Byte](arrayLiteral: 4, 5, 2, 3, 1, 6)
                .elementsEqual(tx.message.instructions[1].accounts.value)
        )
    }

    func generateKeys(_ amount: Int) -> [KeyPair] {
        var keys = [KeyPair]()
        for _ in 0..<amount {
           keys.append(try! KeyPair.generateRandomKeyPair())
        }
        return keys
    }
    
}
