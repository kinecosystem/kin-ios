//
//  Instruction.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/**
* AccountMeta represents the account information required
* for building transactions.
*/
public struct AccountMeta {
    var publicKey: SolanaPublicKey
    var isSigner: Bool
    var isWritable: Bool
    var isPayer: Bool
    var isProgram: Bool
    
    init(publicKey: SolanaPublicKey, isSigner: Bool = false, isWritable: Bool = false, isPayer: Bool = false, isProgram: Bool = false) {
        self.publicKey = publicKey
        self.isSigner = isSigner
        self.isWritable = isWritable
        self.isPayer = isPayer
        self.isProgram = isProgram
    }
    
    static func newAccountMeta(
        _ publicKey: SolanaPublicKey,
        isSigner: Bool,
        isPayer: Bool = false,
        isProgram: Bool = false
    ) -> AccountMeta {
        return AccountMeta(
            publicKey: publicKey,
            isSigner: isSigner,
            isWritable: true,
            isPayer: isPayer,
            isProgram: isProgram
        )
    }
    
    static func newReadonlyAccountMeta(
        _ publicKey: SolanaPublicKey,
        isSigner: Bool,
        isPayer: Bool = false,
        isProgram: Bool = false
    ) -> AccountMeta {
        return AccountMeta(
            publicKey: publicKey,
            isSigner: isSigner,
            isWritable: false,
            isPayer: isPayer,
            isProgram: isProgram
        )
    }
}

extension AccountMeta: Comparable {
    public static func == (lhs: AccountMeta, rhs: AccountMeta) -> Bool {
        return lhs.publicKey == rhs.publicKey &&
            lhs.isSigner == rhs.isSigner &&
            lhs.isWritable == rhs.isWritable &&
            lhs.isPayer == rhs.isPayer &&
            lhs.isProgram == rhs.isProgram
    }
    
    public static func < (lhs: AccountMeta, rhs: AccountMeta) -> Bool {
        if (lhs.isPayer != rhs.isPayer) {
            return lhs.isPayer
        }
        if (lhs.isProgram != rhs.isProgram) {
            return !lhs.isProgram
        }
        if (lhs.isSigner != rhs.isSigner) {
            return lhs.isSigner
        }
        if (lhs.isWritable != rhs.isWritable) {
            return lhs.isWritable
        }

        return false
    }
}

extension AccountMeta {
    func copy(publicKey: SolanaPublicKey? = nil, isSigner: Bool? = nil, isWritable: Bool? = nil, isPayer: Bool? = nil, isProgram: Bool? = nil) -> AccountMeta {
        return AccountMeta(publicKey: publicKey ?? self.publicKey, isSigner: isSigner ?? self.isSigner, isWritable: isWritable ?? self.isWritable, isPayer: isPayer ?? self.isPayer, isProgram: isProgram ?? self.isProgram)
    }
}

/**
* SolanaInstruction represents a transaction instruction.
*/
public struct SolanaInstruction {
    var program: SolanaPublicKey
    var accounts: [AccountMeta]
    var data: Data
    
    private init(_ program: SolanaPublicKey, _ accounts: [AccountMeta], _ data: Data) {
        self.program = program
        self.accounts = accounts
        self.data = data
    }
    
    // newInstruction creates a new instruction.
    static func newInstruction(
        _ program: SolanaPublicKey,
        _ data: Data,
        _ accounts: AccountMeta...
    ) -> SolanaInstruction {
        return SolanaInstruction(
            program,
            accounts,
            data
        )
    }
}

public struct CompiledInstruction: SolanaCodable {
    var programIndex: Byte
    var accounts: ByteArray
    var data: ByteArray

    init(programIndex: Byte,
         accounts: ByteArray,
         data: ByteArray) {
        self.programIndex = programIndex
        self.accounts = accounts
        self.data = data
    }

    init?(data: Data) {
        var array = [Byte](data)

        // Decoding `programIdIndex`
        self.programIndex = array.shift()!

        // Decoding `accounts`
        let shortVecTuple = try! ShortVec.decodeLength(Data(array))
        self.accounts = ByteArray(data: Data(array))!

        let shortVecEncodedLength = try! ShortVec.encodeLength(shortVecTuple.length).count
        array.removeSubrange(0..<(shortVecEncodedLength + shortVecTuple.length))
        
        // Decoding `data`
        self.data = ByteArray(data: Data(array))!
    }

    func encode() -> Data {
        var encoded = Data([programIndex])
    
        encoded.append(accounts.encode())
        
        encoded.append(data.encode())

        return encoded
    }

    public static func == (lhs: CompiledInstruction, rhs: CompiledInstruction) -> Bool {
        return lhs.programIndex == rhs.programIndex &&
            lhs.accounts == rhs.accounts &&
            lhs.data == rhs.data
    }
    
    public var description: String {
        "CompiledInstruction(programIndex: \(Int(programIndex)), accounts: \(accounts.value), data: \(data.value)"
    }
}
