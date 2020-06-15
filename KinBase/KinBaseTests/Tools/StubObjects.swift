//
//  StubObjects.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
@testable import KinBase

class StubObjects {
    static let accountId1 = "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM"
    static let accountId2 = "GBD2LB2VV2GKLO5RBNJKL7IP3WSN2BK46KSYEMDCYZSWLVA5HC7TYR72"

    static let seed1 = "SA5XMJ7XKHFWO6JYE6IWN7OZIV75QBAXIIO2WBKPEG4Q2VEQ2MEOB6XN"
    static let seed2 = "SDXHKOQBDGQ4GPZN44OQCM242ZEAAWZG5HS6NSSP6NS767RIVJ6VXRAA"

    static var transaction: KinTransaction {
        return historicalTransaction(from: StubObjects.transactionEvelope1)
    }

    static let transactionEvelope1 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDpSBbgeceq6/vcEh3/blqn0qNYo4q8DLHes4DADOPzunvSjREWBeKJC9SdaKhtCnrcv3J04V1MVmdN5iDQ5HcP"

    static let transactionEvelope2 = "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4="

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

    static func inFlightTransaction(from envelope: String) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .inFlight(ts: Date().timeIntervalSince1970),
                                   network: .testNet)
    }

    static func ackedTransaction(from envelope: String) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .acknowledged(ts: Date().timeIntervalSince1970,
                                                         resultXdrBytes: [0, 1, 2]),
                                   network: .testNet)
    }

    static func historicalTransaction(from envelope: String) -> KinTransaction {
        return try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: envelope)!),
                                   record: .historical(ts: 123456789,
                                                       resultXdrBytes: [2, 1],
                                                       pagingToken: "pagingtoken"),
                                   network: .testNet)
    }
}


