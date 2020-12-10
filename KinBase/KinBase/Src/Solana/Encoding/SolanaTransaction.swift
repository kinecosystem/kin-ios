//
//  Transaction.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

/**
    Signature: [64]byte
    PublicKey: [32]byte
    Hash:      [32]byte
    CompiledInstruction:
        program_id_index: byte            // index of the program account in message::AccountKeys
        accounts:         short_vec<byte> // ordered indices mapping to message::AccountKeys to input to program
        data:             short_vec<byte> // raw data
    Transaction:
        signature: short_vec<Signature>
        Message:
            Header:
                num_required_signatures:        byte
                num_readonly_signed_accounts:   byte
                num_readonly_unsigned_accounts: byte
            AccountKeys:     short_vec<PublicKey>
            RecentBlockHash: Hash
            Instructions:    short_vec<CompiledInstruction>
    Serialization:
        - Arrays: No length, just elements.
        - ShortVec: ShortVec encoded length, then elements
        - Byte: Byte
        - Structs: Fields are serialized in order as declared. No metadata about structs are serialized.
*/


/// Signature: [64]byte
public class Signature: FixedLengthByteArray {
    override class var Length: UInt {
        return 64
    }
}

/// PublicKey: [32]byte
public class SolanaPublicKey: FixedLengthByteArray {
    override class var Length: UInt {
        return 32
    }
    
    public override var description: String {
        return accountId
    }
}

public class SolanaPrivateKey: FixedLengthByteArray {
    override class var Length: UInt {
        return 64
    }
}

/// Hash: [32]byte
public class Hash: FixedLengthByteArray {
    override class var Length: UInt {
        return 32
    }
}

public struct MessageHeader: SolanaCodable {
    let numSignatures: Byte
    let numReadOnlySigned: Byte
    let numReadOnly: Byte

    static let Length = 3

    init(numSignatures: Byte = 0,
         numReadOnlySigned: Byte = 0,
         numReadOnly: Byte = 0) {
        self.numSignatures = numSignatures
        self.numReadOnlySigned = numReadOnlySigned
        self.numReadOnly = numReadOnly
    }

    init?(data: Data) {
        let array = [Byte](data)
        guard array.count == 3 else {
            return nil
        }

        self.numSignatures = array[0]
        self.numReadOnlySigned = array[1]
        self.numReadOnly = array[2]
    }

    func encode() -> Data {
        return Data([numSignatures,
                     numReadOnlySigned,
                     numReadOnly])
    }

    public static func == (lhs: MessageHeader, rhs: MessageHeader) -> Bool {
        return lhs.numSignatures == rhs.numSignatures &&
            lhs.numReadOnlySigned == rhs.numReadOnlySigned &&
            lhs.numReadOnly == rhs.numReadOnly
    }
    
    
    public var description: String {
        return "MessageHeader(numSignatures: \(numSignatures), numReadOnlySigned: \(numReadOnlySigned), numReadOnly: \(numReadOnly)"
    }
}



public struct Message: SolanaCodable {
    let header: MessageHeader
    let accounts: [SolanaPublicKey]
    let recentBlockhash: Hash
    let instructions: [CompiledInstruction]

    init(header: MessageHeader,
         accounts: [SolanaPublicKey],
         instructions: [CompiledInstruction],
         recentBlockhash: Hash) {
        self.header = header
        self.accounts = accounts
        self.recentBlockhash = recentBlockhash
        self.instructions = instructions
    }

    init?(data: Data) {
        var remData = data

        // Decode `header`
        let headerData = remData.subdata(in: 0..<MessageHeader.Length)

        guard let header = MessageHeader(data: headerData) else {
            return nil
        }

        self.header = header

        remData = remData.subdata(in: MessageHeader.Length..<remData.count)

        // Decode `accountKeys`
        guard let publicKeyTuple = try? ShortVec.decodeLength(remData) else {
            return nil
        }

        remData = publicKeyTuple.remainingData

        var keys = [SolanaPublicKey]()
        for _ in 0..<publicKeyTuple.length {
            let publicKeyData = remData.subdata(in: 0..<Int(SolanaPublicKey.Length))

            guard let pk = SolanaPublicKey(data: publicKeyData) else {
                return nil
            }

            keys.append(pk)
            remData = remData.subdata(in: Int(SolanaPublicKey.Length)..<remData.count)
        }

        self.accounts = keys

        // Decode `recentBlockHash`
        let hashData = remData.subdata(in: 0..<Int(Hash.Length))
        guard let hash = Hash(data: hashData) else {
            return nil
        }

        self.recentBlockhash = hash
        remData = remData.subdata(in: Int(Hash.Length)..<remData.count)

        // Decode `instructions`
        guard let instructionsTuple = try? ShortVec.decodeLength(remData) else {
            return nil
        }

        remData = instructionsTuple.remainingData

        var instructions = [CompiledInstruction]()
        for _ in 0..<instructionsTuple.length {
            guard let instruction = CompiledInstruction(data: remData) else {
                return nil
            }
            
           guard instruction.programIndex >= 0 && instruction.programIndex < keys.count else {
              return nil
           }

            for accountIndex in 0..<instruction.accounts.value.count {
              guard accountIndex >= 0 && accountIndex < keys.count else {
                  return nil
              }
           }

            instructions.append(instruction)

            let length = instruction.encode().count

            remData = remData.subdata(in: length..<remData.count)
        }
        
        self.instructions = instructions
    }

    func encode() -> Data {
        var encoded = header.encode()

        encoded.append(try! ShortVec.encodeLength(accounts.count))
        for key in accounts {
            encoded.append(key.encode())
        }

        encoded.append(recentBlockhash.encode())

        encoded.append(try! ShortVec.encodeLength(instructions.count))
        for instruction in instructions {
            encoded.append(instruction.encode())
        }

        return encoded
    }
    
    public var description: String {
        return "MessageHeader(header: \(header), accounts: \(accounts), recentBlockhash: \(recentBlockhash), instructions: \(instructions)"
    }
}

extension Message {
    func copy(
        header: MessageHeader? = nil,
        accounts: [SolanaPublicKey]? = nil,
        instructions: [CompiledInstruction]? = nil,
        recentBlockhash: Hash? = nil
    ) -> Message {
        return Message(header: header ?? self.header, accounts: accounts ?? self.accounts, instructions: instructions ?? self.instructions, recentBlockhash: recentBlockhash ?? self.recentBlockhash)
    }
}

public struct SolanaTransaction: SolanaCodable {
    
    let signatures: [Signature]
    let message: Message
    
    static func newTransaction(
           _ payer: SolanaPublicKey,
           _ instructions: SolanaInstruction...
    ) -> SolanaTransaction {
        return newTransaction(payer, instructions)
    }

    static func newTransaction(
        _ payer: SolanaPublicKey,
        _ instructions: Array<SolanaInstruction>
    ) -> SolanaTransaction {
        var accounts = [AccountMeta](
            arrayLiteral: AccountMeta(
                publicKey: payer,
                isSigner: true,
                isWritable: true,
                isPayer: true
            )
        )

        // Extract all of the unique accounts from the instructions.
        instructions.makeIterator().forEach({ (it) in
            accounts.append(
                          AccountMeta(
                            publicKey: it.program,
                            isProgram: true
                          )
                      )
            accounts.append(contentsOf: it.accounts)
        })

        // Sort the account meta's based on:
        //   1. Payer is always the first account / signer.
        //   1. All signers are before non-signers.
        //   2. Writable accounts before read-only accounts.
        //   3. Programs last
        var uniqueAccounts = accounts.filterUnique()
        uniqueAccounts.quickSort() //sorted() //quickSort()

        let header = MessageHeader(
            numSignatures: Byte(uniqueAccounts.filter { it in it.isSigner }.count),
            numReadOnlySigned: Byte(uniqueAccounts.filter { it in  !it.isWritable && it.isSigner }.count),
            numReadOnly: Byte(uniqueAccounts.filter { it in !it.isWritable && !it.isSigner }.count)
        )
        let accountPublicKeys = uniqueAccounts.map { it in it.publicKey }
        let messageInstructions = instructions.map { it in
            CompiledInstruction(
                programIndex: Byte(indexOf(accountPublicKeys, it.program)),
                accounts: ByteArray(it.accounts.map { it in Byte(indexOf(accountPublicKeys, it.publicKey)) }),
                data: ByteArray([Byte](it.data))
            )
        }
        let message = Message(
            header: header,
            accounts: accountPublicKeys,
            instructions: messageInstructions,
            recentBlockhash: Hash([Byte](repeating: 0, count: Int(32)))!
            /** Empty unless set with [copyAndSetRecentBlockhash] **/
        )

        return SolanaTransaction(message: message, signatures: [Signature]())
    }
    
    private static func indexOf(_ slice: [SolanaPublicKey], _ item: SolanaPublicKey) -> Int {
        var i: Int=0
        for publicKey in slice {
            if (publicKey.value.elementsEqual(item.value)) {
                return i
            }
            i += 1
        }
        return -1
    }
    
    func copyAndSetRecentBlockhash(recentBlockhash: Hash) -> SolanaTransaction {
        return SolanaTransaction(message: message.copy(recentBlockhash: recentBlockhash), signatures: signatures)
    }
    
    enum SigningError: Error {
        case tooManySigners
        case accountNotInAccountList(_ reason: String)
        case invalidKey
    }
    
    func updatingSignature(signature: Signature) -> SolanaTransaction {
        // Copy and replace the first signature in this transaction
        // and return a new transaction.
        var signatures = [signature]
        signatures.append(contentsOf: self.signatures[1...])
        
        return SolanaTransaction(
            message: message,
            signatures: signatures
        )
    }
    
    func copyAndSign(signers: KeyPair...) throws -> SolanaTransaction {
        let numRequiredSignatures = Int(message.header.numSignatures)
        if (signers.count > numRequiredSignatures) {
            throw SigningError.tooManySigners
        }

        let messageBytes = message.encode()

        var newSignatures = [Signature](repeating: Signature(), count: numRequiredSignatures)
        var index = 0
        signatures.makeIterator().forEach { signature in
            newSignatures[index] = signature
            index += 1
        }
        for it in signers {
            let pubKey = SolanaPublicKey(it.publicKey.bytes)!
            let index = SolanaTransaction.indexOf(message.accounts, pubKey)
            if (index < 0) {
                throw SigningError.accountNotInAccountList(
                    "signing account " +
                            "${pubKey.value.toHexString()} is not in the account list"
                )
            }
            let sig = it.sign([Byte](messageBytes))
            newSignatures[index] = Signature(sig)!
        }

        return SolanaTransaction(message: message, signatures: newSignatures)
    }
    
    init(message: Message, signatures: [Signature]) {
        self.signatures = signatures
        self.message = message
    }


    init?(data: Data) {
        var remData = data

        // Decode `signatures`
        guard let shortVecTuple = try? ShortVec.decodeLength(data) else {
            return nil
        }

        remData = shortVecTuple.remainingData

        var signatures = [Signature]()
        for _ in 0..<shortVecTuple.length {
            let signatureData = remData.subdata(in: 0..<Int(Signature.Length))

            guard let s = Signature(data: signatureData) else {
                return nil
            }

            signatures.append(s)
            remData = remData.subdata(in: Int(Signature.Length)..<remData.count)
        }

        self.signatures = signatures

        // Decode `message`
        guard let message = Message(data: remData) else {
            return nil
        }

        self.message = message
    }

    func encode() -> Data {
        var encoded = Data([Byte]())

        encoded.append(try! ShortVec.encodeLength(signatures.count))
        for s in signatures {
            encoded.append(s.encode())
        }

        encoded.append(message.encode())

        return encoded
    }
    
    public var description: String {
        return "SolanaTransaction(signatures: \(signatures), message: \(message)"
    }
}

/**
 * Provide a unique set by publicKey of AccountMeta with the highest write permission
 */
extension Array where Element == AccountMeta {
    func filterUnique() -> [AccountMeta] {
        var filtered = [AccountMeta]()

        for i in self {
            var found = false
        
            var j = 0
            for accountMeta in filtered {
                if (i.publicKey.value.elementsEqual(accountMeta.publicKey.value)) {
                    // Promote the existing account to writable if applicable
                    if (i.isSigner) {
                        filtered[j] = filtered[j].copy(isSigner: true)
                    }
                    if (i.isWritable) {
                        filtered[j] = filtered[j].copy(isWritable: true)
                    }
                    if (i.isPayer) {
                        filtered[j] = filtered[j].copy(isPayer: true)
                    }
                    found = true
                    break
                }
                j += 1
            }
            if (!found) {
                filtered.append(i)
            }
        }

        return filtered
    }
}

extension Array where Element : Comparable {
    
    mutating func quickSort() {
        quickSort(low: 0, high: self.count - 1)
    }
    
    private mutating func quickSort(low: Int, high: Int) {
        if (low < high) {
            let p = partition(low, high)
            quickSort(low: low, high: p - 1)
            quickSort(low: p + 1, high: high)
        }
    }

    private mutating func partition(
        _ low: Int,
        _ high: Int
    ) -> Int {
        let pivot = self[high]
        var i = low - 1

        for j in low..<high {
            if (self[j] < pivot) {
                i += 1
                self.swap(i, j)
            }
        }

        self.swap(i + 1, high)

        return i + 1
    }

    private mutating func swap(_ i: Int, _ j: Int) {
        let temp = self[i]
        self[i] = self[j]
        self[j] = temp
    }

}
