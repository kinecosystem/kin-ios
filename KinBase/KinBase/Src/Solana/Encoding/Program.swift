//
//  Programs.swift
//  KinSDK
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import CommonCrypto

// MARK: - SystemProgram -

public enum SystemProgram {
    
    public static let systemPublicKey = PublicKey.zero
    
    // Reference: https://github.com/solana-labs/solana/blob/f02a78d8fff2dd7297dc6ce6eb5a68a3002f5359/sdk/src/system_instruction.rs#L58-L72
    public static func createAccountInstruction(subsidizer: PublicKey, address: PublicKey, owner: PublicKey, lamports: UInt64, size: UInt64) -> Instruction {
        // # Account references
        //   0. [WRITE, SIGNER] Funding account
        //   1. [WRITE, SIGNER] New account
        //
        // CreateAccount {
        //   // Number of lamports to transfer to the new account
        //   lamports: u64,
        //   // Number of bytes of memory to allocate
        //   space: u64,
        //
        //   //Address of program that will own the new account
        //   owner: Pubkey,
        // }
        //
        
        var data = Data()
        data.append(contentsOf: Command.createAccount.rawValue.bytes)
        data.append(contentsOf: lamports.bytes)
        data.append(contentsOf: size.bytes)
        data.append(contentsOf: owner.bytes)
        
        return Instruction(
            program: Self.systemPublicKey,
            accounts: [
                .writable(publicKey: subsidizer, signer: true, payer: false),
                .writable(publicKey: address, signer: true, payer: false),
            ],
            data: data
        )
    }
}

extension SystemProgram {
    public enum Command: UInt32 {
        case createAccount
        case assign
        case transfer
        case createAccountWithSeed
        case advanceNonceAccount
        case withdrawNonceAccount
        case initializeNonceAccount
        case authorizeNonceAccount
        case allocate
        case allocateWithSeed
        case assignWithSeed
        case transferWithSeed
    }
}

extension PublicKey {
    static let sysVarRent = PublicKey(base58: "SysvarRent111111111111111111111111111111111")!
}

// MARK: - AssociatedTokenProgram -

enum AssociatedTokenProgram {
    
    static let publicKey = PublicKey(base58: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!
    
    private static let maxSeeds      = 16
    private static let maxSeedLength = 32
    
    // CreateProgramAddress mirrors the implementation of the Solana SDK's CreateProgramAddress.
    //
    // ProgramAddresses are public keys that _do not_ lie on the ed25519 curve to ensure that
    // there is no associated private key. In the event that the program and seed parameters
    // result in a valid public key, ErrInvalidPublicKey is returned.
    //
    // Reference: https://github.com/solana-labs/solana/blob/5548e599fe4920b71766e0ad1d121755ce9c63d5/sdk/program/src/pubkey.rs#L158
    static func deriveProgramAddress(program: PublicKey, seeds: [Data]) -> PublicKey? {
        if seeds.count > maxSeeds {
            return nil
        }
        
        var digest = SHA256()
        
        seeds.forEach { seed in
            digest.update(seed)
        }
        
        digest.update(program.data)
        digest.update("ProgramDerivedAddress")
        
        let publicKey = PublicKey(digest.digestBytes())!
        
        // Following the Solana SDK, we want to _reject_ the generated public key
        // if it's a valid compressed EdwardsPoint (on the curve).
        //
        // Reference: https://github.com/solana-labs/solana/blob/5548e599fe4920b71766e0ad1d121755ce9c63d5/sdk/program/src/pubkey.rs#L182-L187
        guard !publicKey.isOnCurve() else {
            return nil
        }
        
        return publicKey
    }
    
    // FindProgramAddress mirrors the implementation of the Solana SDK's FindProgramAddress. Its primary
    // use case (for Kin and Agora) is for deriving associated accounts.
    //
    // Reference: https://github.com/solana-labs/solana/blob/5548e599fe4920b71766e0ad1d121755ce9c63d5/sdk/program/src/pubkey.rs#L234
    static func findProgramAddress(program: PublicKey, seeds: Data...) -> PublicKey? {
        findProgramAddress(program: program, seeds: seeds)
    }
    
    static func findProgramAddress(program: PublicKey, seeds: [Data]) -> PublicKey? {
        for i in 0...Byte.max {
            let bumpValue = Byte.max - i
            let bumpSeed = Data([bumpValue])
            if let publicKey = deriveProgramAddress(program: program, seeds: seeds + [bumpSeed]) {
                return publicKey
            }
        }
        
        return nil
    }
    
    public static func deriveAssociatedAccount(owner: PublicKey, mint: PublicKey) -> PublicKey? {
        findProgramAddress(
            program: publicKey,
            seeds: owner.data, TokenProgram.publicKey.data, mint.data
        )
    }
}

// MARK: - TokenProgram -

enum TokenProgram {
    
    // Reference: https://github.com/solana-labs/solana-program-library/blob/11b1e3eefdd4e523768d63f7c70a7aa391ea0d02/token/program/src/state.rs#L125
    static let accountSize: UInt64 = 165
    
    // ProgramKey is the address of the token program that should be used.
    //
    // Current key: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
    //
    // todo: lock this in, THIS SHOULD BE ONLY USED FOR TESTING IN THE MEANTIME
    static let publicKey = PublicKey(base58: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!
    
    // Reference: https://github.com/solana-labs/solana-program-library/blob/b011698251981b5a12088acba18fad1d41c3719a/token/program/src/instruction.rs#L41-L55
    public static func initializeAccountInstruction(account: PublicKey, mint: PublicKey, owner: PublicKey, programKey: PublicKey) -> Instruction {
        // Accounts expected by this instruction:
        //
        //   0. `[writable]`  The account to initialize.
        //   1. `[]` The mint this account will be associated with.
        //   2. `[]` The new account's owner/multisignature.
        //   3. `[]` Rent sysvar
        var data = Data()
        data.append(Command.initializeAccount.rawValue)
        
        return Instruction(
            program: programKey,
            accounts: [
                .writable(publicKey: account,     signer: true,  payer: false),
                .readonly(publicKey: mint,        signer: false, payer: false),
                .readonly(publicKey: owner,       signer: false, payer: false),
                .readonly(publicKey: .sysVarRent, signer: false, payer: false),
            ],
            data: data
        )
    }
    
    // todo(feature): support multi-sig
    //
    // Reference: https://github.com/solana-labs/solana-program-library/blob/b011698251981b5a12088acba18fad1d41c3719a/token/program/src/instruction.rs#L76-L91
    public static func transferInstruction(source: PublicKey, destination: PublicKey, owner: PublicKey, amount: Decimal, programKey: PublicKey) -> Instruction {
        // Accounts expected by this instruction:
        //
        //   * Single owner/delegate
        //   0. `[writable]` The source account.
        //   1. `[writable]` The destination account.
        //   2. `[signer]` The source account's owner/delegate.
        //
        //   * Multisignature owner/delegate
        //   0. `[writable]` The source account.
        //   1. `[writable]` The destination account.
        //   2. `[]` The source account's multisignature owner/delegate.
        //   3. ..3+M `[signer]` M signer accounts.
        var data = Data()
        data.append(Command.transfer.rawValue)
        data.append(contentsOf: UInt64(amount.quark).bytes)
        
        return Instruction(
            program: programKey,
            accounts: [
                .writable(publicKey: source,      signer: false, payer: false),
                .writable(publicKey: destination, signer: false, payer: false),
                .writable(publicKey: owner,       signer: true,  payer: false),
            ],
            data: data
        )
    }
    
    public static func setAuthority(account: PublicKey, currentAuthority: PublicKey, newAuthority: PublicKey?, authorityType: AuthorityType, programKey: PublicKey) -> Instruction {
        // Sets a new authority of a mint or account.
        //
        // Accounts expected by this instruction:
        //
        //   * Single authority
        //   0. `[writable]` The mint or account to change the authority of.
        //   1. `[signer]` The current authority of the mint or account.
        //
        //   * Multisignature authority
        //   0. `[writable]` The mint or account to change the authority of.
        //   1. `[]` The mint's or account's multisignature authority.
        //   2. ..2+M `[signer]` M signer accounts
        
        var data = Data()
        data.append(Byte(Command.setAuthority.rawValue))
        data.append(authorityType.rawValue)
        
        if let authority = newAuthority {
            data.append(1)
            data.append(contentsOf: authority.bytes)
        } else {
            data.append(0)
        }
        
        return Instruction(
            program: programKey,
            accounts: [
                .writable(publicKey: account,          signer: false, payer: false),
                .readonly(publicKey: currentAuthority, signer: true,  payer: false),
            ],
            data: data
        )
    }
}

extension TokenProgram {
    public enum Command: Byte {
        case initializeMint
        case initializeAccount
        case initializeMultisig
        case transfer
        case approve
        case revoke
        case setAuthority
        case mintTo
        case burn
        case closeAccount
        case freezeAccount
        case thawAccount
        case transfer2
        case approve2
        case mintTo2
        case burn2
    }
}

extension TokenProgram {
    public enum AuthorityType: Byte {
        case authorityTypeMintTokens
        case authorityFreezeAccount
        case authorityAccountHolder
        case authorityCloseAccount
    }
}

// MARK: - MemoProgram -

enum MemoProgram {
    // ProgramKey is the address of the memo program that should be used.
    //
    // Current key: Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo
    //
    // todo: lock this in, or make configurable
    static let publicKey = PublicKey(base58: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")!
    
    public static func memoInsutruction(with data: Data) -> Instruction {
        Instruction(
            program: publicKey,
            accounts: [],
            data: data
        )
    }
}

// MARK: - Bytes -

extension UInt16 {
    var bytes: [Byte] {
        [
            Byte((self & 0x00000000000000FF) >> 0),
            Byte((self & 0x000000000000FF00) >> 8),
        ]
    }
}

extension UInt32 {
    var bytes: [Byte] {
        [
            Byte((self & 0x00000000000000FF) >> 0),
            Byte((self & 0x000000000000FF00) >> 8),
            Byte((self & 0x0000000000FF0000) >> 16),
            Byte((self & 0x00000000FF000000) >> 24),
        ]
    }
}

extension UInt64 {
    var bytes: [Byte] {
        [
            Byte((self & 0x00000000000000FF) >> 0),
            Byte((self & 0x000000000000FF00) >> 8),
            Byte((self & 0x0000000000FF0000) >> 16),
            Byte((self & 0x00000000FF000000) >> 24),
            Byte((self & 0x000000FF00000000) >> 32),
            Byte((self & 0x0000FF0000000000) >> 40),
            Byte((self & 0x00FF000000000000) >> 48),
            Byte((self & 0xFF00000000000000) >> 56),
        ]
    }
}
