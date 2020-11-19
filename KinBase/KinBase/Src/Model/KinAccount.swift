//
//  KinAccount.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

extension KeyPair: CustomStringConvertible {
    public var description: String {
        return "KeyPair(accountId=\(accountId), secretSeed=XXXXXXXX<Private>XXXXXXXX)"
    }
}

public class KinAccount : CustomStringConvertible {
    public typealias Key = KeyPair
    public typealias Id = String

    public enum Status {
        case unregistered
        case registered
    }

    public var key: Key

    public var id: Id {
        get {
            return key.accountId
        }
    }
    
    public var tokenAccounts: [Key]

    public var balance: KinBalance

    public var status: Status

    /// The sequence number on a registered account
    public var sequence: Int64?

    init(key: Key,
         balance: KinBalance = KinBalance.zero,
         status: Status = .unregistered,
         sequence: Int64? = nil,
         tokenAccounts: [Key] = [Key]()) {
        self.key = key
        self.balance = balance
        self.status = status
        self.sequence = sequence
        self.tokenAccounts = tokenAccounts
    }
    
    public func copy(key: Key? = nil,
         balance: KinBalance? = nil,
         status: Status? = nil,
         sequence: Int64? = nil,
         tokenAccounts: [Key]? = nil) -> KinAccount {
        return KinAccount(key: key ?? self.key, balance: balance ?? self.balance, status: status ?? self.status, sequence: sequence ?? self.sequence, tokenAccounts: tokenAccounts ?? self.tokenAccounts)
    }
    
    public var description: String {
        get {
            return "KinAccount(id=\(id)), key=\(key), balance=\(balance), status=\(status), sequence=\(String(describing: sequence)), accounts=\(tokenAccounts)))"
        }
    }
}

extension KinAccount: Equatable {
    public static func == (lhs: KinAccount, rhs: KinAccount) -> Bool {
        return lhs.id == rhs.id &&
            lhs.key == rhs.key &&
            lhs.balance == rhs.balance &&
            lhs.status == rhs.status &&
            lhs.sequence == rhs.sequence &&
            lhs.tokenAccounts == rhs.tokenAccounts
    }
}

extension KinAccount: TransactionAccount {
    public var keyPair: KeyPair {
        return key
    }

    public var sequenceNumber: Int64 {
        return sequence ?? 0
    }

    public func incrementedSequenceNumber() -> Int64 {
        return sequenceNumber + 1
    }

    public func incrementSequenceNumber() {
        sequence = sequence != nil ? sequence! + 1 : nil
    }
}

extension KinAccount {
    /// Merges self.key with other info on the given account
    /// - Parameter account: account info will be kept
    public func merge(_ account: KinAccount) -> KinAccount {
        return KinAccount(key: key,
                          balance: account.balance,
                          status: account.status,
                          sequence: account.sequence,
                          tokenAccounts: account.tokenAccounts)
    }
}
