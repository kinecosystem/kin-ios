//
//  FriendBotApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class FriendBotApiTests: XCTestCase {

    private var mockUrlSession: URLSession!
    private var sut: FriendBotApi!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockUrlSession = URLSession(configuration: config)

        sut = FriendBotApi(urlSession: mockUrlSession)
    }

    override func tearDown() {
        MockURLProtocol.stubUrlData = [:]
    }

    func testCreateAccountSucceed() {
        // Set up stub account and response data
        let accountId = "GBD2LB2VV2GKLO5RBNJKL7IP3WSN2BK46KSYEMDCYZSWLVA5HC7TYR72"
        let url = URL(string: "https://friendbot-testnet.kininfrastructure.com/?addr=" + accountId)
        let string = """
                        {
                          "_links": {
                            "transaction": {
                              "href": "https://horizon-testnet.kininfrastructure.com/transactions/fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53"
                            }
                          },
                          "hash": "fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53",
                          "ledger": 5964634,
                          "envelope_xdr": "AAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWAAAAZAAAAdUAAJJlAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAR6WHVa6MpbuxC1Kl/Q/dpN0FXPKlgjBixmVl1B04vzwAAAAAO5rKAAAAAAAAAAABa08A1gAAAED2aPrxPiARzp4Ef1Lf1ZvvCwlJnFa5rHl7ughlXt1b3tyeuzCa1F4VNeVHiW5txUXjPfWY3ZBGWThT+yC9dw4K",
                          "result_xdr": "AAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
                          "result_meta_xdr": "AAAAAAAAAAEAAAADAAAAAABbA1oAAAAAAAAAAEelh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88AAAAADuaygAAWwNaAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz98/Tmd+QAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz987lLreQAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"
                        }
                    """
        let data = string.data(using: .utf8)
        MockURLProtocol.stubUrlData = [url!: data!]

        let expect = expectation(description: "request complete")
        let expectAccount = KinAccount(key: try! KinAccount.Key(accountId: accountId),
                                       balance: KinBalance(Kin(10000)),
                                       status: .registered,
                                       sequence: 25617907962609664)
        let request = CreateAccountRequest(accountId: accountId)

        sut.createAccount(request: request) { response in
            XCTAssertEqual(response.result, CreateAccountResponse.Result.ok)
            XCTAssertEqual(response.account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateAccountNetworkError() {
        let accountId = StubObjects.accountId1

        let expect = expectation(description: "request complete")
        let request = CreateAccountRequest(accountId: accountId)

        sut.createAccount(request: request) { response in
            XCTAssertEqual(response.result, CreateAccountResponse.Result.transientFailure)
            XCTAssertTrue(response.error is MockURLProtocol.Errors)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateAccountInvalidJson() {
        // Set up stub account and response data
        let accountId = StubObjects.accountId1
        let url = URL(string: "https://friendbot-testnet.kininfrastructure.com/?addr=" + accountId)
        let string = """
                        invalidjson{
                          "_links": {
                            "transaction": {
                              "href": "https://horizon-testnet.kininfrastructure.com/transactions/fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53"
                            }
                          },
                          "hash": "fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53",
                          "ledger": 5964634,
                          "envelope_xdr": "AAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWAAAAZAAAAdUAAJJlAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAR6WHVa6MpbuxC1Kl/Q/dpN0FXPKlgjBixmVl1B04vzwAAAAAO5rKAAAAAAAAAAABa08A1gAAAED2aPrxPiARzp4Ef1Lf1ZvvCwlJnFa5rHl7ughlXt1b3tyeuzCa1F4VNeVHiW5txUXjPfWY3ZBGWThT+yC9dw4K",
                          "result_xdr": "AAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
                          "result_meta_xdr": "AAAAAAAAAAEAAAADAAAAAABbA1oAAAAAAAAAAEelh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88AAAAADuaygAAWwNaAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz98/Tmd+QAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz987lLreQAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"
                        }
                     """
        let data = string.data(using: .utf8)
        MockURLProtocol.stubUrlData = [url!: data!]

        let expect = expectation(description: "request complete")
        let request = CreateAccountRequest(accountId: accountId)

        sut.createAccount(request: request) { response in
            XCTAssertEqual(response.result, CreateAccountResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateAccountMissingAccount() {
        // Set up stub account and response data
        let accountId = StubObjects.accountId1
        let url = URL(string: "https://friendbot-testnet.kininfrastructure.com/?addr=" + accountId)
        let string = """
                        {
                          "_links": {
                            "transaction": {
                              "href": "https://horizon-testnet.kininfrastructure.com/transactions/fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53"
                            }
                          },
                          "hash": "fa2993719082e64031e89c7937cb80ee82c1b7b819b8196a86f8931a934a6d53",
                          "ledger": 5964634,
                          "envelope_xdr": "AAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWAAAAZAAAAdUAAJJlAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAR6WHVa6MpbuxC1Kl/Q/dpN0FXPKlgjBixmVl1B04vzwAAAAAO5rKAAAAAAAAAAABa08A1gAAAED2aPrxPiARzp4Ef1Lf1ZvvCwlJnFa5rHl7ughlXt1b3tyeuzCa1F4VNeVHiW5txUXjPfWY3ZBGWThT+yC9dw4K",
                          "result_xdr": "AAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
                          "result_meta_xdr": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAwBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz98/Tmd+QAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQBbA1oAAAAAAAAAACpCXwaqhTNr8kig8asLD3dUIXDo5PKy5wP1byRrTwDWDdz987lLreQAAAHVAACSZgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"
                        }
                    """
        let data = string.data(using: .utf8)
        MockURLProtocol.stubUrlData = [url!: data!]

        let expect = expectation(description: "request complete")
        let request = CreateAccountRequest(accountId: accountId)

        sut.createAccount(request: request) { response in
            XCTAssertEqual(response.result, CreateAccountResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
