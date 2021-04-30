//
//  StubObjects.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
import KinGrpcApi
@testable import KinBase

class StubObjects {
    static let accountId1 = "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM"
    static let accountId2 = "GBD2LB2VV2GKLO5RBNJKL7IP3WSN2BK46KSYEMDCYZSWLVA5HC7TYR72"
    static let agoraTestAppAccountId = "GDHCB4VCNNFIMZI3BVHLA2FVASECBR2ZXHOAXEBBFVUH5G2YAD7V3JVH"
    static let badAccountId = "GAXOKOHOUOED5V6PDQP3XNXTJ25Y5DH4MEMY2RRYHYO5F5BVYZ6F7L3D"
    static let androidTestAccountId = "GDOC25WFE2XQBNXCQ6TTI7H4CBS2CRAQ6BBV5VYFG4GUGBZY7QERNIW4"

    static let seed1 = "SA5XMJ7XKHFWO6JYE6IWN7OZIV75QBAXIIO2WBKPEG4Q2VEQ2MEOB6XN"
    static let seed2 = "SDXHKOQBDGQ4GPZN44OQCM242ZEAAWZG5HS6NSSP6NS767RIVJ6VXRAA"

    static var transaction: KinTransaction {
        return historicalTransaction(from: StubObjects.transactionEnvelope)
    }
    
    static let transactionEnvelope = "Ad9R8DcOAY3++Nb9Gw/+fq7Tvjs+/RQ8OxoIBukB0Swvgo/3NnTIf1/uGfuyhV6FDCTs8uBPvKh3oapzcbvvJAABAAEEKxWpzUvvLNgJ5GRXDSpsvZvMZOMupOu890h1e7s91b0by4Gu7Kz0Z6/CD955cKmUzUvH9k+xa24RA03gXlWhgvy2u5ce5eBpFygoKxE2hUKWocS2efFFuCaQyOV3sqmWBt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKmDyDdjjDfBov7h0MpaHivqttZ4XKBzrb4j3/n75GxCrgEDAwECAAkDQEIPAAAAAAA="
    
    static let transactionEnvelopeSigned = "Aj/N3Xno4QQO92Ab4MIJiWj00cNwE82NtQNA1IwFxbM/jZIcv92d4ePIE/gjGk9llwaWGQUHJ+mpjJI8NhNlEAQiXQ6/YSI1om+WUzIcLWYnRcJUsJtX9OAOU47D9ZDkk2f2OnJ/qvRlaSGnimCjVFKM23Ml9gbp+IN9+SrMFLYGAgACBisVqc1L7yzYCeRkVw0qbL2bzGTjLqTrvPdIdXu7PdW9r2ElOFUJmss5cmwSTmASML8X6Eic8np492J99eJ0Wc0GRR5FRbGYg+q57jLv2vAfJzzAYZRj5xOqkGOSlas+k/y2u5ce5eBpFygoKxE2hUKWocS2efFFuCaQyOV3sqmWBUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqUaTBRosmazzBt+auE3/nH0zUJR6f/OjeFILhHLqeMSUAgQALFFRQUFTTy9QaEVxaUpONjc4SHNlU3N2cFFJUG41OWFsY2xZU0Y5cnUyQU09BQMDAgEJA6AlJgAAAAAA"

    static let transactionEvelope1 = "Ad9R8DcOAY3++Nb9Gw/+fq7Tvjs+/RQ8OxoIBukB0Swvgo/3NnTIf1/uGfuyhV6FDCTs8uBPvKh3oapzcbvvJAABAAEEKxWpzUvvLNgJ5GRXDSpsvZvMZOMupOu890h1e7s91b0by4Gu7Kz0Z6/CD955cKmUzUvH9k+xa24RA03gXlWhgvy2u5ce5eBpFygoKxE2hUKWocS2efFFuCaQyOV3sqmWBt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKmDyDdjjDfBov7h0MpaHivqttZ4XKBzrb4j3/n75GxCrgEDAwECAAkDQEIPAAAAAAA="

    static let transactionEvelope2 = "Aj/N3Xno4QQO92Ab4MIJiWj00cNwE82NtQNA1IwFxbM/jZIcv92d4ePIE/gjGk9llwaWGQUHJ+mpjJI8NhNlEAQiXQ6/YSI1om+WUzIcLWYnRcJUsJtX9OAOU47D9ZDkk2f2OnJ/qvRlaSGnimCjVFKM23Ml9gbp+IN9+SrMFLYGAgACBisVqc1L7yzYCeRkVw0qbL2bzGTjLqTrvPdIdXu7PdW9r2ElOFUJmss5cmwSTmASML8X6Eic8np492J99eJ0Wc0GRR5FRbGYg+q57jLv2vAfJzzAYZRj5xOqkGOSlas+k/y2u5ce5eBpFygoKxE2hUKWocS2efFFuCaQyOV3sqmWBUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqUaTBRosmazzBt+auE3/nH0zUJR6f/OjeFILhHLqeMSUAgQALFFRQUFTTy9QaEVxaUpONjc4SHNlU3N2cFFJUG41OWFsY2xZU0Y5cnUyQU09BQMDAgEJA6AlJgAAAAAA"

    static let transactionResult1 = "AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA="

    static let transationResponse1 = """
        {
          "memo": "",
          "_links": {
            "self": {
              "href": "http://horizon-testnet.kininfrastructure.com/transactions/129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5"
            },
            "account": {
              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ"
            },
            "ledger": {
              "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5965143"
            },
            "operations": {
              "href": "http://horizon-testnet.kininfrastructure.com/transactions/129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5/operations{?cursor,limit,order}",
              "templated": true
            },
            "effects": {
              "href": "http://horizon-testnet.kininfrastructure.com/transactions/129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5/effects{?cursor,limit,order}",
              "templated": true
            },
            "precedes": {
              "href": "http://horizon-testnet.kininfrastructure.com/transactions?order=asc\\u0026cursor=25620094100967424"
            },
            "succeeds": {
              "href": "http://horizon-testnet.kininfrastructure.com/transactions?order=desc\\u0026cursor=25620094100967424"
            }
          },
          "id": "129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5",
          "paging_token": "25620094100967424",
          "hash": "129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5",
          "ledger": 5965143,
          "created_at": "2020-04-16T01:09:42Z",
          "source_account": "GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ",
          "source_account_sequence": "25620076921094145",
          "fee_paid": 100,
          "operation_count": 1,
          "envelope_xdr": "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4=",
          "result_xdr": "AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=",
          "result_meta_xdr": "AAAAAAAAAAEAAAAEAAAAAwBbBVMAAAAAAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAADuaygAAWwVTAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbBVcAAAAAAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAADwzYIAAWwVTAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwBbBVcAAAAAAAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAADuayZwAWwVTAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbBVcAAAAAAAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAADsCMxwAWwVTAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA",
          "fee_meta_xdr": "AAAAAgAAAAMAWwVTAAAAAAAAAADsxURfR6gDtK1eX4/sNYygYDkdpzm6fYOxDANvxwksewAAAAA7msoAAFsFUwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAWwVXAAAAAAAAAADsxURfR6gDtK1eX4/sNYygYDkdpzm6fYOxDANvxwksewAAAAA7msmcAFsFUwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==",
          "memo_type": "text",
          "signatures": [
            "DSK4A1RxLBmdKUEFsRJUOcMA1voGQeYkCjDpk0ho1qJZfTKQGCzLFuoMsxu22qLEIHM1+omDVcO5Vs7WNgE8Dg=="
          ]
        }
    """

    static let stubInvoiceList1: InvoiceList =
        try! InvoiceList(invoices: [StubObjects.stubInvoice,
                                    StubObjects.stubInvoice])

    static let stubInvoiceList2: InvoiceList =
        try! InvoiceList(invoices: [StubObjects.stubInvoice])

    static let stubInvoice: Invoice =
        try! Invoice(lineItems: [StubObjects.stubLineItem])

    static let stubLineItem: LineItem =
        try! LineItem(title: "title",
                      description: "desc",
                      amount: Kin(123),
                      sku: SKU(bytes: [1, 3, 0]))

    static let stubInvoiceListProto: APBCommonV3InvoiceList = {
        let invoiceList = APBCommonV3InvoiceList()
        invoiceList.invoicesArray = [StubObjects.stubInvoiceProto]
        return invoiceList
    }()

    static let stubInvoiceProto: APBCommonV3Invoice = {
        let invoice = APBCommonV3Invoice()
        invoice.itemsArray = [StubObjects.stubLineItemProto, StubObjects.stubLineItemProto]
        return invoice
    }()

    static let stubLineItemProto: APBCommonV3Invoice_LineItem = {
        let item = APBCommonV3Invoice_LineItem()
        item.amount = 10
        item.title = "title"
        item.description_p = "description"
        return item
    }()

    static func inFlightTransaction(from envelope: String) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .inFlight(ts: Date().timeIntervalSince1970),
                                   network: .testNet)
    }

    static func ackedTransaction(from envelope: String, withInvoice: Bool = false) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .acknowledged(ts: Date().timeIntervalSince1970,
                                                         resultXdrBytes: [0, 1, 2]),
                                   network: .testNet,
                                   invoiceList: withInvoice ? stubInvoiceList1 : nil)
    }

    static func historicalTransaction(from envelope: String) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .historical(ts: 123456789,
                                                       resultXdrBytes: [2, 1],
                                                       pagingToken: "pagingtoken"),
                                   network: .testNet)
    }
}


