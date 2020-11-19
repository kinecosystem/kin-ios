//
//  HorizonKinApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc. on 2020-03-30.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class HorizonKinApiTests: XCTestCase {

    var mockStellarSdk: MockStellarSdkProxy!
    var sut: HorizonKinApi!

    override func setUp() {
        mockStellarSdk = MockStellarSdkProxy(network: .testNet)
        sut = HorizonKinApi(stellarSdkProxy: mockStellarSdk)
    }
    
    func testGetAccountSucceed() {
        let string = """
                        {
                          "_links": {
                            "self": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM"
                            },
                            "transactions": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/transactions{?cursor,limit,order}",
                              "templated": true
                            },
                            "operations": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/operations{?cursor,limit,order}",
                              "templated": true
                            },
                            "payments": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/payments{?cursor,limit,order}",
                              "templated": true
                            },
                            "effects": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/effects{?cursor,limit,order}",
                              "templated": true
                            },
                            "offers": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/offers{?cursor,limit,order}",
                              "templated": true
                            },
                            "trades": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/trades{?cursor,limit,order}",
                              "templated": true
                            },
                            "data": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM/data/{key}",
                              "templated": true
                            }
                          },
                          "id": "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                          "paging_token": "",
                          "account_id": "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                          "sequence": "24497836326387718",
                          "subentry_count": 0,
                          "last_modified_ledger": 5737898,
                          "thresholds": {
                            "low_threshold": 0,
                            "med_threshold": 0,
                            "high_threshold": 0
                          },
                          "flags": {
                            "auth_required": false,
                            "auth_revocable": false,
                            "auth_immutable": false
                          },
                          "balances": [
                            {
                              "balance": "9999.99400",
                              "buying_liabilities": "0.00000",
                              "selling_liabilities": "0.00000",
                              "asset_type": "native"
                            }
                          ],
                          "signers": [
                            {
                              "public_key": "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                              "weight": 1,
                              "key": "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                              "type": "ed25519_public_key"
                            }
                          ],
                          "data": {}
                        }
                    """
        let data = string.data(using: .utf8)
        let accountResponseStub = try! JSONDecoder().decode(AccountResponse.self, from: data!)
        let accountResponseEnum = AccountResponseEnum.success(details: accountResponseStub)
        mockStellarSdk.stubAccountResponse = accountResponseEnum

        let expect = expectation(description: "callback")
        let accountId = StubObjects.accountId1
        let expectAccount = KinAccount(key: try! KinAccount.Key(accountId: accountId),
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let request = GetAccountRequest(accountId: accountId)

        sut.getAccount(request: request) { (response) in
            XCTAssertEqual(response.result, GetAccountResponse.Result.ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.account, expectAccount)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountNetworkError() {
        let accountResponseEnum = AccountResponseEnum.failure(error: HorizonRequestError.requestFailed(message: "unknown"))
        mockStellarSdk.stubAccountResponse = accountResponseEnum

        let expect = expectation(description: "callback")
        let accountId = StubObjects.accountId1
        let request = GetAccountRequest(accountId: accountId)

        sut.getAccount(request: request) { (response) in
            XCTAssertEqual(response.result, GetAccountResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountUpgradeRequired() {
        let accountResponseEnum = AccountResponseEnum.failure(error: HorizonRequestError.serverGone(message: "", horizonErrorResponse: nil))
        mockStellarSdk.stubAccountResponse = accountResponseEnum

        let expect = expectation(description: "callback")
        let accountId = StubObjects.accountId1
        let request = GetAccountRequest(accountId: accountId)

        sut.getAccount(request: request) { (response) in
            XCTAssertEqual(response.result, GetAccountResponse.Result.upgradeRequired)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStreamAccountSucceed() {
        let key = try! KeyPair(secretSeed: StubObjects.seed1)

        let accountDataString = "{\"_links\":{\"self\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ\"},\"transactions\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/transactions{?cursor,limit,order}\",\"templated\":true},\"operations\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/operations{?cursor,limit,order}\",\"templated\":true},\"payments\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/payments{?cursor,limit,order}\",\"templated\":true},\"effects\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/effects{?cursor,limit,order}\",\"templated\":true},\"offers\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/offers{?cursor,limit,order}\",\"templated\":true},\"trades\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/trades{?cursor,limit,order}\",\"templated\":true},\"data\":{\"href\":\"http://horizon-testnet.kininfrastructure.com/accounts/GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ/data/{key}\",\"templated\":true}},\"id\":\"GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ\",\"paging_token\":\"\",\"account_id\":\"GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ\",\"sequence\":\"26545062552797197\",\"subentry_count\":0,\"last_modified_ledger\":6276840,\"thresholds\":{\"low_threshold\":0,\"med_threshold\":0,\"high_threshold\":0},\"flags\":{\"auth_required\":false,\"auth_revocable\":false,\"auth_immutable\":false},\"balances\":[{\"balance\":\"6809.98600\",\"buying_liabilities\":\"0.00000\",\"selling_liabilities\":\"0.00000\",\"asset_type\":\"native\"}],\"signers\":[{\"public_key\":\"GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ\",\"weight\":1,\"key\":\"GDUDMQAZWQ26U2M63CIQJ5HLZW4QVPUNYXYSM4Q2UHOKH63OFXJG27SJ\",\"type\":\"ed25519_public_key\"}],\"data\":{}}"

        let stubAccountResponse = try! JSONDecoder().decode(AccountResponse.self, from: accountDataString.data(using: .utf8)!)
        let stubAccountStreamItem = MockAccountsStreamItem(baseURL: "", subpath: "")

        stubAccountStreamItem.stubResponse = .response(id: "", data: stubAccountResponse)

        mockStellarSdk.stubAccountsStreamItem = stubAccountStreamItem

        let expectStreamResponse = expectation(description: "callback")
        expectStreamResponse.expectedFulfillmentCount = 1

        let accountObservable = sut.streamAccount(key.accountId)
            .subscribe { returnedAccount in
                XCTAssertEqual(key.accountId, returnedAccount.id)
                XCTAssertEqual(KinBalance(Kin(6809.98600)), returnedAccount.balance)
                expectStreamResponse.fulfill()
        }

        waitForExpectations(timeout: 1)

        accountObservable.dispose()
    }

    func testSubmitTransactionSucceed() {
        let envelopeXdr = "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4="
        let responseString = """
                                {
                                  "_links": {
                                    "transaction": {
                                      "href": "http://horizon-testnet.kininfrastructure.com/transactions/129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5"
                                    }
                                  },
                                  "hash": "129f77a0ffac2f3759f9f9cad5af7c36d02c5c49252f9b051eb883409f5cc4d5",
                                  "ledger": 5965143,
                                  "envelope_xdr": "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4=",
                                  "result_xdr": "AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=",
                                  "result_meta_xdr": "AAAAAAAAAAEAAAAEAAAAAwBbBVMAAAAAAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAADuaygAAWwVTAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbBVcAAAAAAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAADwzYIAAWwVTAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwBbBVcAAAAAAAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAADuayZwAWwVTAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbBVcAAAAAAAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAADsCMxwAWwVTAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"
                                }
                            """
        let data = responseString.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        let transactionResponse = try! jsonDecoder.decode(SubmitTransactionResponse.self, from: data!)
        let transactionResponseEnum = TransactionPostResponseEnum.success(details: transactionResponse)
        mockStellarSdk.stubTransactionPostResponse = transactionResponseEnum

        let expect = expectation(description: "callback")
        let expectTransaction = try! transactionResponse.toAcknowledgedKinTransaction(network: .testNet)
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: envelopeXdr)

        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.kinTransaction?.envelopeXdrBytes, expectTransaction.envelopeXdrBytes)
            XCTAssertEqual(response.kinTransaction?.record.recordType, expectTransaction.record.recordType)
            XCTAssertEqual(response.kinTransaction?.record.resultXdrBytes, expectTransaction.record.resultXdrBytes)
            XCTAssertEqual(response.kinTransaction?.resultCode, ResultCode.success)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionNetworkError() {
        let envelopeXdr = StubObjects.transactionEvelope1
        let transactionResponseEnum = TransactionPostResponseEnum.failure(error: HorizonRequestError.requestFailed(message: "unknown"))
        mockStellarSdk.stubTransactionPostResponse = transactionResponseEnum

        let expect = expectation(description: "callback")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: envelopeXdr)

        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionUpgradeRequired() {
        let envelopeXdr = StubObjects.transactionEvelope1
        let transactionResponseEnum = TransactionPostResponseEnum.failure(error: HorizonRequestError.serverGone(message: "", horizonErrorResponse: nil))
        mockStellarSdk.stubTransactionPostResponse = transactionResponseEnum

        let expect = expectation(description: "callback")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: envelopeXdr)

        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.upgradeRequired)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionBadRequest() {
        let data = Data(base64Encoded: "ewogICJ0eXBlIjogImh0dHBzOi8vc3RlbGxhci5vcmcvaG9yaXpvbi1lcnJvcnMvdHJhbnNhY3Rpb25fZmFpbGVkIiwKICAidGl0bGUiOiAiVHJhbnNhY3Rpb24gRmFpbGVkIiwKICAic3RhdHVzIjogNDAwLAogICJkZXRhaWwiOiAiVGhlIHRyYW5zYWN0aW9uIGZhaWxlZCB3aGVuIHN1Ym1pdHRlZCB0byB0aGUgc3RlbGxhciBuZXR3b3JrLiBUaGUgYGV4dHJhcy5yZXN1bHRfY29kZXNgIGZpZWxkIG9uIHRoaXMgcmVzcG9uc2UgY29udGFpbnMgZnVydGhlciBkZXRhaWxzLiAgRGVzY3JpcHRpb25zIG9mIGVhY2ggY29kZSBjYW4gYmUgZm91bmQgYXQ6IGh0dHBzOi8vd3d3LnN0ZWxsYXIub3JnL2RldmVsb3BlcnMvbGVhcm4vY29uY2VwdHMvbGlzdC1vZi1vcGVyYXRpb25zLmh0bWwiLAogICJleHRyYXMiOiB7CiAgICAiZW52ZWxvcGVfeGRyIjogIkFBQUFBT2cyUUJtME5lcHBudGlSQlBUcnpia0t2bzNGOFNaeUdxSGNvL3R1TGRKdEFBQUFaQUJlVHBnQUFBQXNBQUFBQUFBQUFBRUFBQUFBQUFBQUFRQUFBQUVBQUFBQTZEWkFHYlExNm1tZTJKRUU5T3ZOdVFxK2pjWHhKbklhb2R5aisyNHQwbTBBQUFBQkFBQUFBTHRiaVR1U21mUE9OL0hxVjZvYVR1Z3RpOTZITjVhYW5DUGFmNTZCR2dmTEFBQUFBQUFBQUFKVUMrUUFBQUFBQUFBQUFBRnVMZEp0QUFBQVFGTkRIWExLVEZrT0dBRWx5cXhLdnZWZ0poZzg3bnFlVlVXNS8yV0xoWDUvUXcwSFN1eGFnZzROQmtkS0hCSnRtRFNUSTNmWGo4TUNrWGVKd1FWbHVBaz0iLAogICAgInJlc3VsdF9jb2RlcyI6IHsKICAgICAgInRyYW5zYWN0aW9uIjogInR4X2ZhaWxlZCIsCiAgICAgICJvcGVyYXRpb25zIjogWwogICAgICAgICJvcF91bmRlcmZ1bmRlZCIKICAgICAgXQogICAgfSwKICAgICJyZXN1bHRfeGRyIjogIkFBQUFBQUFBQUdULy8vLy9BQUFBQVFBQUFBQUFBQUFCLy8vLy9nQUFBQUE9IgogIH0KfQ==")
        let badRequestErrorResponse = try! JSONDecoder().decode(BadRequestErrorResponse.self, from: data!)

        let transactionResponseEnum = TransactionPostResponseEnum.failure(error: HorizonRequestError.badRequest(message: "bad request", horizonErrorResponse: badRequestErrorResponse))
        mockStellarSdk.stubTransactionPostResponse = transactionResponseEnum

        let envelopeXdr = StubObjects.transactionEvelope1

        let expect = expectation(description: "callback")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: envelopeXdr)

        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.insufficientBalance)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetTransactionSucceed() {
        let responseString = StubObjects.transationResponse1
        let responseData = responseString.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        let transactionResponse = try! jsonDecoder.decode(TransactionResponse.self, from: responseData!)
        let transactionResponseEnum = TransactionDetailsResponseEnum.success(details: transactionResponse)
        mockStellarSdk.stubTransactionDetailsResponse = transactionResponseEnum

        let expectTransaction = try! transactionResponse.toHistoricalKinTransaction(network: .testNet)
        let data = try! Transaction(envelopeXdr: expectTransaction.envelopeXdrString).getTransactionHashData(network: KinNetwork.testNet.stellarNetwork)
        let transactionHash = KinTransactionHash(data)
        let request = GetTransactionRequest(transactionHash: transactionHash)

        let expect = expectation(description: "callback")

        sut.getTransaction(request: request) { (response) in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.kinTransaction, expectTransaction)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionNetworkError() {
        let transactionResponseEnum = TransactionDetailsResponseEnum.failure(error: HorizonRequestError.requestFailed(message: "unknown"))
        mockStellarSdk.stubTransactionDetailsResponse = transactionResponseEnum

        let expectTransaction = try! Transaction(envelopeXdr: "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4=")
        let data = try! expectTransaction.getTransactionHashData(network: KinNetwork.testNet.stellarNetwork)
        let transactionHash = KinTransactionHash(data)
        let request = GetTransactionRequest(transactionHash: transactionHash)

        let expect = expectation(description: "callback")

        sut.getTransaction(request: request) { (response) in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionUpgradeRequired() {
        let transactionResponseEnum = TransactionDetailsResponseEnum.failure(error: HorizonRequestError.serverGone(message: "", horizonErrorResponse: nil))
        mockStellarSdk.stubTransactionDetailsResponse = transactionResponseEnum

        let expectTransaction = try! Transaction(envelopeXdr: "AAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAZABbBVMAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAABAAAAAEE14+z9KYW9IT2Qgdpwth9IqeNZZcQzMJwy1OMeIywbAAAAAAAAAAAAmJaAAAAAAAAAAAHHCSx7AAAAQA0iuANUcSwZnSlBBbESVDnDANb6BkHmJAow6ZNIaNaiWX0ykBgsyxbqDLMbttqixCBzNfqJg1XDuVbO1jYBPA4=")
        let data = try! expectTransaction.getTransactionHashData(network: KinNetwork.testNet.stellarNetwork)
        let transactionHash = KinTransactionHash(data)
        let request = GetTransactionRequest(transactionHash: transactionHash)

        let expect = expectation(description: "callback")

        sut.getTransaction(request: request) { (response) in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.upgradeRequired)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionMinFeeSucceed() {
        let string = """
                        {
                          "_links": {
                            "self": {
                              "href": "http://horizon-testnet.kininfrastructure.com/ledgers?cursor=\\u0026limit=1\\u0026order=desc"
                            },
                            "next": {
                              "href": "http://horizon-testnet.kininfrastructure.com/ledgers?cursor=25667914266836992\\u0026limit=1\\u0026order=desc"
                            },
                            "prev": {
                              "href": "http://horizon-testnet.kininfrastructure.com/ledgers?cursor=25667914266836992\\u0026limit=1\\u0026order=asc"
                            }
                          },
                          "_embedded": {
                            "records": [
                              {
                                "_links": {
                                  "self": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5976277"
                                  },
                                  "transactions": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5976277/transactions{?cursor,limit,order}",
                                    "templated": true
                                  },
                                  "operations": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5976277/operations{?cursor,limit,order}",
                                    "templated": true
                                  },
                                  "payments": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5976277/payments{?cursor,limit,order}",
                                    "templated": true
                                  },
                                  "effects": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5976277/effects{?cursor,limit,order}",
                                    "templated": true
                                  }
                                },
                                "id": "968b04e215d00297c525c6ea3c09bb871c25a57c84c23b3fb5a760e52e98b74b",
                                "paging_token": "25667914266836992",
                                "hash": "968b04e215d00297c525c6ea3c09bb871c25a57c84c23b3fb5a760e52e98b74b",
                                "prev_hash": "73cb65bccc7a6bec6019ded1870bc7d553caf290b0fbd714aecd2b625c4a0c54",
                                "sequence": 5976277,
                                "transaction_count": 0,
                                "successful_transaction_count": 0,
                                "failed_transaction_count": 0,
                                "operation_count": 0,
                                "closed_at": "2020-04-16T18:13:37Z",
                                "total_coins": "10000000000000.00000",
                                "fee_pool": "6159.65562",
                                "base_fee_in_stroops": 100,
                                "base_reserve_in_stroops": 0,
                                "max_tx_set_size": 500,
                                "protocol_version": 9,
                                "header_xdr": "AAAACXPLZbzMemvsYBne0YcLx9VTyvKQsPvXFK7NK2JcSgxU0Bq6AjJJWjROJ+A/rBZWOuG0FFvWdkSfdHWSkwrW8rcAAAAAXpigUQAAAAAAAAAA3z9hmASpL9tAVxktxD3XSOp3itxSvEmM6AUkwBS4ERn6DUPhCXbX5N+lFeU1mOeA38qkn5KXXdsjTGrttAXPDQBbMNUN4Lazp2QAAAAAAAAktuN6AAAAAAAAAAAAAAACAAAAZAAAAAAAAAH0Dfp92gfcJjCOCv8Oi7urSTvQev2Po7FixZ3Yg9EPkOhUC//WdqiP2Cd+I0PpMb5qtQ8oC4uhe5jSGQRlkjvlEo2f4jvmT1HOVCWDs9BQ8wUTcg7J+sJwIOv+5x9VNwpP+HxbH0lOvydqqeiI+6T0yQexDwlfm6HS+lkf2wFLJcoAAAAA"
                              }
                            ]
                          }
                        }
                    """
        let data = string.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        let ledgers = try! jsonDecoder.decode(PageResponse<LedgerResponse>.self, from: data!)

        let ledgerResponseEnum = PageResponse<LedgerResponse>.ResponseEnum.success(details: ledgers)
        mockStellarSdk.stubLedgerResponse = ledgerResponseEnum

        let expect = expectation(description: "callback")
        sut.getTransactionMinFee { (response) in
            XCTAssertEqual(response.result, GetMinFeeForTransactionResponse.Result.ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.fee, Quark(100))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionMinFeeNetworkError() {
        let ledgerResponseEnum = PageResponse<LedgerResponse>.ResponseEnum.failure(error: HorizonRequestError.requestFailed(message: "unknown"))
        mockStellarSdk.stubLedgerResponse = ledgerResponseEnum

        let expect = expectation(description: "callback")
        sut.getTransactionMinFee { (response) in
            XCTAssertEqual(response.result, GetMinFeeForTransactionResponse.Result.error)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionMinFeeUpgradeRequired() {
        let ledgerResponseEnum = PageResponse<LedgerResponse>.ResponseEnum.failure(error: HorizonRequestError.serverGone(message: "", horizonErrorResponse: nil))
        mockStellarSdk.stubLedgerResponse = ledgerResponseEnum

        let expect = expectation(description: "callback")
        sut.getTransactionMinFee { (response) in
            XCTAssertEqual(response.result, GetMinFeeForTransactionResponse.Result.upgradeRequired)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionHistorySucceed() {
        let string = """
                        {
                          "_links": {
                            "self": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ/transactions?cursor=\\u0026limit=10\\u0026order=desc"
                            },
                            "next": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ/transactions?cursor=25620076921098240\\u0026limit=10\\u0026order=desc"
                            },
                            "prev": {
                              "href": "http://horizon-testnet.kininfrastructure.com/accounts/GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ/transactions?cursor=25620094100967424\\u0026limit=10\\u0026order=asc"
                            }
                          },
                          "_embedded": {
                            "records": [
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
                              },
                              {
                                "_links": {
                                  "self": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/transactions/ea6f0378fdc148f4a07984cadad83b4b63b8dc68422b0010bc4d7a7290e7385f"
                                  },
                                  "account": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/accounts/GAVEEXYGVKCTG27SJCQPDKYLB53VIILQ5DSPFMXHAP2W6JDLJ4ANMFAH"
                                  },
                                  "ledger": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/ledgers/5965139"
                                  },
                                  "operations": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/transactions/ea6f0378fdc148f4a07984cadad83b4b63b8dc68422b0010bc4d7a7290e7385f/operations{?cursor,limit,order}",
                                    "templated": true
                                  },
                                  "effects": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/transactions/ea6f0378fdc148f4a07984cadad83b4b63b8dc68422b0010bc4d7a7290e7385f/effects{?cursor,limit,order}",
                                    "templated": true
                                  },
                                  "precedes": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/transactions?order=asc\\u0026cursor=25620076921098240"
                                  },
                                  "succeeds": {
                                    "href": "http://horizon-testnet.kininfrastructure.com/transactions?order=desc\\u0026cursor=25620076921098240"
                                  }
                                },
                                "id": "ea6f0378fdc148f4a07984cadad83b4b63b8dc68422b0010bc4d7a7290e7385f",
                                "paging_token": "25620076921098240",
                                "hash": "ea6f0378fdc148f4a07984cadad83b4b63b8dc68422b0010bc4d7a7290e7385f",
                                "ledger": 5965139,
                                "created_at": "2020-04-16T01:09:22Z",
                                "source_account": "GAVEEXYGVKCTG27SJCQPDKYLB53VIILQ5DSPFMXHAP2W6JDLJ4ANMFAH",
                                "source_account_sequence": "2014339699311",
                                "fee_paid": 0,
                                "operation_count": 1,
                                "envelope_xdr": "AAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWAAAAZAAAAdUAAJJvAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA7MVEX0eoA7StXl+P7DWMoGA5Hac5un2DsQwDb8cJLHsAAAAAO5rKAAAAAAAAAAABa08A1gAAAEAz0n21zu1Y7Q4cr0CB0MWtUwIEoWkA5+rWTBNhmKn6tUfivjXDSuMzV4DhgfFh0Q44ayZTp9enVTrBZxSQI3EG",
                                "result_xdr": "AAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
                                "result_meta_xdr": "AAAAAAAAAAEAAAADAAAAAABbBVMAAAAAAAAAAOzFRF9HqAO0rV5fj+w1jKBgOR2nObp9g7EMA2/HCSx7AAAAADuaygAAWwVTAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwBbBVMAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz98lOq8eQAAAHVAACScAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbBVMAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz98hgQJ+QAAAHVAACScAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA",
                                "fee_meta_xdr": "AAAAAgAAAAMAWwU4AAAAAAAAAAAqQl8GqoUza/JIoPGrCw93VCFw6OTysucD9W8ka08A1g3c/fJTqvHkAAAB1QAAkm4AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAWwVTAAAAAAAAAAAqQl8GqoUza/JIoPGrCw93VCFw6OTysucD9W8ka08A1g3c/fJTqvHkAAAB1QAAkm8AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==",
                                "memo_type": "none",
                                "signatures": [
                                  "M9J9tc7tWO0OHK9AgdDFrVMCBKFpAOfq1kwTYZip+rVH4r41w0rjM1eA4YHxYdEOOGsmU6fXp1U6wWcUkCNxBg=="
                                ]
                              }
                            ]
                          }
                        }
                    """
        let data = string.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        let transactions = try! jsonDecoder.decode(PageResponse<TransactionResponse>.self, from: data!)
        let transactionsResponseEnum = PageResponse<TransactionResponse>.ResponseEnum.success(details: transactions)
        mockStellarSdk.stubTransactionsResponse = transactionsResponseEnum

        let expect = expectation(description: "callback")
        let expectTransaction1 = try! transactions.records[0].toHistoricalKinTransaction(network: .testNet)
        let expectTransaction2 = try! transactions.records[1].toHistoricalKinTransaction(network: .testNet)
        let request = GetTransactionHistoryRequest(accountId: "GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ",
                                                   cursor: nil,
                                                   order: .descending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.ok)
            XCTAssertNil(response.error)
            XCTAssertEqual(response.kinTransactions?.count, 2)
            XCTAssertEqual(response.kinTransactions?[0], expectTransaction1)
            XCTAssertEqual(response.kinTransactions?[0].resultCode, ResultCode.success)
            XCTAssertEqual(response.kinTransactions?[1], expectTransaction2)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionHistoryNetworkError() {
        let transactionsResponseEnum = PageResponse<TransactionResponse>.ResponseEnum.failure(error: HorizonRequestError.requestFailed(message: "unknown"))
        mockStellarSdk.stubTransactionsResponse = transactionsResponseEnum

        let expect = expectation(description: "callback")
        let request = GetTransactionHistoryRequest(accountId: "GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ",
                                                   cursor: nil,
                                                   order: .descending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            XCTAssertNil(response.kinTransactions)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionHistoryUpgradeRequired() {
        let transactionsResponseEnum = PageResponse<TransactionResponse>.ResponseEnum.failure(error: HorizonRequestError.serverGone(message: "", horizonErrorResponse: nil))
        mockStellarSdk.stubTransactionsResponse = transactionsResponseEnum

        let expect = expectation(description: "callback")
        let request = GetTransactionHistoryRequest(accountId: "GDWMKRC7I6UAHNFNLZPY73BVRSQGAOI5U443U7MDWEGAG36HBEWHW3OZ",
                                                   cursor: nil,
                                                   order: .descending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.upgradeRequired)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is HorizonRequestError)
            XCTAssertNil(response.kinTransactions)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testStreamTransactionSucceed() {
        let responseString = StubObjects.transationResponse1
        let responseData = responseString.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        let transactionResponse = try! jsonDecoder.decode(TransactionResponse.self, from: responseData!)
        let stubTransStreamItem = MockTransactionStreamItem(baseURL: "", subpath: "")

        stubTransStreamItem.stubResponse = .response(id: "", data: transactionResponse)

        mockStellarSdk.stubTransactionsStreamItem = stubTransStreamItem

        let expect = expectation(description: "event")
        let observable = sut.streamNewTransactions(accountId: StubObjects.accountId1)
            .subscribe { transaction in
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)

        observable.dispose()
    }
}
