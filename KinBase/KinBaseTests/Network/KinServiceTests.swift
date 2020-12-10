//
//  KinServiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class MockKinAccountApi: KinAccountApi {
    var stubGetAccountResponse: GetAccountResponse?

    func getAccount(request: GetAccountRequest, completion: @escaping (GetAccountResponse) -> Void) {
        completion(stubGetAccountResponse!)
    }
}

class MockKinAccountCreationApi: KinAccountCreationApi {
    var stubCreateAccountResponse: CreateAccountResponse?

    func createAccount(request: CreateAccountRequest, completion: @escaping (CreateAccountResponse) -> Void) {
        completion(stubCreateAccountResponse!)
    }
}

class MockKinTransactionApi: KinTransactionApi {

    var stubGetTransactionHistoryResponse: GetTransactionHistoryResponse?
    var stubGetTransactionResponse: GetTransactionResponse?
    var stubGetMinFeeResponse: GetMinFeeForTransactionResponse?
    var stubSubmitTransactionResponse: SubmitTransactionResponse?

    func getTransactionHistory(request: GetTransactionHistoryRequest, completion: @escaping (GetTransactionHistoryResponse) -> Void) {
        completion(stubGetTransactionHistoryResponse!)
    }

    func getTransaction(request: GetTransactionRequest, completion: @escaping (GetTransactionResponse) -> Void) {
        completion(stubGetTransactionResponse!)
    }

    func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponse) -> Void) {
        completion(stubGetMinFeeResponse!)
    }

    func submitTransaction(request: SubmitTransactionRequest, completion: @escaping (SubmitTransactionResponse) -> Void) {
        completion(stubSubmitTransactionResponse!)
    }
}

class MockWhitelistingApi: KinTransactionWhitelistingApi {
    var isWhitelistingAvailable: Bool = false

    func whitelistTransaction(request: WhitelistTransactionRequest, completion: @escaping (WhitelistTransactionResponse) -> Void) {

    }
}

class MockKinStreamingApi: KinStreamingApi {
    var stubNewTransactionsStream: Observable<KinTransaction>?
    var stubAccountStream: Observable<KinAccount>?

    func streamAccount(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        return stubAccountStream!
    }

    func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return stubNewTransactionsStream!
    }
}

class KinServiceTests: XCTestCase {

    var mockKinAccountApi: MockKinAccountApi!
    var mockKinAccountCreationApi: MockKinAccountCreationApi!
    var mockKinTransactionApi: MockKinTransactionApi!
    var mockKinWhitelistingApi: MockWhitelistingApi!
    var mockKinStreamingApi: MockKinStreamingApi!
    var sut: KinServiceType!
    var sut2: KinServiceType!

    override func setUp() {
        mockKinAccountApi = MockKinAccountApi()
        mockKinAccountCreationApi = MockKinAccountCreationApi()
        mockKinTransactionApi = MockKinTransactionApi()
        mockKinWhitelistingApi = MockWhitelistingApi()
        mockKinStreamingApi = MockKinStreamingApi()

        sut = KinService(network: .testNet,
                         networkOperationHandler: NetworkOperationHandler(),
                         dispatchQueue: .main,
                         accountApi: mockKinAccountApi,
                         accountCreationApi: mockKinAccountCreationApi,
                         transactionApi: mockKinTransactionApi,
                         transactionWhitelistingApi: mockKinWhitelistingApi,
                         streamingApi: mockKinStreamingApi,
                         logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
        
        sut2 = KinService(network: .testNetKin2,
                         networkOperationHandler: NetworkOperationHandler(),
                         dispatchQueue: .main,
                         accountApi: mockKinAccountApi,
                         accountCreationApi: mockKinAccountCreationApi,
                         transactionApi: mockKinTransactionApi,
                         transactionWhitelistingApi: mockKinWhitelistingApi,
                         streamingApi: mockKinStreamingApi,
                         logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
    }

    func testCreateAccountSucceed() {
        let accountId = StubObjects.accountId1
        let expectAccount = KinAccount(key: try! KinAccount.Key(accountId: accountId),
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let stubResponse = CreateAccountResponse(result: .ok,
                                                 error: nil,
                                                 account: expectAccount)
        mockKinAccountCreationApi.stubCreateAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.createAccount(accountId: "", signer: expectAccount.key).then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateAccountError() {
        let error = KinService.Errors.unknown
        let stubResponse = CreateAccountResponse(result: .undefinedError,
                                                 error: error,
                                                 account: nil)
        mockKinAccountCreationApi.stubCreateAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.createAccount(accountId: "", signer: try! KinAccount.Key.generateRandomKeyPair()).catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountSucceed() {
        let accountId = StubObjects.accountId1
        let expectAccount = KinAccount(key: try! KinAccount.Key(accountId: accountId),
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let stubResponse = GetAccountResponse(result: .ok,
                                              error: nil,
                                              account: expectAccount)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: accountId).then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetAccountTransientFailure() {
        let error = KinService.Errors.unknown
        let stubResponse = GetAccountResponse(result: .transientFailure,
                                              error: error,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountNotFound() {
        let stubResponse = GetAccountResponse(result: .notFound,
                                              error: nil,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.itemNotFound)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountUpgradeRequired() {
        let stubResponse = GetAccountResponse(result: .upgradeRequired,
                                              error: nil,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeSucceed() {
        let stubResponse = GetMinFeeForTransactionResponse(result: .ok,
                                                           error: nil,
                                                           fee: Quark(101))
        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getMinFee().then { fee in
            XCTAssertEqual(fee, Quark(101))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeError() {
        let error = KinService.Errors.unknown
        let stubResponse = GetMinFeeForTransactionResponse(result: .error,
                                                           error: error,
                                                           fee: nil)
        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getMinFee().catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeUpgradeRequired() {
        let stubResponse = GetMinFeeForTransactionResponse(result: .upgradeRequired,
                                                           error: nil,
                                                           fee: nil)
        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getMinFee().catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBuildAndSignTransactionSucceed() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDpSBbgeceq6/vcEh3/blqn0qNYo4q8DLHes4DADOPzunvSjREWBeKJC9SdaKhtCnrcv3J04V1MVmdN5iDQ5HcP"

        let sourceAccountSeed = "SDFDPC5VK7FSFDH4Q3CQPQRA4OPFXYM6CFRXVQOA767OGXFYBEDEQGMF"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"

        let account = KinAccount(key: try! KinAccount.Key(secretSeed: sourceAccountSeed),
                                 balance: KinBalance(Kin(string: "9999.99400")!),
                                 status: .registered,
                                 sequence: 16576250185252864)
        let paymentItems = [KinPaymentItem(amount: Kin(123), destAccountId: destAccountId)]

        let expect = expectation(description: "callback")
        sut.buildAndSignTransaction(ownerKey: account.key, sourceKey: account.key, nonce: account.sequenceNumber,
                                    paymentItems: paymentItems,
                                    memo: KinMemo(text: "ohi"),
                                    fee: Quark(100))
            .then { transaction in
                XCTAssertEqual(Data(transaction.envelopeXdrBytes).base64EncodedString(), expectEnvelope)
                XCTAssertEqual(transaction.record.recordType, Record.RecordType.inFlight)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testBuildAndSignTransactionKin2Succeed() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AABOIAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAIAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAFLSU4AAAAAAEW5G8005Z05h9lKYP6VjCyF2379OGk5xeTLLLm15qibAAAAAElQT4AAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAFLSU4AAAAAAEW5G8005Z05h9lKYP6VjCyF2379OGk5xeTLLLm15qibAAAAAIt5kQAAAAAAAAAAAcIY7/sAAABAoSWFNRFdkKFrtXQhTSK/4TFibwBs2M/hd6SwVisS32qLqrSjUwOssELC83Hpe6cyU/BYuvmQvlgGZ38zIV5vAg=="

        let sourceAccountSeed = "SDFDPC5VK7FSFDH4Q3CQPQRA4OPFXYM6CFRXVQOA767OGXFYBEDEQGMF"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"

        let account = KinAccount(
            key: try! KinAccount.Key(secretSeed: sourceAccountSeed),
            balance: KinBalance(Kin(string: "9999.99400")!),
            status: .registered,
            sequence: 16576250185252864
        )
        
        let paymentItems = [
            KinPaymentItem(amount: Kin(123), destAccountId: destAccountId),
            KinPaymentItem(amount: Kin(234), destAccountId: destAccountId),
        ]

        let expect = expectation(description: "callback")
        sut2.buildAndSignTransaction(
            ownerKey: account.key,
            sourceKey: account.key,
            nonce: account.sequenceNumber,
            paymentItems: paymentItems,
            memo: KinMemo(text: "ohi"),
            fee: Quark(12)
        ).then { transaction in
            XCTAssertEqual(transaction.fee, 20000)
            XCTAssertEqual(transaction.paymentOperations[0].amount, 12300)
            XCTAssertEqual(transaction.paymentOperations[1].amount, 23400)
            XCTAssertEqual(Data(transaction.envelopeXdrBytes).base64EncodedString(), expectEnvelope)
            XCTAssertEqual(transaction.record.recordType, Record.RecordType.inFlight)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBuildAndSignTransactionAgoraMemoSucceed() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAANhAAAg/dXTMFwEyDLyL0+Yr+f1f4LYZEEubaO47gaTAQAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDQ3WmCKQd8CSd4+uF/Oj3WxgG5o4XirKsO0H37ke9PZ8QG3CYMOgAPrAA0YD3cfx/87x8VIW/NMj69RRLtZL4G"

        let sourceAccountSeed = "SDFDPC5VK7FSFDH4Q3CQPQRA4OPFXYM6CFRXVQOA767OGXFYBEDEQGMF"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"

        let account = KinAccount(key: try! KinAccount.Key(secretSeed: sourceAccountSeed),
                                 balance: KinBalance(Kin(string: "9999.99400")!),
                                 status: .registered,
                                 sequence: 16576250185252864)

        let invoice = StubObjects.stubInvoice
        let invoiceList = try! InvoiceList(invoices: [invoice])

        let paymentItems = [KinPaymentItem(amount: Kin(123),
                                           destAccountId: destAccountId,
                                           invoice: invoice)]

        let agoraMemo = try! KinBinaryMemo(typeId: KinBinaryMemo.TransferType.p2p.rawValue,
                                       appIdx: 0,
                                       foreignKeyBytes: invoiceList.id.decode())

        let expect = expectation(description: "callback")
        sut.buildAndSignTransaction(ownerKey: account.key, sourceKey: account.key, nonce: account.sequenceNumber,
                                    paymentItems: paymentItems,
                                    memo: agoraMemo.kinMemo,
                                    fee: Quark(100))
            .then { transaction in
                XCTAssertEqual(Data(transaction.envelopeXdrBytes).base64EncodedString(), expectEnvelope)
                XCTAssertEqual(transaction.record.recordType, Record.RecordType.inFlight)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testBuildAndSignTransactionUnableToSignError() {
        let sourceAccountId = "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"

        let account = KinAccount(key: try! KinAccount.Key(accountId: sourceAccountId),
                                 balance: KinBalance(Kin(string: "9999.99400")!),
                                 status: .registered,
                                 sequence: 16576250185252864)
        let paymentItems = [KinPaymentItem(amount: Kin(123), destAccountId: destAccountId)]

        let expect = expectation(description: "callback")
        sut.buildAndSignTransaction(ownerKey: account.key, sourceKey: account.key, nonce: account.sequenceNumber,
                                    paymentItems: paymentItems,
                                    memo: KinMemo(text: "ohi"),
                                    fee: Quark(100))
            .catch { error in
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionSucceed() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDpSBbgeceq6/vcEh3/blqn0qNYo4q8DLHes4DADOPzunvSjREWBeKJC9SdaKhtCnrcv3J04V1MVmdN5iDQ5HcP"
        let expectResponse = GetTransactionResponse(result: .ok,
                                                    error: nil,
                                                    kinTransaction: try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                                                        record: .historical(ts: 123456789,
                                                                                                            resultXdrBytes: [2, 1],
                                                                                                            pagingToken: "pagingtoken"),
                                                                                        network: .testNet))
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .then { transaction in
                XCTAssertEqual(expectResponse.kinTransaction, transaction)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionTransientFailure() {
        let error = KinService.Errors.unknown
        let expectResponse = GetTransactionResponse(result: .transientFailure,
                                                    error: error,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionNotFound() {
        let expectResponse = GetTransactionResponse(result: .notFound,
                                                    error: nil,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionUpgradeRequired() {
        let expectResponse = GetTransactionResponse(result: .upgradeRequired,
                                                    error: nil,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsSucceed() {
        let expectEnvelope1 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDpSBbgeceq6/vcEh3/blqn0qNYo4q8DLHes4DADOPzunvSjREWBeKJC9SdaKhtCnrcv3J04V1MVmdN5iDQ5HcP"
        let transaction1 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope1)!),
                                              record: .historical(ts: 123456789,
                                                                  resultXdrBytes: [2, 1],
                                                                  pagingToken: "pagingtoken"),
                                              network: .testNet)
        let expectEnvelope2 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let transaction2 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope2)!),
                                               record: .historical(ts: 1234567890,
                                                                   resultXdrBytes: [2, 1],
                                                                   pagingToken: "pagingtoken"),
                                               network: .testNet)

        let expectResponse = GetTransactionHistoryResponse(result: .ok,
                                                           error: nil,
                                                           kinTransactions: [transaction1, transaction2])
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .then { transactions in
                XCTAssertEqual(transactions, [transaction1, transaction2])
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsTransientFailure() {
        let error = KinService.Errors.unknown
        let expectResponse = GetTransactionHistoryResponse(result: .transientFailure,
                                                           error: error,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsNotFound() {
        let expectResponse = GetTransactionHistoryResponse(result: .notFound,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsUpgradeRequired() {
        let expectResponse = GetTransactionHistoryResponse(result: .upgradeRequired,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageSucceed() {
        let expectEnvelope1 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAEAAAADb2hpAAAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDpSBbgeceq6/vcEh3/blqn0qNYo4q8DLHes4DADOPzunvSjREWBeKJC9SdaKhtCnrcv3J04V1MVmdN5iDQ5HcP"
        let transaction1 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope1)!),
                                              record: .historical(ts: 123456789,
                                                                  resultXdrBytes: [2, 1],
                                                                  pagingToken: "pagingtoken"),
                                              network: .testNet)
        let expectEnvelope2 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let transaction2 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope2)!),
                                               record: .historical(ts: 1234567890,
                                                                   resultXdrBytes: [2, 1],
                                                                   pagingToken: "pagingtoken"),
                                               network: .testNet)

        let expectResponse = GetTransactionHistoryResponse(result: .ok,
                                                           error: nil,
                                                           kinTransactions: [transaction1, transaction2])
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .then { transactions in
                XCTAssertEqual(transactions, [transaction1, transaction2])
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageTransientFailure() {
        let error = KinService.Errors.unknown
        let expectResponse = GetTransactionHistoryResponse(result: .transientFailure,
                                                           error: error,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageNotFound() {
        let expectResponse = GetTransactionHistoryResponse(result: .notFound,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.itemNotFound)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageUpgradeRequired() {
        let expectResponse = GetTransactionHistoryResponse(result: .upgradeRequired,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionSucceed() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet,
                                                      invoiceList: StubObjects.stubInvoiceList1)
        let ackedTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                   record: .acknowledged(ts: 123456799,
                                                                         resultXdrBytes: [0, 1]),
                                                   network: .testNet)
        let expectResponse = SubmitTransactionResponse(result: .ok,
                                                       error: nil,
                                                       kinTransaction: ackedTransaction)

        mockKinTransactionApi.stubSubmitTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .then { transaction in
                XCTAssertEqual(transaction, ackedTransaction)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionError() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet)
        let error = KinService.Errors.unknown
        let expectResponse = SubmitTransactionResponse(result: .transientFailure,
                                                       error: error,
                                                       kinTransaction: nil)

        mockKinTransactionApi.stubSubmitTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionUpgradeRequired() {
        let expectEnvelope = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet)

        let expectResponse = SubmitTransactionResponse(result: .upgradeRequired,
                                                       error: nil,
                                                       kinTransaction: nil)

        mockKinTransactionApi.stubSubmitTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCanWhitelistTransaction() {
        mockKinWhitelistingApi.isWhitelistingAvailable = true
        sut.canWhitelistTransactions().then { XCTAssertTrue($0) }

        mockKinWhitelistingApi.isWhitelistingAvailable = false
        sut.canWhitelistTransactions().then { XCTAssertFalse($0) }
    }

    func testStreamNewTransactions() {
        mockKinStreamingApi.stubNewTransactionsStream = ValueSubject<KinTransaction>()
        XCTAssertNoThrow(sut.streamNewTransactions(accountId: "id"))
    }

    func testStreamAccount() {
        mockKinStreamingApi.stubAccountStream = ValueSubject<KinAccount>()
        XCTAssertNoThrow(sut.streamAccount(accountId: "id"))
    }

    func testKinServiceErrorEquatable() {
        XCTAssertEqual(KinService.Errors.insufficientBalance, KinService.Errors.insufficientBalance)
        XCTAssertEqual(KinService.Errors.invalidAccount, KinService.Errors.invalidAccount)
        XCTAssertEqual(KinService.Errors.missingApi, KinService.Errors.missingApi)
        XCTAssertEqual(KinService.Errors.transientFailure(error: KinService.Errors.unknown), KinService.Errors.transientFailure(error: KinService.Errors.unknown))
        XCTAssertEqual(KinService.Errors.upgradeRequired, KinService.Errors.upgradeRequired)
        XCTAssertEqual(KinService.Errors.unknown, KinService.Errors.unknown)
        XCTAssertNotEqual(KinService.Errors.unknown, KinService.Errors.upgradeRequired)
    }
}
