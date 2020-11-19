//
//  Programs.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Base58Swift

struct SystemProgram {
     public static let PROGRAM_KEY = SolanaPublicKey([Byte](repeating: 0, count: 32))!
    
    enum Command : Int {
        case CreateAccount
        case Assign
        case Transfer
        case CreateAccountWithSeed
        case AdvanceNonceAccount
        case WithdrawNonceAccount
        case InitializeNonceAccount
        case AuthorizeNonceAccount
        case Allocate
        case AllocateWithSeed
        case AssignWithSeed
        case TransferWithSeed
    }
    
    // Reference: https://github.com/solana-labs/solana/blob/f02a78d8fff2dd7297dc6ce6eb5a68a3002f5359/sdk/src/system_instruction.rs#L58-L72
    static func createAccountInstruction(
        subsidizer: SolanaPublicKey,
        address: SolanaPublicKey,
        owner: SolanaPublicKey,
        lamports: UInt64,
        size: UInt64
    ) -> SolanaInstruction {
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
        data.append(contentsOf: UInt32(Command.CreateAccount.rawValue).toByteArray()[0..<4])
        data.append(contentsOf: lamports.toByteArray()[0..<8])
        data.append(contentsOf: size.toByteArray()[0..<8])
        data.append(contentsOf: owner.value)

        return SolanaInstruction.newInstruction(
            SystemProgram.PROGRAM_KEY,
            data,
            AccountMeta.newAccountMeta(subsidizer, isSigner: true),
            AccountMeta.newAccountMeta(address, isSigner: true)
        )
    }
}

struct TokenProgram {
    // Reference: https://github.com/solana-labs/solana-program-library/blob/11b1e3eefdd4e523768d63f7c70a7aa391ea0d02/token/program/src/state.rs#L125
    static let accountSize: UInt64 = UInt64(165)
    
    // ProgramKey is the address of the token program that should be used.
    //
    // Current key: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
    //
    // todo: lock this in, THIS SHOULD BE ONLY USED FOR TESTING IN THE MEANTIME
    static let PROGRAM_KEY: SolanaPublicKey = SolanaPublicKey(
       [Byte](arrayLiteral:
           6, 221, 246, 225, 215, 101, 161, 147, 217, 203, 225,
           70, 206, 235, 121, 172, 28, 180, 133, 237, 95, 91, 55,
           145, 58, 140, 245, 133, 126, 255, 0, 169
       )
    )!
    
    static let SYS_VAR_RENT = SolanaPublicKey(Base58.base58Decode("SysvarRent111111111111111111111111111111111")!)!
    
    enum Command : Int {
        case InitializeMint
        case InitializeAccount
        case InitializeMultisig
        case Transfer
        case Approve
        case Revoke
        case SetAuthority
        case MintTo
        case Burn
        case CloseAccount
        case FreezeAccount
        case ThawAccount
        case Transfer2
        case Approve2
        case MintTo2
        case Burn2
    }
    
    // Reference: https://github.com/solana-labs/solana-program-library/blob/b011698251981b5a12088acba18fad1d41c3719a/token/program/src/instruction.rs#L41-L55
    static func initializeAccountInstruction(
        account: SolanaPublicKey,
        mint: SolanaPublicKey,
        owner: SolanaPublicKey,
        programKey: SolanaPublicKey
    ) -> SolanaInstruction {
        // Accounts expected by this instruction:
        //
        //   0. `[writable]`  The account to initialize.
        //   1. `[]` The mint this account will be associated with.
        //   2. `[]` The new account's owner/multisignature.
        //   3. `[]` Rent sysvar
        var data = Data()
        data.append(contentsOf: UInt32(Command.InitializeAccount.rawValue).toByteArray()[0..<1])
        return SolanaInstruction.newInstruction(
                programKey,
                data,
                AccountMeta.newAccountMeta(account, isSigner: true),
                AccountMeta.newReadonlyAccountMeta(mint, isSigner: false),
                AccountMeta.newReadonlyAccountMeta(owner, isSigner: false),
                AccountMeta.newReadonlyAccountMeta(SYS_VAR_RENT, isSigner: false)
            )
    }
    
    // todo(feature): support multi-sig
    //
    // Reference: https://github.com/solana-labs/solana-program-library/blob/b011698251981b5a12088acba18fad1d41c3719a/token/program/src/instruction.rs#L76-L91
    static func transferInstruction(
        source: SolanaPublicKey,
        destination: SolanaPublicKey,
        owner: SolanaPublicKey,
        amount: Kin,
        programKey: SolanaPublicKey
    ) -> SolanaInstruction {
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
        data.append(contentsOf: UInt32(Command.Transfer.rawValue).toByteArray()[0..<1])
        data.append(contentsOf: UInt64(amount.quark).toByteArray()[0..<8])
        
        return SolanaInstruction.newInstruction(
            programKey,
            data,
            AccountMeta.newAccountMeta(source, isSigner: false),
            AccountMeta.newAccountMeta(destination, isSigner: false),
            AccountMeta.newAccountMeta(owner, isSigner: true)
        )
    }
    
    enum AuthorityType: Int {
        case AuthorityTypeMintTokens
        case AuthorityFreezeAccount
        case AuthorityAccountHolder
        case AuthorityCloseAccount
    }

    static func setAuthority(
        account: SolanaPublicKey,
        currentAuthority: SolanaPublicKey,
        newAuthority: SolanaPublicKey?,
        authorityType: AuthorityType,
        programKey: SolanaPublicKey
    ) -> SolanaInstruction {
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
        data.append(Byte(Command.SetAuthority.rawValue))
        data.append(Byte(authorityType.rawValue))
        data.append(Byte(0))

    
        if (newAuthority != nil) {
            data[2] = 1
            data.append(contentsOf: newAuthority!.value)
        }
        return SolanaInstruction.newInstruction(
                programKey,
                data,
                AccountMeta.newAccountMeta(account, isSigner: false),
                AccountMeta.newReadonlyAccountMeta(currentAuthority, isSigner: true)
        )
    }
}

struct MemoProgram {
    // ProgramKey is the address of the memo program that should be used.
    //
    // Current key: Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo
    //
    // todo: lock this in, or make configurable
    static let PROGRAM_KEY: SolanaPublicKey = SolanaPublicKey(
        [Byte](arrayLiteral:
            5, 74, 83, 80, 248, 93, 200, 130, 214, 20, 165, 86, 114, 120, 138, 41, 109, 223,
            30, 171, 171, 208, 166, 6, 120, 136, 73, 50, 244, 238, 246, 160
        )
    )!

    static func memoInsutructionFromBytes(bytes: [Byte]) -> SolanaInstruction {
        return SolanaInstruction.newInstruction(
                   MemoProgram.PROGRAM_KEY,
                   Data(bytes)
               )
    }
}

extension UInt32 {
    func toByteArray()-> [Byte] {
        return [Byte](arrayLiteral:
            Byte(self & 0x00000000000000FF),
            Byte((self & 0x000000000000FF00) >> 8),
            Byte((self & 0x0000000000FF0000) >> 16),
            Byte((self & 0x00000000FF000000) >> 24)
        )
    }
}

extension UInt64 {
    func toByteArray()-> [Byte] {
        return [Byte](arrayLiteral:
            Byte(self & 0x00000000000000FF),
            Byte((self & 0x000000000000FF00) >> 8),
            Byte((self & 0x0000000000FF0000) >> 16),
            Byte((self & 0x00000000FF000000) >> 24),
            Byte((self & 0x000000FF00000000) >> 32),
            Byte((self & 0x0000FF0000000000) >> 40),
            Byte((self & 0x00FF000000000000) >> 48),
            Byte((self & 0xFF00000000000000) >> 56)
        )
    }
}
