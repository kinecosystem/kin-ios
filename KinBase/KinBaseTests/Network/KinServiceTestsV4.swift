//
//  KinServiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class MockKinAccountApiV4: KinAccountApiV4 {
    var stubGetAccountResponse: GetAccountResponseV4?
    var stubResolveTokenAccounts: ResolveTokenAccountsResponseV4?

    func getAccount(request: GetAccountRequestV4, completion: @escaping (GetAccountResponseV4) -> Void) {
        completion(stubGetAccountResponse!)
    }
    
    func resolveTokenAccounts(request: ResolveTokenAccountsRequestV4, completion: @escaping (ResolveTokenAccountsResponseV4) -> Void) {
        completion(stubResolveTokenAccounts!)
    }
}

class MockKinAccountCreationApiV4: KinAccountCreationApiV4 {
    var stubCreateAccountResponse: CreateAccountResponseV4?

    func createAccount(request: CreateAccountRequestV4, completion: @escaping (CreateAccountResponseV4) -> Void) {
        completion(stubCreateAccountResponse!)
    }
}

class MockKinTransactionApiV4: KinTransactionApiV4 {
    var stubGetTransactionHistoryResponse: GetTransactionHistoryResponseV4?
    var stubGetTransactionResponse: GetTransactionResponseV4?
    var stubGetMinFeeResponse: GetMinFeeForTransactionResponseV4?
    var stubSubmitTransactionResponse: SubmitTransactionResponseV4?
    var subServiceConfigResponse: GetServiceConfigResponseV4?
    var stubRecentBlockhashResponse: GetRecentBlockHashResonseV4?
    var stubMinBalanceRentExemption: GetMinimumBalanceForRentExemptionResponseV4?
    var stubMinVersionResponse: GetMinimumKinVersionResponseV4?

    func getTransactionHistory(request: GetTransactionHistoryRequestV4, completion: @escaping (GetTransactionHistoryResponseV4) -> Void) {
        completion(stubGetTransactionHistoryResponse!)
    }

    func getTransaction(request: GetTransactionRequestV4, completion: @escaping (GetTransactionResponseV4) -> Void) {
        completion(stubGetTransactionResponse!)
    }

    func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponseV4) -> Void) {
        completion(stubGetMinFeeResponse!)
    }

    func submitTransaction(request: SubmitTransactionRequestV4, completion: @escaping (SubmitTransactionResponseV4) -> Void) {
        completion(stubSubmitTransactionResponse!)
    }
    
    func getServiceConfig(request: GetServiceConfigRequestV4, completion: @escaping (GetServiceConfigResponseV4) -> Void) {
        completion(subServiceConfigResponse!)
    }
    
    func getRecentBlockHash(request: GetRecentBlockHashRequestV4, completion: @escaping (GetRecentBlockHashResonseV4) -> Void) {
        completion(stubRecentBlockhashResponse!)
    }
    
    func getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4, completion: @escaping (GetMinimumBalanceForRentExemptionResponseV4) -> Void) {
        completion(stubMinBalanceRentExemption!)
    }
    
    func getMinKinVersion(request: GetMinimumKinVersionRequestV4, completion: @escaping (GetMinimumKinVersionResponseV4) -> Void) {
        completion(stubMinVersionResponse!)
    }
}

class MockKinStreamingApiV4: KinStreamingApiV4 {
    var stubNewTransactionsStream: Observable<KinTransaction>?
    var stubAccountStream: Observable<KinAccount>?

    func streamAccountV4(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        return stubAccountStream!
    }

    func streamNewTransactionsV4(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return stubNewTransactionsStream!
    }
}

class KinServiceTestsV4: XCTestCase {

    var mockKinAccountApi: MockKinAccountApiV4!
    var mockKinAccountCreationApi: MockKinAccountCreationApiV4!
    var mockKinTransactionApi: MockKinTransactionApiV4!
    var mockKinStreamingApi: MockKinStreamingApiV4!
    var sut: KinServiceType!

    override func setUp() {
        mockKinAccountApi = MockKinAccountApiV4()
        mockKinAccountCreationApi = MockKinAccountCreationApiV4()
        mockKinTransactionApi = MockKinTransactionApiV4()
        mockKinStreamingApi = MockKinStreamingApiV4()
        
        mockKinTransactionApi.subServiceConfigResponse = GetServiceConfigResponseV4(result: .ok, subsidizerAccount: TokenProgram.PROGRAM_KEY, tokenProgram: TokenProgram.PROGRAM_KEY, token: TokenProgram.PROGRAM_KEY)
        mockKinTransactionApi.stubMinBalanceRentExemption = GetMinimumBalanceForRentExemptionResponseV4(result: .ok, lamports: 12345)
        mockKinTransactionApi.stubRecentBlockhashResponse = GetRecentBlockHashResonseV4(result: .ok, blockHash: Hash())

        sut = KinServiceV4(network: .testNet,
                         networkOperationHandler: NetworkOperationHandler(),
                         dispatchQueue: .main,
                         accountApi: mockKinAccountApi,
                         accountCreationApi: mockKinAccountCreationApi,
                         transactionApi: mockKinTransactionApi,
                         streamingApi: mockKinStreamingApi,
                         logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
    }

    func testCreateAccountSucceed() {
        let expectAccount = KinAccount(key: try! KinAccount.Key(secretSeed: StubObjects.seed1),
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let stubResponse = CreateAccountResponseV4(result: .ok,
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
        let error = KinServiceV4.Errors.unknown
        let stubResponse = CreateAccountResponseV4(result: .undefinedError,
                                                 error: error,
                                                 account: nil)
        mockKinAccountCreationApi.stubCreateAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.createAccount(accountId: "", signer: try! KinAccount.Key.generateRandomKeyPair()).catch { error in
            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
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
        let stubResponse = GetAccountResponseV4(result: .ok,
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
        let error = KinServiceV4.Errors.unknown
        let stubResponse = GetAccountResponseV4(result: .transientFailure,
                                              error: error,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountNotFound() {
        let stubResponse = GetAccountResponseV4(result: .notFound,
                                              error: nil,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.itemNotFound)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountUpgradeRequired() {
        let stubResponse = GetAccountResponseV4(result: .upgradeRequired,
                                              error: nil,
                                              account: nil)
        mockKinAccountApi.stubGetAccountResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeSucceed() {
        let stubResponse = GetMinFeeForTransactionResponseV4(result: .ok,
                                                           error: nil,
                                                           fee: Quark(0))
        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse

        let expect = expectation(description: "callback")
        sut.getMinFee().then { fee in
            XCTAssertEqual(fee, Quark(0))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

//    func testGetMinFeeError() {
//        let error = KinServiceV4.Errors.unknown
//        let stubResponse = GetMinFeeForTransactionResponseV4(result: .error,
//                                                           error: error,
//                                                           fee: nil)
//        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse
//
//        let expect = expectation(description: "callback")
//        sut.getMinFee().catch { error in
//            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testGetMinFeeUpgradeRequired() {
//        let stubResponse = GetMinFeeForTransactionResponseV4(result: .upgradeRequired,
//                                                           error: nil,
//                                                           fee: nil)
//        mockKinTransactionApi.stubGetMinFeeResponse = stubResponse
//
//        let expect = expectation(description: "callback")
//        sut.getMinFee().catch { error in
//            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }

    func testBuildAndSignTransactionSucceed() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATU8/l5NBLia6Ip4ZevFr8EVdu+XuarcB9iFMoyviM4RTnmZfCRjmvZubp4ONLChWU6yAvAQkNBfp7G0SUcycHAgABBAbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwVKU1D4XciC1hSlVnJ4iilt3x6rq9CmBniISTL07vagAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAwAKMS1rZWstYmxhaAADAQIBCQPgrrsAAAAAAA=="

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
                                    memo: KinMemo(text: "1-kek-blah"),
                                    fee: Quark(100))
            .then { transaction in
                XCTAssertEqual(Data(transaction.envelopeXdrBytes).base64EncodedString(), expectEnvelope)
                XCTAssertEqual(transaction.record.recordType, Record.RecordType.inFlight)
                XCTAssertEqual("1-kek-blah", transaction.memo.text)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBuildAndSignTransactionAgoraMemoSucceed() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABT7AS9uPlvnSFyPu6zi4RUcxk2jVFg/ak/9THDNxsQOEU2DNV7wgpIqvDX5vdV6EJG6S9SKF48wJiduzLCfuEIAgABBAbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwVKU1D4XciC1hSlVnJ4iilt3x6rq9CmBniISTL07vagAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAwAsWVFBQUlQM1YwekJjQk1neThpOVBtSy9uOVgrQzJHUkJMbTJqdU80R2t3RT0AAwECAQkD4K67AAAAAAA="

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
                XCTAssertEqual(agoraMemo.kinMemo.data, transaction.memo.data)
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
        let expectResponse = GetTransactionResponseV4(result: .ok,
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
        let error = KinServiceV4.Errors.unknown
        let expectResponse = GetTransactionResponseV4(result: .transientFailure,
                                                    error: error,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionNotFound() {
        let expectResponse = GetTransactionResponseV4(result: .notFound,
                                                    error: nil,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionUpgradeRequired() {
        let expectResponse = GetTransactionResponseV4(result: .upgradeRequired,
                                                    error: nil,
                                                    kinTransaction: nil)
        mockKinTransactionApi.stubGetTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
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

        let expectResponse = GetTransactionHistoryResponseV4(result: .ok,
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
        let error = KinServiceV4.Errors.unknown
        let expectResponse = GetTransactionHistoryResponseV4(result: .transientFailure,
                                                           error: error,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsNotFound() {
        let expectResponse = GetTransactionHistoryResponseV4(result: .notFound,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsUpgradeRequired() {
        let expectResponse = GetTransactionHistoryResponseV4(result: .upgradeRequired,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
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

        let expectResponse = GetTransactionHistoryResponseV4(result: .ok,
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
        let error = KinServiceV4.Errors.unknown
        let expectResponse = GetTransactionHistoryResponseV4(result: .transientFailure,
                                                           error: error,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageNotFound() {
        let expectResponse = GetTransactionHistoryResponseV4(result: .notFound,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.itemNotFound)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageUpgradeRequired() {
        let expectResponse = GetTransactionHistoryResponseV4(result: .upgradeRequired,
                                                           error: nil,
                                                           kinTransactions: nil)
        mockKinTransactionApi.stubGetTransactionHistoryResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionSucceed() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADBhKbplKYVFe1zp0Qbm0sgmfDJ/4PaKI6sdhW5K2hYa3yTxBa4fJz/KclOzYQnutToS8NCcgtE1Zm43VjEEo8LAgACBe8oot1gdFzu7PD9FVa1d7qVwJMMaA9eHCYwdUXnQVthXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpBUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIEACxRUUFBdFBKYmVhMUFzazR6UytKSGRjMkJWem5GWXZlMU5BWnNoR2kxUHdJPQMDAQIBCQPgrrsAAAAAAA=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet,
                                                      invoiceList: StubObjects.stubInvoiceList1)
        let ackedTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                   record: .acknowledged(ts: 123456799,
                                                                         resultXdrBytes: [0, 1]),
                                                   network: .testNet)
        let expectResponse = SubmitTransactionResponseV4(result: .ok,
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
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADBhKbplKYVFe1zp0Qbm0sgmfDJ/4PaKI6sdhW5K2hYa3yTxBa4fJz/KclOzYQnutToS8NCcgtE1Zm43VjEEo8LAgACBe8oot1gdFzu7PD9FVa1d7qVwJMMaA9eHCYwdUXnQVthXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpBUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIEACxRUUFBdFBKYmVhMUFzazR6UytKSGRjMkJWem5GWXZlMU5BWnNoR2kxUHdJPQMDAQIBCQPgrrsAAAAAAA=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet)
        let error = KinServiceV4.Errors.unknown
        let expectResponse = SubmitTransactionResponseV4(result: .transientFailure,
                                                       error: error,
                                                       kinTransaction: nil)

        mockKinTransactionApi.stubSubmitTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionUpgradeRequired() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADBhKbplKYVFe1zp0Qbm0sgmfDJ/4PaKI6sdhW5K2hYa3yTxBa4fJz/KclOzYQnutToS8NCcgtE1Zm43VjEEo8LAgACBe8oot1gdFzu7PD9FVa1d7qVwJMMaA9eHCYwdUXnQVthXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpBUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIEACxRUUFBdFBKYmVhMUFzazR6UytKSGRjMkJWem5GWXZlMU5BWnNoR2kxUHdJPQMDAQIBCQPgrrsAAAAAAA=="
        let inFlightTransaction = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope)!),
                                                      record: .inFlight(ts: 123456789),
                                                      network: .testNet)

        let expectResponse = SubmitTransactionResponseV4(result: .upgradeRequired,
                                                       error: nil,
                                                       kinTransaction: nil)

        mockKinTransactionApi.stubSubmitTransactionResponse = expectResponse

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCanWhitelistTransaction() {
        sut.canWhitelistTransactions().then { XCTAssertTrue($0) }
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
        XCTAssertEqual(KinServiceV4.Errors.insufficientBalance, KinServiceV4.Errors.insufficientBalance)
        XCTAssertEqual(KinServiceV4.Errors.invalidAccount, KinServiceV4.Errors.invalidAccount)
        XCTAssertEqual(KinServiceV4.Errors.missingApi, KinServiceV4.Errors.missingApi)
        XCTAssertEqual(KinServiceV4.Errors.transientFailure(error: KinServiceV4.Errors.unknown), KinServiceV4.Errors.transientFailure(error: KinServiceV4.Errors.unknown))
        XCTAssertEqual(KinServiceV4.Errors.upgradeRequired, KinServiceV4.Errors.upgradeRequired)
        XCTAssertEqual(KinServiceV4.Errors.unknown, KinServiceV4.Errors.unknown)
        XCTAssertNotEqual(KinServiceV4.Errors.unknown, KinServiceV4.Errors.upgradeRequired)
    }
}
