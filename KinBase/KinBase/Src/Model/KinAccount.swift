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

public class KinAccount : CustomStringConvertible {

    public enum Status {
        case unregistered
        case registered
    }

    public var publicKey: PublicKey
    public var privateKey: PrivateKey?

//    public var id: String {
//        get {
//            return publicKey.base58
//        }
//    }
    
    public var tokenAccounts: [PublicKey]

    public var balance: KinBalance

    public var status: Status

    /// The sequence number on a registered account
    public var sequence: Int64?

    init(publicKey: PublicKey, privateKey: PrivateKey? = nil, balance: KinBalance = KinBalance.zero, status: Status = .unregistered, sequence: Int64? = nil, tokenAccounts: [PublicKey] = []) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.balance = balance
        self.status = status
        self.sequence = sequence
        self.tokenAccounts = tokenAccounts
    }
    
    public func copy(publicKey: PublicKey? = nil, balance: KinBalance? = nil, status: Status? = nil, sequence: Int64? = nil, tokenAccounts: [PublicKey]? = nil) -> KinAccount {
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
        "KinAccount(key=\(publicKey), balance=\(balance), status=\(status), sequence=\(String(describing: sequence)), accounts=\(tokenAccounts)))"
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

//extension KinAccount: TransactionAccount {
//    public var keyPair: KeyPair {
//        return key
//    }
//
//    public var sequenceNumber: Int64 {
//        return sequence ?? 0
//    }
//
//    public func incrementedSequenceNumber() -> Int64 {
//        return sequenceNumber + 1
//    }
//
//    public func incrementSequenceNumber() {
//        sequence = sequence != nil ? sequence! + 1 : nil
//    }
//}

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
