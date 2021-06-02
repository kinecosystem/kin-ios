//
//  AccountMeta.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-04.
//

import Foundation

public struct AccountMeta {
    
    public var publicKey: Key32
    public var isSigner: Bool
    public var isWritable: Bool
    public var isPayer: Bool
    public var isProgram: Bool
    
    private init(publicKey: Key32, signer: Bool, writable: Bool, payer: Bool, program: Bool) {
        self.publicKey = publicKey
        self.isSigner = signer
        self.isWritable = writable
        self.isPayer = payer
        self.isProgram = program
    }
    
    public static func writable(publicKey: Key32, signer: Bool = false, payer: Bool = false) -> AccountMeta {
        AccountMeta(
            publicKey: publicKey,
            signer: signer,
            writable: true,
            payer: payer,
            program: false
        )
    }
    
    public static func readonly(publicKey: Key32, signer: Bool = false, payer: Bool = false) -> AccountMeta {
        AccountMeta(
            publicKey: publicKey,
            signer: signer,
            writable: false,
            payer: payer,
            program: false
        )
    }
    
    public static func program(publicKey: Key32, signer: Bool = false, writable: Bool = false) -> AccountMeta {
        AccountMeta(
            publicKey: publicKey,
            signer: signer,
            writable: writable,
            payer: false,
            program: true
        )
    }
}

// MARK: - Comparable -

extension AccountMeta: Comparable {
    public static func <(lhs: AccountMeta, rhs: AccountMeta) -> Bool {
        if lhs.isPayer != rhs.isPayer {
            return lhs.isPayer
        }
        
        if lhs.isProgram != rhs.isProgram {
            return !lhs.isProgram
        }
        
        if lhs.isSigner != rhs.isSigner {
            return lhs.isSigner
        }
        
        if lhs.isWritable != rhs.isWritable {
            return lhs.isWritable
        }
        
        return lhs.publicKey.base58 < rhs.publicKey.base58
    }
}
