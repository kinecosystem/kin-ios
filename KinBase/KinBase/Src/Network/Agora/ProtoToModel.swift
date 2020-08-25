//
//  ProtoToModel.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

extension Int64 {
    var kinBalance: KinBalance {
        return KinBalance(Quark(self).kin)
    }
}

extension APBAccountV3AccountInfo {
    var kinAccount: KinAccount? {
        guard let key = try? KinAccount.Key(accountId: accountId.value) else {
            return nil
        }

        return KinAccount(key: key,
                          balance: balance.kinBalance,
                          status: .registered,
                          sequence: sequenceNumber)
    }
}

extension APBTransactionV3HistoryItem {
    func toKinTransactionHistorical(network: KinNetwork) -> KinTransaction? {
        let record = KinTransaction.Record.historical(ts: Date().timeIntervalSince1970,
                                                      resultXdrBytes: [Byte](resultXdr),
                                                      pagingToken: String(bytes: cursor.value, encoding: .utf8) ?? "")

        let invoices: InvoiceList? = hasInvoiceList ? invoiceList.invoiceList : nil

        let transaction = try? KinTransaction(envelopeXdrBytes: [Byte](envelopeXdr),
                                              record: record,
                                              network: network,
                                              invoiceList: invoices)

        return transaction
    }
}

extension APBTransactionV3SubmitTransactionResponse {
    func toKinTransactionAcknowledged(envelopeXdrFromRequest: String,
                                      network: KinNetwork) -> KinTransaction? {
        guard !resultXdr.isEmpty else {
            return nil
        }

        let record = KinTransaction.Record.acknowledged(ts: Date().timeIntervalSince1970,
                                                        resultXdrBytes: [Byte](resultXdr))

        guard let envelopeXdr = Data(base64Encoded: envelopeXdrFromRequest) else {
            return nil
        }

        return try? KinTransaction(envelopeXdrBytes: [Byte](envelopeXdr),
                                   record: record,
                                   network: network)
    }
}

extension APBAccountV3TransactionEvent {
    func toKinTransactionAcknowledged(network: KinNetwork) -> KinTransaction? {
        guard !envelopeXdr.isEmpty && !resultXdr.isEmpty else {
            return nil
        }

        let record = KinTransaction.Record.acknowledged(ts: Date().timeIntervalSince1970,
                                                        resultXdrBytes: [Byte](resultXdr))

        return try? KinTransaction(envelopeXdrBytes: [Byte](envelopeXdr),
                                   record: record,
                                   network: network)
    }
}

extension APBCommonV3Invoice_LineItem {
    var lineItem: LineItem? {
        return try? LineItem(title: title,
                             description: description_p,
                             amount: amount.kin,
                             sku: sku != nil ? SKU(bytes: [Byte](sku)) : nil)
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

extension APBTransactionV3SubmitTransactionResponse_InvoiceError {
    var invoiceError: InvoiceError? {
        guard let modelInvoice = invoice.invoice else {
            return nil
        }

        return InvoiceError(operationIndex: Int(opIndex),
                            invoice: modelInvoice,
                            reason: reason.reason)
    }
}

extension APBTransactionV3SubmitTransactionResponse_InvoiceError_Reason {
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
