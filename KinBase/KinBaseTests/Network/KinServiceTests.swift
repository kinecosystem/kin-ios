//
//  KinServiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class MockKinAccountApi: KinAccountApiV4 {
    
    var stubGetAccountResponse: GetAccountResponseV4?
    var stubResolveTokenAccounts: ResolveTokenAccountsResponseV4?
    
    func getAccount(request: GetAccountRequestV4, completion: @escaping (GetAccountResponseV4) -> Void) {
        completion(stubGetAccountResponse!)
    }
    
    func resolveTokenAccounts(request: ResolveTokenAccountsRequestV4, completion: @escaping (ResolveTokenAccountsResponseV4) -> Void) {
        completion(stubResolveTokenAccounts!)
    }
}

class MockKinAccountCreationApi: KinAccountCreationApiV4 {
    var stubCreateAccountResponse: CreateAccountResponseV4?

    func createAccount(request: CreateAccountRequestV4, completion: @escaping (CreateAccountResponseV4) -> Void) {
        completion(stubCreateAccountResponse!)
    }
}

class MockKinTransactionApi: KinTransactionApiV4 {
    
    var stubGetMinKinVersion: GetMinimumKinVersionResponseV4?
    var stubGetServiceConfig: GetServiceConfigResponseV4?
    var stubGetRecentBlockHash: GetRecentBlockHashResonseV4?
    var stubGetMinimumBalanceForRentExemption: GetMinimumBalanceForRentExemptionResponseV4?
    var stubGetTransactionHistory: GetTransactionHistoryResponseV4?
    var stubGetTransaction: GetTransactionResponseV4?
    var stubGetTransactionMinFee: GetMinFeeForTransactionResponseV4?
    var stubSubmitTransaction: SubmitTransactionResponseV4?
    
    func getMinKinVersion(request: GetMinimumKinVersionRequestV4, completion: @escaping (GetMinimumKinVersionResponseV4) -> Void) {
        completion(stubGetMinKinVersion!)
    }
    
    func getServiceConfig(request: GetServiceConfigRequestV4, completion: @escaping (GetServiceConfigResponseV4) -> Void) {
        completion(stubGetServiceConfig!)
    }
    
    func getRecentBlockHash(request: GetRecentBlockHashRequestV4, completion: @escaping (GetRecentBlockHashResonseV4) -> Void) {
        completion(stubGetRecentBlockHash!)
    }
    
    func getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4, completion: @escaping (GetMinimumBalanceForRentExemptionResponseV4) -> Void) {
        completion(stubGetMinimumBalanceForRentExemption!)
    }
    
    func getTransactionHistory(request: GetTransactionHistoryRequestV4, completion: @escaping (GetTransactionHistoryResponseV4) -> Void) {
        completion(stubGetTransactionHistory!)
    }
    
    func getTransaction(request: GetTransactionRequestV4, completion: @escaping (GetTransactionResponseV4) -> Void) {
        completion(stubGetTransaction!)
    }
    
    func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponseV4) -> Void) {
        completion(stubGetTransactionMinFee!)
    }
    
    func submitTransaction(request: SubmitTransactionRequestV4, completion: @escaping (SubmitTransactionResponseV4) -> Void) {
        completion(stubSubmitTransaction!)
    }
}

class MockKinStreamingApi: KinStreamingApiV4 {
    var stubNewTransactionsStream: Observable<KinTransaction>?
    var stubAccountStream: Observable<KinAccount>?

    func streamAccountV4(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        return stubAccountStream!
    }

    func streamNewTransactionsV4(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return stubNewTransactionsStream!
    }
}

class KinServiceTests: XCTestCase {

    var mockKinAccountApi: MockKinAccountApi!
    var mockKinAccountCreationApi: MockKinAccountCreationApi!
    var mockKinTransactionApi: MockKinTransactionApi!
    var mockKinStreamingApi: MockKinStreamingApi!
    var sut: KinServiceType!
    var sut2: KinServiceType!

    override func setUp() {
        mockKinAccountApi = MockKinAccountApi()
        mockKinAccountCreationApi = MockKinAccountCreationApi()
        mockKinTransactionApi = MockKinTransactionApi()
        mockKinStreamingApi = MockKinStreamingApi()

        sut = KinServiceV4(network: .testNet,
                         networkOperationHandler: NetworkOperationHandler(),
                         dispatchQueue: .main,
                         accountApi: mockKinAccountApi,
                         accountCreationApi: mockKinAccountCreationApi,
                         transactionApi: mockKinTransactionApi,
                         streamingApi: mockKinStreamingApi,
                         logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
        
        mockKinTransactionApi.stubGetServiceConfig = .init(
            result: .ok,
            subsidizerAccount: StubObjects.accountId1.asPublicKey(),
            tokenProgram: StubObjects.accountId2.asPublicKey(),
            token: StubObjects.accountId2.asPublicKey()
        )
    }

    func testCreateAccountSucceed() {
        let accountId = StubObjects.accountId1
        let expectAccount = KinAccount(key: try! KinAccount.Key(accountId: accountId),
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        
        mockKinAccountCreationApi.stubCreateAccountResponse = .init(
            result: .ok,
            error: nil,
            account: expectAccount
        )

        let expect = expectation(description: "callback")
        sut.createAccount(accountId: "", signer: expectAccount.key).then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateAccountError() {
        mockKinAccountCreationApi.stubCreateAccountResponse = .init(
            result: .undefinedError,
            error: KinService.Errors.unknown,
            account: nil
        )
        
        mockKinTransactionApi.stubGetMinimumBalanceForRentExemption = .init(result: .ok, lamports: 32)
        mockKinTransactionApi.stubGetRecentBlockHash = .init(result: .ok, blockHash: Hash())

        let expect = expectation(description: "callback")
        sut.createAccount(accountId: "", signer: try! KinAccount.Key.generateRandomKeyPair()).catch { error in
            if case .transientFailure = error as? KinService.Errors {} else {
                XCTFail()
            }
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
        
        mockKinAccountApi.stubGetAccountResponse = .init(
            result: .ok,
            error: nil,
            account: expectAccount
        )

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: accountId).then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetAccountTransientFailure() {
        mockKinAccountApi.stubGetAccountResponse = .init(
            result: .transientFailure,
            error: KinService.Errors.unknown,
            account: nil
        )

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountNotFound() {
        mockKinAccountApi.stubGetAccountResponse = .init(
            result: .notFound,
            error: nil,
            account: nil
        )

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertError(error, is: KinService.Errors.itemNotFound)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetAccountUpgradeRequired() {
        mockKinAccountApi.stubGetAccountResponse = .init(
            result: .upgradeRequired,
            error: nil,
            account: nil
        )

        let expect = expectation(description: "callback")
        sut.getAccount(accountId: "").catch { error in
            XCTAssertError(error, is: KinService.Errors.upgradeRequired)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeSucceed() {
        mockKinTransactionApi.stubGetTransactionMinFee = .init(
            result: .ok,
            error: nil,
            fee: Quark(101)
        )

        let expect = expectation(description: "callback")
        sut.getMinFee().then { fee in
            XCTAssertEqual(fee, Quark(101))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeError() {
        mockKinTransactionApi.stubGetTransactionMinFee = .init(
            result: .error,
            error: KinService.Errors.unknown,
            fee: nil
        )

        let expect = expectation(description: "callback")
        sut.getMinFee().catch { error in
            XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetMinFeeUpgradeRequired() {
        mockKinTransactionApi.stubGetTransactionMinFee = .init(
            result: .upgradeRequired,
            error: nil,
            fee: nil
        )

        let expect = expectation(description: "callback")
        sut.getMinFee().catch { error in
            XCTAssertError(error, is: KinService.Errors.upgradeRequired)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBuildAndSignTransactionSucceed() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0TkH5OqiL+e3r9ZxQbUBFqC6PySv5Cc9yOzf2guknCHbIcTc2BDEvi57qB3NLGxfacjIVcBgm6hYeBLAoIrYPAgABAyEHLqkO+hRTLAROj/XYWiX22Llwa7F/EN/FPca3iiAvXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/sFSlNQ+F3IgtYUpVZyeIopbd8eq6vQpgZ4iEky9O72oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgIAA29oaQADAQABCQPgrrsAAAAAAA=="

        let sourceAccountSeed = "SDFDPC5VK7FSFDH4Q3CQPQRA4OPFXYM6CFRXVQOA767OGXFYBEDEQGMF"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"
        
        mockKinTransactionApi.stubGetRecentBlockHash = .init(result: .ok, blockHash: Hash())

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

    func testBuildAndSignTransactionAgoraMemoSucceed() {
        let expectEnvelope = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABdHoppHI/xXaRLRk1yJyBegxHuKVfCPyVYumj/1JP+lS82RjVIkU47boTtllTFmB50OnMvgJXsP/VCu692MxoJAgACBbtbiTuSmfPON/HqV6oaTugti96HN5aanCPaf56BGgfLXcX6W5Rx/UxdWFA1UzmGZgUAY7yHYMvnC/isIcIY7/shBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogL0elh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88BUpTUPhdyILWFKVWcniKKW3fHqur0KYGeIhJMvTu9qAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIEACxZUUFBSVAzVjB6QmNCTWd5OGk5UG1LL245WCtDMkdSQkxtMmp1TzRHa3dFPQMDAQIBCQPgrrsAAAAAAA=="

        let sourceAccountSeed = "SDFDPC5VK7FSFDH4Q3CQPQRA4OPFXYM6CFRXVQOA767OGXFYBEDEQGMF"
        let destAccountId = "GAQQOLVJB35BIUZMARHI75OYLIS7NWFZOBV3C7YQ37CT3RVXRIQC6CXN"
        
        mockKinTransactionApi.stubGetRecentBlockHash = .init(result: .ok, blockHash: Hash())

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
        
        mockKinTransactionApi.stubGetRecentBlockHash = .init(result: .ok, blockHash: Hash())
        
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
        mockKinTransactionApi.stubGetTransaction = .init(
            result: .ok,
            error: nil,
            kinTransaction: try! KinTransaction(
                envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
                record: .historical(
                    ts: 123456789,
                    resultXdrBytes: [2, 1],
                    pagingToken: "pagingtoken"
                ),
                network: .testNet
            )
        )

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .then { transaction in
                XCTAssertEqual(transaction, self.mockKinTransactionApi.stubGetTransaction?.kinTransaction)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionTransientFailure() {
        let error = KinService.Errors.unknown
        
        mockKinTransactionApi.stubGetTransaction = .init(
            result: .transientFailure,
            error: error,
            kinTransaction: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionNotFound() {
        mockKinTransactionApi.stubGetTransaction = .init(
            result: .notFound,
            error: nil,
            kinTransaction: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionUpgradeRequired() {
        mockKinTransactionApi.stubGetTransaction = .init(
            result: .upgradeRequired,
            error: nil,
            kinTransaction: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransaction(transactionHash: KinTransactionHash(Data([0, 1])))
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsSucceed() {
        let transaction1 = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .historical(
                ts: 123456789,
                resultXdrBytes: [2, 1],
                pagingToken: "pagingtoken"
            ),
            network: .testNet
        )
        
        let transaction2 = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope2)!),
            record: .historical(
                ts: 1234567890,
                resultXdrBytes: [2, 1],
                pagingToken: "pagingtoken"
            ),
            network: .testNet
        )

        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .ok,
            error: nil,
            kinTransactions: [transaction1, transaction2]
        )

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .then { transactions in
                XCTAssertEqual(transactions, [transaction1, transaction2])
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsTransientFailure() {
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .transientFailure,
            error: KinService.Errors.unknown,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsNotFound() {
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .notFound,
            error: nil,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.itemNotFound)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetLatestTransactionsUpgradeRequired() {
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .upgradeRequired,
            error: nil,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getLatestTransactions(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM")
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testGetTransactionPageSucceed() {
        let transaction1 = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .historical(
                ts: 123456789,
                resultXdrBytes: [2, 1],
                pagingToken: "pagingtoken"
            ),
            network: .testNet
        )
        
        let transaction2 = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope2)!),
            record: .historical(
                ts: 1234567890,
                resultXdrBytes: [2, 1],
                pagingToken: "pagingtoken"
            ),
            network: .testNet
        )
        
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .ok,
            error: nil,
            kinTransactions: [transaction1, transaction2]
        )

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
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .transientFailure,
            error: KinService.Errors.unknown,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageNotFound() {
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .notFound,
            error: nil,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.itemNotFound)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionPageUpgradeRequired() {
        mockKinTransactionApi.stubGetTransactionHistory = .init(
            result: .upgradeRequired,
            error: nil,
            kinTransactions: nil
        )

        let expect = expectation(description: "callback")
        sut.getTransactionPage(accountId: "GC5VXCJ3SKM7HTRX6HVFPKQ2J3UC3C66Q43ZNGU4EPNH7HUBDID4XHKM",
                               pagingToken: "pagingtoken",
                               order: .descending)
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.upgradeRequired)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionSucceed() {
        let inFlightTransaction = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .inFlight(ts: 123456789),
            network: .testNet,
            invoiceList: StubObjects.stubInvoiceList1
        )
        
        let ackedTransaction = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .acknowledged(
                ts: 123456799,
                resultXdrBytes: [0, 1]
            ),
            network: .testNet
        )

        mockKinTransactionApi.stubSubmitTransaction = .init(
            result: .ok,
            error: nil,
            kinTransaction: ackedTransaction
        )

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .then { transaction in
                XCTAssertEqual(transaction, ackedTransaction)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionError() {
        let inFlightTransaction = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .inFlight(ts: 123456789),
            network: .testNet
        )
        
        mockKinTransactionApi.stubSubmitTransaction = .init(
            result: .transientFailure,
            error: KinService.Errors.unknown,
            kinTransaction: nil
        )

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.transientFailure(error: error))
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionUpgradeRequired() {
        let inFlightTransaction = try! KinTransaction(
            envelopeXdrBytes: [Byte](Data(base64Encoded: StubObjects.transactionEvelope1)!),
            record: .inFlight(ts: 123456789),
            network: .testNet
        )

        mockKinTransactionApi.stubSubmitTransaction = .init(
            result: .upgradeRequired,
            error: nil,
            kinTransaction: nil
        )

        let expect = expectation(description: "callback")
        sut.submitTransaction(transaction: inFlightTransaction)
            .catch { error in
                XCTAssertError(error, is: KinService.Errors.upgradeRequired)
                expect.fulfill()
        }

        waitForExpectations(timeout: 1)
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
