//
//  BaseTransaction.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

public class Transaction {

    let transaction: KinTransaction

    init(transaction: KinTransaction) {
        self.transaction = transaction
    }

    public static let MaxMemoLength = 28

    public var fee: Quark {
        return Quark(transaction.fee)
    }

    public func hash(networkId: Network.Id) throws -> Data {
        guard let hash = transaction.transactionHash else {
            throw StellarError.missingHash
        }

        return hash.data
    }

    public var sequenceNumber: UInt64 {
        return UInt64(transaction.sequenceNumber)
    }

    public var sourcePublicAddress: String {
        return transaction.sourceAccount
    }

    public func envelope() -> TransactionEnvelope {
        return TransactionEnvelope(envelopeXdrBytes: transaction.envelopeXdrBytes, transaction: transaction)
    }

    public func whitelistPayload(networkId: Network.Id) -> WhitelistEnvelope {
        return WhitelistEnvelope(transactionEnvelope: envelope(), networkId: networkId)
    }
}
