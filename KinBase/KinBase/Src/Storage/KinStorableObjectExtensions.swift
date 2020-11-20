//
//  KinStorableObjectExtensions.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
import KinGrpcApi

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
            return KinStorageKinAccount_Status.registered
        case .unregistered:
            return KinStorageKinAccount_Status.unregistered
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
        storable.accountsArray = NSMutableArray(array: tokenAccounts.map { it in it.publicKey.storableObject })
        return storable
    }
}

extension Record.RecordType {
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

extension Dictionary where Key == InvoiceList.Id, Value == InvoiceList {
    var storableObject: KinStorageInvoices {
        var invoiceLists = [String : KinStorageInvoiceListBlob]()
        self.forEach { (key: SHA224Hash, value: InvoiceList) in
            invoiceLists[key.encodedValue] = value.storableObject
        }

        let storable = KinStorageInvoices()
        storable.invoiceLists = NSMutableDictionary(dictionary: invoiceLists)
        return storable
    }
}

extension InvoiceList {
    public var storableObject: KinStorageInvoiceListBlob {
        let storable = KinStorageInvoiceListBlob()
        storable.networkInvoiceList = self.proto.data()
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
        switch self.rawValue {
        case KinStorageKinAccount_Status.registered.rawValue:
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
        var tokenAccounts = [KinAccount.Key]()
        accountsArray.forEach { it in
            if let element = it as? KinStoragePublicKey {
                tokenAccounts.append(KinAccount.Key(publicKey:element.publicKey!))
            }
        }
        let account = KinAccount(key: key,
                                 balance: kinBalance,
                                 status: status.kinAccountStatus,
                                 sequence: sequenceNumber,
                                 tokenAccounts: tokenAccounts)
        return account
    }
}

extension KinStorageKinTransaction_Status {
    var kinTransactionRecordType: Record.RecordType {
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
        let record: Record
        switch status.kinTransactionRecordType {
        case .inFlight:
            record = .inFlight(ts: TimeInterval(timestamp))
        case .acknowledged:
            record = .acknowledged(ts: TimeInterval(timestamp),
                                   resultXdrBytes: [Byte](resultXdr))
        case .historical:
            record = .historical(ts: TimeInterval(timestamp),
                                 resultXdrBytes: [Byte](resultXdr),
                                 pagingToken: pagingToken)
        }

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

extension KinStorageInvoices {
    var invoicesMap: [InvoiceList.Id: InvoiceList] {
        guard let invoices = invoiceLists as? [String: KinStorageInvoiceListBlob] else {
            return [:]
        }

        var map = [InvoiceList.Id: InvoiceList]()

        invoices.forEach { (key: String, value: KinStorageInvoiceListBlob) in
            map[SHA224Hash(encodedValue: key)] = value.invoiceList
        }

        return map
    }
}

extension KinStorageInvoiceListBlob {
    public var invoiceList: InvoiceList? {
        guard networkInvoiceList != nil,
            let protoInvoiceList = try? APBCommonV3InvoiceList(data: networkInvoiceList) else {
            return nil
        }

        return protoInvoiceList.invoiceList
    }
}
