//
//  Instruction.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct Instruction: Equatable {
    
    public var program: Key32
    public var accounts: [AccountMeta]
    public var data: Data
    
    public init(program: Key32, accounts: [AccountMeta], data: Data) {
        self.program = program
        self.accounts = accounts
        self.data = data
    }
    
    public func compile(using messageAccounts: [Key32]) -> CompiledInstruction {
        let programIndex = messageAccounts.firstIndex { $0 == program }!
        let accountIndexes = accounts.map { account in
            messageAccounts.firstIndex { $0 == account.publicKey }!
        }
        
        return CompiledInstruction(
            programIndex: programIndex,
            accountIndexes: accountIndexes,
            data: data
        )
    }
}

// MARK: - CompiledInstruction -

public struct CompiledInstruction: Equatable {
    
    public var programIndex: Byte
    public var accountIndexes: [Byte]
    public var data: Data
    
    public var byteLength: Int {
        return
            1 +
            ShortVec.encodeLength(UInt16(accountIndexes.count)).count +
            accountIndexes.count +
            ShortVec.encodeLength(UInt16(data.count)).count +
            data.count
    }
    
    public init(programIndex: Int, accountIndexes: [Int], data: Data) {
        self.init(
            programIndex: Byte(programIndex),
            accountIndexes: accountIndexes.map { Byte($0) },
            data: data
        )
    }
    
    public init(programIndex: Byte, accountIndexes: [Byte], data: Data) {
        self.programIndex = Byte(programIndex)
        self.accountIndexes = accountIndexes.map { Byte($0) }
        self.data = data
    }
}

// MARK: - SolanaCodable -

extension CompiledInstruction: SolanaCodable {
    
    public init?(data: Data) {
        guard data.count > 1 else {
            return nil
        }
        
        var payload = data
        
        let index = payload.consume(1)[0]
        
        var (accountCount, accountData) = ShortVec.decodeLength(payload)
        guard accountData.count >= accountCount else {
            return nil
        }
        
        let accountIndexes = accountData.consume(accountCount).map { $0 }
        
        let (opaqueCount, opaqueData) = ShortVec.decodeLength(accountData)
        guard opaqueData.count >= opaqueCount else {
            return nil
        }
        
        self.programIndex = index
        self.accountIndexes = accountIndexes
        self.data = opaqueData.prefix(opaqueCount)
    }
    
    public func encode() -> Data {
        var container = Data()
        
        container.append(programIndex)
        container.append(
            ShortVec.encode(Data(accountIndexes))
        )
        container.append(
            ShortVec.encode(data)
        )
        
        return container
    }
}
