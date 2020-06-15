//
//  KinAccount.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public class KinAccount {
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

    public var balance: KinBalance

    public var status: Status

    /// The sequence number on a registered account
    public var sequence: Int64?

    init(key: Key,
         balance: KinBalance = KinBalance.zero,
         status: Status = .unregistered,
         sequence: Int64? = nil) {
        self.key = key
        self.balance = balance
        self.status = status
        self.sequence = sequence
    }
}

extension KinAccount: Equatable {
    public static func == (lhs: KinAccount, rhs: KinAccount) -> Bool {
        return lhs.id == rhs.id &&
            lhs.key == rhs.key &&
            lhs.balance == rhs.balance &&
            lhs.status == rhs.status &&
            lhs.sequence == rhs.sequence
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
                          sequence: account.sequence)
    }
}
