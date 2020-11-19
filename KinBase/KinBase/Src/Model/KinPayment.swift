//
//  KinPayment.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct KinPayment: Equatable {
    public struct Id: Equatable {
        public let transactionHash: KinTransactionHash
        public let offset: UInt8

        public var value: [Byte] {
            return transactionHash.rawValue + [offset]
        }
    }

    public enum Status: Int {
        case inFlight
        case success
        case error
    }

    public typealias Addendum = [Byte]

    public let id: Id
    public let status: Status
    public let sourceAccountId: KinAccount.Id
    public let destAccountId: KinAccount.Id
    public let amount: Kin
    public let fee: Quark
    public let memo: KinMemo
    public let timestamp: TimeInterval
    public let extra: Addendum? = nil
    public let error: Error? = nil
    public let invoice: Invoice?

    public static func == (lhs: KinPayment, rhs: KinPayment) -> Bool {
        return lhs.id == rhs.id &&
            lhs.status == rhs.status &&
            lhs.sourceAccountId == rhs.sourceAccountId &&
            lhs.destAccountId == rhs.destAccountId &&
            lhs.amount == rhs.amount &&
            lhs.fee == rhs.fee &&
            lhs.timestamp == rhs.timestamp &&
            lhs.extra == rhs.extra &&
            lhs.invoice == rhs.invoice
    }
}

public struct KinPaymentItem {
    public let amount: Kin
    public let destAccountId: KinAccount.Id
    public let invoice: Invoice?

    public init(amount: Kin,
                destAccountId: KinAccount.Id,
                invoice: Invoice? = nil) {
        self.amount = amount
        self.destAccountId = destAccountId
        self.invoice = invoice
    }
    
    public func copy(amount: Kin? = nil, destAccountId: KinAccount.Id? = nil, invoice: Invoice? = nil) -> KinPaymentItem {
        return KinPaymentItem(amount: amount ?? self.amount, destAccountId: destAccountId ?? self.destAccountId, invoice: invoice ?? self.invoice)
    }
}
