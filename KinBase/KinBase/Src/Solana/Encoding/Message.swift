//
//  Message.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-03.
//

import Foundation

public struct Message: Equatable {
    
    public var header: MessageHeader
    public var accounts: [Key32]
    public var recentBlockhash: Hash
    public var instructions: [CompiledInstruction]
    
    // MARK: - Init -
    
    public init(header: MessageHeader, accounts: [Key32], recentBlockhash: Hash, instructions: [CompiledInstruction]) {
        self.header = header
        self.accounts = accounts
        self.recentBlockhash = recentBlockhash
        self.instructions = instructions
    }
}

// MARK: - SolanaCodable -

extension Message: SolanaCodable {
    
    public init?(data: Data) {
        var payload = data
        
        // Decode `header`
        guard let header = MessageHeader(data: payload.consume(MessageHeader.length)) else {
            return nil
        }
        
        // Decode `accountKeys`
        let (accountCount, accountData) = ShortVec.decodeLength(payload)
        guard let keys = accountData.chunk(size: Key32.length, count: accountCount, block: { Key32($0)! }) else {
            return nil
        }
        
        payload = accountData.tail(from: Key32.length * accountCount)
        
        // Decode `recentBlockHash`
        guard let hash = Hash(payload.consume(Hash.length)) else {
            return nil
        }
        
        // Decode `instructions`
        let (instructionCount, instructionsData) = ShortVec.decodeLength(payload)
        
        var remainingData = instructionsData
        var instructions: [CompiledInstruction] = []
        
        for _ in 0..<instructionCount {
            guard let instruction = CompiledInstruction(data: remainingData) else {
                return nil
            }
            
            guard instruction.programIndex < keys.count else {
                return nil
            }
            
            remainingData = remainingData.tail(from: instruction.byteLength)
            instructions.append(instruction)
        }
        
        self.header = header
        self.accounts = keys
        self.recentBlockhash = hash
        self.instructions = instructions
    }
    
    public func encode() -> Data {
        var data = Data()
        
        data.append(header.encode())
        data.append(
            ShortVec.encode(accounts.map { $0.data })
        )
        data.append(recentBlockhash.data)
        data.append(
            ShortVec.encode(instructions.map { $0.encode() })
        )
        
        return data
    }
}
