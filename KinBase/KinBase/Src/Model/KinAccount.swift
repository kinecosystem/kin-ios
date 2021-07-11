//
//  KinAccount.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

extension KeyPair: CustomStringConvertible {
    public var description: String {
        return "KeyPair(accountId=\(publicKey.base58), secretSeed=XXXXXXXX<Private>XXXXXXXX)"
    }
}

public struct AccountDescription: Equatable {
    var publicKey: PublicKey
    var balance: Kin?
    var closeAuthority: PublicKey?
}

public struct KinAccount: CustomStringConvertible {

    public var publicKey: PublicKey
    public var privateKey: PrivateKey?
    
    public var tokenAccounts: [AccountDescription]

    public var balance: KinBalance

    public var status: Status

    /// The sequence number on a registered account
    public var sequence: Int64?

    init(publicKey: PublicKey, privateKey: PrivateKey? = nil, balance: KinBalance = KinBalance.zero, status: Status = .unregistered, sequence: Int64? = nil, tokenAccounts: [AccountDescription] = []) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.balance = balance
        self.status = status
        self.sequence = sequence
        self.tokenAccounts = tokenAccounts
    }
    
    public func copy(publicKey: PublicKey? = nil, balance: KinBalance? = nil, status: Status? = nil, sequence: Int64? = nil, tokenAccounts: [AccountDescription]? = nil) -> KinAccount {
        KinAccount(
            publicKey: publicKey ?? self.publicKey,
            privateKey: self.privateKey,
            balance: balance ?? self.balance,
            status: status ?? self.status,
            sequence: sequence ?? self.sequence,
            tokenAccounts: tokenAccounts ?? self.tokenAccounts
        )
    }
    
    public var description: String {
        """
        KinAccount
          key: \(publicKey.base58)
          balance: \(balance)
          status: \(status)
          sequence: \(String(describing: sequence))
          accounts: \(tokenAccounts.map { $0.publicKey.base58 })))
        """
    }
}

extension KinAccount {
    public enum Status {
        case unregistered
        case registered
    }
}

extension KinAccount: Equatable {
    public static func == (lhs: KinAccount, rhs: KinAccount) -> Bool {
        return lhs.publicKey == rhs.publicKey &&
            lhs.privateKey == rhs.privateKey &&
            lhs.balance == rhs.balance &&
            lhs.status == rhs.status &&
            lhs.sequence == rhs.sequence &&
            lhs.tokenAccounts == rhs.tokenAccounts
    }
}

extension KinAccount {
    /// Merges self.key with other info on the given account
    /// - Parameter account: account info will be kept
    public func merge(_ account: KinAccount) -> KinAccount {
        return KinAccount(
            publicKey: publicKey,
            privateKey: privateKey,
            balance: account.balance,
            status: account.status,
            sequence: account.sequence,
            tokenAccounts: account.tokenAccounts
        )
    }
}

// MARK: - export account for BackupRestoreModule -
extension KinAccount {
    /**
         Export the account data as a JSON string.  The seed is encrypted.
         - Parameter passphrase: The passphrase with which to encrypt the seed
         - Returns: A JSON representation of the data as a string
         */
    public func export(passphrase: String) throws -> String {
        guard let salt = KeyUtils.salt() else {
            throw KeyUtilsError.unknownError
        }
        let keyHash = try KeyUtils.keyHash(passphrase: passphrase, salt: salt)
        guard let pk = privateKey else {
            throw KeyUtilsError.encodingFailed("missing private key")
        }
        guard let encryptedSeed = KeyUtils.encryptSeed(pk.bytes, secretKey: keyHash) else {
            throw KeyUtilsError.hashingFailed
        }
        let seed = Data(encryptedSeed).hexEncodedString()
        let accountData = KeyUtils.AccountData(pkey: publicKey.base58, seed: seed, salt: salt, extra: nil)
        guard let jsonString = try String(data: JSONEncoder().encode(accountData), encoding: .utf8) else {
            throw KeyUtilsError.encodingFailed("invalid AccountData")
        }
        return jsonString
    }
}
