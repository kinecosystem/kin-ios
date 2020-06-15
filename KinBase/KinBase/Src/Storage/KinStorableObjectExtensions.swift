//
//  KinStorableObjectExtensions.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

// MARK: Models to KinStorage Objects
extension PublicKey {
    var storableObject: KinStoragePublicKey {
        let storable = KinStoragePublicKey()
        storable.value = Data(bytes)
        return storable
    }
}

extension KinBalance {
    var storableObject: KinStorageKinBalance {
        let storable = KinStorageKinBalance()
        storable.quarkAmount = amount.quark
        storable.pendingQuarkAmount = pendingAmount.quark
        return storable
    }
}

extension KinAccount.Status {
    var storableObject: KinStorageKinAccount_Status {
        switch self {
        case .registered:
            return .registered
        case .unregistered:
            return .unregistered
        }
    }
}

extension KinAccount {
    var storableObject: KinStorageKinAccount {
        let storable = KinStorageKinAccount()
        storable.publicKey = key.publicKey.storableObject
        storable.balance = balance.storableObject
        storable.status = status.storableObject
        storable.sequenceNumber = sequence ?? 0
        return storable
    }
}

extension KinTransaction.Record.RecordType {
    var storableObject: KinStorageKinTransaction_Status {
        switch self {
        case .inFlight:
            return .inflight
        case .acknowledged:
            return .acknowledged
        case .historical:
            return .historical
        }
    }
}

extension KinTransaction {
    var storableObject: KinStorageKinTransaction {
        let storable = KinStorageKinTransaction()
        storable.envelopeXdr = Data(envelopeXdrBytes)
        storable.status = record.recordType.storableObject
        storable.resultXdr = record.resultXdrBytes != nil ? Data(record.resultXdrBytes!) : nil
        storable.timestamp = Int64(record.timestamp)
        storable.pagingToken = record.pagingToken
        return storable
    }
}

extension KinTransactions {
    var storableObject: KinStorageKinTransactions {
        let storable = KinStorageKinTransactions()
        let storableItems = items.map { $0.storableObject }
        storable.itemsArray = NSMutableArray(array: storableItems)
        storable.headPagingToken = headPagingToken
        storable.tailPagingToken = tailPagingToken
        return storable
    }
}

// MARK: KinStorage Objects to Models
extension KinStoragePublicKey {
    var publicKey: PublicKey? {
        return try? PublicKey([Byte](value))
    }
}

extension KinStorageKinBalance {
    var kinBalance: KinBalance {
        return KinBalance(amount: Quark(quarkAmount).kin, pendingAmount: Quark(pendingQuarkAmount).kin)
    }
}

extension KinStorageKinAccount_Status {
    var kinAccountStatus: KinAccount.Status {
        switch self {
        case .registered:
            return .registered
        default:
            return .unregistered
        }
    }
}

extension KinStorageKinAccount {
    var kinAccount: KinAccount? {
        guard hasPublicKey, let pk = publicKey.publicKey else {
            return nil
        }

        let key = KinAccount.Key(publicKey: pk)
        let kinBalance = hasBalance ? balance.kinBalance : KinBalance.zero
        let account = KinAccount(key: key,
                                 balance: kinBalance,
                                 status: status.kinAccountStatus,
                                 sequence: sequenceNumber)
        return account
    }
}

extension KinStorageKinTransaction_Status {
    var kinTransactionRecordType: KinTransaction.Record.RecordType {
        switch self {
        case .inflight:
            return .inFlight
        case .acknowledged:
            return .acknowledged
        case .historical:
            return .historical
        default:
            return .inFlight
        }
    }
}

extension KinStorageKinTransaction {
    func kinTransaction(network: KinNetwork) -> KinTransaction? {
        let record = KinTransaction.Record(recordType: status.kinTransactionRecordType,
                                           timestamp: TimeInterval(timestamp),
                                           resultXdrBytes: [Byte](resultXdr),
                                           pagingToken: pagingToken)
        return try? KinTransaction(envelopeXdrBytes: [Byte](envelopeXdr),
                                   record: record,
                                   network: network)
    }
}

extension KinStorageKinTransactions {
    func kinTransactions(network: KinNetwork) -> KinTransactions? {
        let transactions = itemsArray.compactMap { item -> KinTransaction? in
            return (item as? KinStorageKinTransaction)?.kinTransaction(network: network)
        }

        return KinTransactions(items: transactions,
                               headPagingToken: headPagingToken ?? "",
                               tailPagingToken: tailPagingToken ?? "")
    }
}
