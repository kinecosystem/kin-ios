//
//  ProtoToModel.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

extension Int64 {
    var kinBalance: KinBalance {
        return KinBalance(Quark(self).kin)
    }
}

extension APBAccountV4AccountInfo {
    var kinAccount: KinAccount? {
        guard let publicKey = PublicKey(accountId.value) else {
            return nil
        }

        return KinAccount(
            publicKey: publicKey,
            balance: balance.kinBalance,
            status: .registered,
            sequence: 0
        )
    }
}

extension APBCommonV4SolanaAccountId {
    var publicKey: PublicKey {
        return PublicKey(value)!
    }
}

extension APBTransactionV4HistoryItem {
    func toKinTransactionHistorical(network: KinNetwork) -> KinTransaction? {
        let record = Record.historical(
            ts: Date().timeIntervalSince1970,
            pagingToken: cursor.value.base64EncodedString()
        )

        let invoices: InvoiceList? = hasInvoiceList ? invoiceList.invoiceList : nil


        var bytes: [Byte]

        if ([Byte](solanaTransaction.value).count != 0) {
            bytes =  [Byte](solanaTransaction.value)
            return try? KinTransaction(
                envelopeXdrBytes: bytes,
                record: record,
                network: network,
                invoiceList: invoices
            )
        } else {
            bytes = [Byte](stellarTransaction.envelopeXdr)
            return try? KinTransaction(
                envelopeXdrBytes: bytes,
                record: record,
                network: network,
                invoiceList: invoices,
                historyItem: self
            )
        }
    }
}

extension APBTransactionV4SignTransactionResponse {
    func toKinTransactionAcknowledged(solanaTransaction: Transaction, network: KinNetwork) -> KinTransaction? {

        let record = Record.acknowledged(ts: Date().timeIntervalSince1970)

        return try? KinTransaction(
            envelopeXdrBytes: [Byte](solanaTransaction.encode()),
            record: record,
            network: network
        )
    }
}

extension APBTransactionV4SubmitTransactionResponse {
    func toKinTransactionAcknowledged(solanaTransaction: Transaction, network: KinNetwork) -> KinTransaction? {

        let record = Record.acknowledged(ts: Date().timeIntervalSince1970)

        return try? KinTransaction(
            envelopeXdrBytes: [Byte](solanaTransaction.encode()),
            record: record,
            network: network
        )
    }
}

extension APBAccountV4TransactionEvent {
    func toKinTransactionAcknowledged(network: KinNetwork) -> KinTransaction? {
        guard hasTransaction && !hasTransactionError else {
            return nil
        }

        let record = Record.acknowledged(ts: Date().timeIntervalSince1970)

        return try? KinTransaction(
            envelopeXdrBytes: [Byte](transaction.value),
            record: record,
            network: network
        )
    }
}

extension APBCommonV3Invoice_LineItem {
    var lineItem: LineItem? {
        try? LineItem(
            title: title,
            description: description_p,
            amount: amount.kin,
            sku: sku != nil ? SKU(bytes: [Byte](sku)) : nil
        )
    }
}

extension APBCommonV3Invoice {
    var invoice: Invoice? {
        guard itemsArray.count > 0 else {
            return nil
        }

        let lineItems = itemsArray.compactMap { item -> LineItem? in
            return (item as? APBCommonV3Invoice_LineItem)?.lineItem
        }

        return try? Invoice(lineItems: lineItems)
    }
}

extension APBCommonV3InvoiceList {
    var invoiceList: InvoiceList? {
        guard invoicesArray_Count > 0 else {
            return nil
        }

        let invoices = invoicesArray.compactMap { invoice -> Invoice? in
            return (invoice as? APBCommonV3Invoice)?.invoice
        }

        return try? InvoiceList(invoices: invoices)
    }
}

extension APBCommonV3InvoiceError {
    var invoiceError: InvoiceError? {
        guard let modelInvoice = invoice.invoice else {
            return nil
        }

        return InvoiceError(
            operationIndex: Int(opIndex),
            invoice: modelInvoice,
            reason: reason.reason
        )
    }
}

extension APBCommonV3InvoiceError_Reason {
    var reason: InvoiceError.Reason {
        switch self {
        case .alreadyPaid:
            return .alreadyPaid
        case .wrongDestination:
            return .wrongDestination
        case .skuNotFound:
            return .skuNotFound
        default:
            return .unknown
        }
    }
}
