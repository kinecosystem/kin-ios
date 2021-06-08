//
//  ModelToProto.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

extension CreateAccountRequestV4 {
    var protoRequest: APBAccountV4CreateAccountRequest {
        let t = APBCommonV4Transaction()
        t.value = transaction.encode()

        let request = APBAccountV4CreateAccountRequest()
        request.transaction = t
        request.commitment = APBCommonV4Commitment.single

        return request
    }
}

extension GetAccountRequestV4 {
    var protoRequest: APBAccountV4GetAccountInfoRequest {
        let request = APBAccountV4GetAccountInfoRequest()
        request.accountId = account.solanaAccountId

        return request
    }
}

extension ResolveTokenAccountsRequestV4 {
    var protoRequest: APBAccountV4ResolveTokenAccountsRequest {
        let request = APBAccountV4ResolveTokenAccountsRequest()
        request.accountId = account.solanaAccountId
        request.includeAccountInfo = true
        
        return request
    }
}

extension GetMinimumKinVersionRequestV4 {
    var protoRequest: APBTransactionV4GetMinimumKinVersionRequest {
        let request = APBTransactionV4GetMinimumKinVersionRequest()
        return request
    }
}

extension GetServiceConfigRequestV4 {
    var protoRequest: APBTransactionV4GetServiceConfigRequest {
        return APBTransactionV4GetServiceConfigRequest()
    }
}

extension GetMinimumBalanceForRentExemptionRequestV4 {
    var protoRequest: APBTransactionV4GetMinimumBalanceForRentExemptionRequest {
        let request = APBTransactionV4GetMinimumBalanceForRentExemptionRequest()
        request.size = size
        
        return request
    }
}

extension GetTransactionHistoryRequestV4 {
    var protoRequest: APBTransactionV4GetHistoryRequest {
        let request = APBTransactionV4GetHistoryRequest()
        request.accountId = account.solanaAccountId

        if let cursor = cursor {
            let protoCursor = APBTransactionV4Cursor()
            protoCursor.value = Data(base64Encoded: cursor)
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

extension SubmitTransactionRequestV4 {
    var protoRequest: APBTransactionV4SubmitTransactionRequest {
        let request = APBTransactionV4SubmitTransactionRequest()
        request.transaction = APBCommonV4Transaction()
        request.transaction.value = transaction.encode()
        request.invoiceList = invoiceList?.proto
        request.commitment = APBCommonV4Commitment.recent
        
        return request
    }
}

extension GetRecentBlockHashRequestV4 {
    var protoRequest: APBTransactionV4GetRecentBlockhashRequest {
        return APBTransactionV4GetRecentBlockhashRequest()
    }
}

extension KinTransactionHash {
    var proto: APBCommonV3TransactionHash {
        let hash = APBCommonV3TransactionHash()
        hash.value = data
        return hash
    }
    
    var protoV4: APBCommonV4TransactionId {
        let hash = APBCommonV4TransactionId()
        hash.value = data
        return hash
    }
}

extension AirdropRequest {
    var protoRequest: APBAirdropV4RequestAirdropRequest {
        let request = APBAirdropV4RequestAirdropRequest()
        request.accountId = account.solanaAccountId
        request.quarks = UInt64(kin.quark)
        request.commitment = APBCommonV4Commitment.single
        
        return request
    }
}

extension GetTransactionRequestV4 {
    var protoRequest: APBTransactionV4GetTransactionRequest {
        let request = APBTransactionV4GetTransactionRequest()
        request.transactionId = transactionHash.protoV4
        request.commitment = APBCommonV4Commitment.single
        
        return request
    }
}

extension PublicKey {
    var proto: APBCommonV3StellarAccountId {
        let accountId = APBCommonV3StellarAccountId()
        accountId.value = base58
        return accountId
    }
}

extension PublicKey {
    var solanaAccountId: APBCommonV4SolanaAccountId{
        let accountId = APBCommonV4SolanaAccountId()
        accountId.value = data
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
