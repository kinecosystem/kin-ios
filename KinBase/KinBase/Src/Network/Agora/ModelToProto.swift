//
//  ModelToProto.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

extension CreateAccountRequest {
    var protoRequest: APBAccountV3CreateAccountRequest {
        let protoAccountId = APBCommonV3StellarAccountId()
        protoAccountId.value = accountId

        let request = APBAccountV3CreateAccountRequest()
        request.accountId = protoAccountId

        return request
    }
}

extension GetAccountRequest {
    var protoRequest: APBAccountV3GetAccountInfoRequest {
        let protoAccountId = APBCommonV3StellarAccountId()
        protoAccountId.value = accountId

        let request = APBAccountV3GetAccountInfoRequest()
        request.accountId = protoAccountId

        return request
    }
}

extension GetTransactionHistoryRequest {
    var protoRequest: APBTransactionV3GetHistoryRequest {
        let protoAccountId = APBCommonV3StellarAccountId()
        protoAccountId.value = accountId

        let request = APBTransactionV3GetHistoryRequest()
        request.accountId = protoAccountId

        if let cursor = cursor {
            let protoCursor = APBTransactionV3Cursor()
            protoCursor.value = cursor.data(using: .utf8)
            request.cursor = protoCursor
        }

        switch order {
        case .ascending:
            request.direction = .asc
        case .descending:
            request.direction = .desc
        }

        return request
    }
}

extension KinTransactionHash {
    var proto: APBCommonV3TransactionHash {
        let hash = APBCommonV3TransactionHash()
        hash.value = data
        return hash
    }
}

extension GetTransactionRequest {
    var protoRequest: APBTransactionV3GetTransactionRequest {
        let request = APBTransactionV3GetTransactionRequest()
        request.transactionHash = transactionHash.proto
        return request
    }
}

extension SubmitTransactionRequest {
    var protoRequest: APBTransactionV3SubmitTransactionRequest {
        let request = APBTransactionV3SubmitTransactionRequest()
        request.envelopeXdr = Data(base64Encoded: transactionEnvelopeXdr)
        request.invoiceList = invoiceList?.proto
        return request
    }
}

extension KinAccount.Id {
    var proto: APBCommonV3StellarAccountId {
        let accountId = APBCommonV3StellarAccountId()
        accountId.value = self
        return accountId
    }
}

extension LineItem {
    var proto: APBCommonV3Invoice_LineItem {
        let protoLineItem = APBCommonV3Invoice_LineItem()
        protoLineItem.title = title
        protoLineItem.description_p = description
        protoLineItem.amount = amount.quark
        protoLineItem.sku = sku != nil ? Data(sku!.bytes) : nil
        return protoLineItem
    }
}

extension Array where Element == LineItem {
    var protoInvoice: APBCommonV3Invoice {
        let protoInvoice = APBCommonV3Invoice()
        let itemsArray = NSMutableArray(array: self.map { item -> APBCommonV3Invoice_LineItem in
            return item.proto
        })
        protoInvoice.itemsArray = itemsArray
        return protoInvoice
    }
}

extension Invoice {
    var proto: APBCommonV3Invoice {
        return lineItems.protoInvoice
    }
}

extension Array where Element == Invoice {
    var protoInvoiceList: APBCommonV3InvoiceList {
        let protoInvoiceList = APBCommonV3InvoiceList()
        let invoicesArray = NSMutableArray(array: self.map { item -> APBCommonV3Invoice in
            return item.proto
        })
        protoInvoiceList.invoicesArray = invoicesArray
        return protoInvoiceList
    }
}

extension InvoiceList {
    var proto: APBCommonV3InvoiceList {
        return invoices.protoInvoiceList
    }
}
