//
//  Transaction.swift
//  KinSDK
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

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

public protocol SolanaCodable {
    init?(data: Data)
    func encode() -> Data
}

public struct Transaction {
    
    public private(set) var message: Message
    public private(set) var signatures: [Signature]
    
    // MARK: - Init -
    
    public init(message: Message, signatures: [Signature]) {
        self.signatures = signatures
        self.message = message
    }
    
    public init(payer: Key32, instructions: Instruction...) {
        self.init(
            payer: payer,
            instructions: instructions
        )
    }
    
    public init(payer: Key32, instructions: [Instruction]) {
        var accounts: [AccountMeta] = []
        
        accounts.append(
            AccountMeta.writable(publicKey: payer, signer: true, payer: true)
        )
        
        // Extract all of the unique accounts from the instructions.
        instructions.forEach {
            accounts.append(
                AccountMeta.program(publicKey: $0.program)
            )
            accounts.append(contentsOf: $0.accounts)
        }
        
        // Sort the account meta's based on:
        //   1. Payer is always the first account / signer.
        //   1. All signers are before non-signers.
        //   2. Writable accounts before read-only accounts.
        //   3. Programs last
        let uniqueAccounts = accounts.filterUniqueAccounts().sorted()
        
        let signers = uniqueAccounts.filter { $0.isSigner }
        let readOnlySigned = uniqueAccounts.filter { !$0.isWritable && $0.isSigner }
        let readOnly = uniqueAccounts.filter { !$0.isWritable && !$0.isSigner }
        
        let header = MessageHeader(
            signatureCount: signers.count,
            readOnlySignedCount: readOnlySigned.count,
            readOnlyCount: readOnly.count
        )
        
        let accountPublicKeys = uniqueAccounts.map { $0.publicKey }
        let messageInstructions = instructions.map { $0.compile(using: accountPublicKeys) }
        
        let message = Message(
            header: header,
            accounts: accountPublicKeys,
            recentBlockhash: Hash.zero,
            instructions: messageInstructions
        )
        
        self.init(
            message: message,
            signatures: []
        )
    }
    
    public func updatingBlockhash(_ hash: Hash) -> Transaction {
        var transaction = self
        transaction.message.recentBlockhash = hash
        return transaction
    }
    
    public func updatingSignature(signature: Signature) -> Transaction {
        var transaction = self
        transaction.signatures.remove(at: 0)
        transaction.signatures.insert(signature, at: 0)
        return transaction
    }
    
    // MARK: - Signing -
    
    public func signing(using keyPairs: KeyPair...) throws -> Transaction {
        let requiredSignatureCount = message.header.signatureCount
        if keyPairs.count > requiredSignatureCount {
            throw SigningError.tooManySigners
        }
        
        let messageData = message.encode()
        
        var signatures = [Signature](repeating: Signature.zero, count: requiredSignatureCount)
        self.signatures.enumerated().forEach { index, signature in
            signatures[index] = signature
        }
        
        for keyPair in keyPairs {
            let key = Key32(keyPair.publicKey.bytes)!
            
            guard let signatureIndex = message.accounts.firstIndex(of: key) else {
                throw SigningError.accountNotInAccountList("Account: \(key)")
            }
            
            let signature = keyPair.sign(messageData.bytes)
            signatures[signatureIndex] = Signature(signature)!
        }
        
        return Transaction(message: message, signatures: signatures)
    }
}

// MARK: - SolanaCodable -

extension Transaction: SolanaCodable {
    
    public init?(data: Data) {
        let (signatureCount, payload) = ShortVec.decodeLength(data)
        
        guard payload.count >= signatureCount * Signature.length else {
            return nil // Mismatched data
        }
        
        let signatures = payload.chunk(size: Signature.length, count: signatureCount) { Signature($0) }?.compactMap { $0 } ?? []
        let messageData = payload.tail(from: signatureCount * Signature.length)
        
        guard let message = Message(data: messageData) else {
            return nil
        }
        
        self.signatures = signatures
        self.message = message
    }
    
    public func encode() -> Data {
        var data = Data()
        
        data.append(
            ShortVec.encode(signatures.map { $0.data })
        )
        
        data.append(message.encode())
        
        return data
    }
}

extension Transaction {
    public enum SigningError: Error {
        case tooManySigners
        case accountNotInAccountList(_ reason: String)
        case invalidKey
    }
}

/**
 * Provide a unique set by publicKey of AccountMeta with the highest write permission
 */
extension Array where Element == AccountMeta {
    
    func filterUniqueAccounts() -> [AccountMeta] {
        var container: [AccountMeta] = []
        for account in self {
            var found = false
            
            for (index, existingAccount) in container.enumerated() {
                if account.publicKey == existingAccount.publicKey {
                    var updatedAccount = existingAccount
                    
                    // Promote the existing account to writable if applicable
                    if account.isSigner {
                        updatedAccount.isSigner = true
                    }
                    
                    if account.isWritable {
                        updatedAccount.isWritable = true
                    }
                    
                    if account.isPayer {
                        updatedAccount.isPayer = true
                    }
                    
                    container[index] = updatedAccount
                    found = true
                    break
                }
            }
            
            if !found {
                container.append(account)
            }
        }
        
        return container
    }
}
