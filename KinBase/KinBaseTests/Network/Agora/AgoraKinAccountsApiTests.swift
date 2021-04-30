//
//  AgoraKinAccountsApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Promises
import KinGrpcApi
@testable import KinBase

class MockAgoraAccountServiceGrpcProxy: AgoraAccountServiceGrpcProxy {
    var network: KinNetwork = .testNet
    
    var stubGetAccountInfoResponsePromiseV4: Promise<APBAccountV4GetAccountInfoResponse>?
    var stubCreateAccountResponsePromiseV4: Promise<APBAccountV4CreateAccountResponse>?
    var stubEventsObservableV4: Observable<APBAccountV4Events>?
    var stubResolveTokenAccountsResponsePromiseV4: Promise<APBAccountV4ResolveTokenAccountsResponse>?
    
    func createAccount(_ request: APBAccountV4CreateAccountRequest) -> Promise<APBAccountV4CreateAccountResponse> {
        return stubCreateAccountResponsePromiseV4!
    }
    
    func getAccountInfo(_ request: APBAccountV4GetAccountInfoRequest) -> Promise<APBAccountV4GetAccountInfoResponse> {
        return stubGetAccountInfoResponsePromiseV4!
    }
    
    func getEvents(_ request: APBAccountV4GetEventsRequest) -> Observable<APBAccountV4Events> {
        return stubEventsObservableV4!
    }
    
    func resolveTokenAccounts(_ request: APBAccountV4ResolveTokenAccountsRequest) -> Promise<APBAccountV4ResolveTokenAccountsResponse> {
        return stubResolveTokenAccountsResponsePromiseV4!
    }
}

class AgoraKinAccountsApiTests: XCTestCase {
//
//    var mockAccountServiceGrpc: MockAgoraAccountServiceGrpcProxy!
//    var sut: AgoraKinAccountsApi!
//
//    override func setUpWithError() throws {
//        mockAccountServiceGrpc = MockAgoraAccountServiceGrpcProxy()
//        sut = AgoraKinAccountsApi(agoraGrpc: mockAccountServiceGrpc)
//    }
//
//    func testCreateAccountOk() {
//        let stubAccountInfo = createStubAccountInfo(id: StubObjects.accountId1,
//                                                    balance: 100,
//                                                    sequence: 123)
//        let stubResponse = APBAccountV3CreateAccountResponse()
//        stubResponse.result = .ok
//        stubResponse.accountInfo = stubAccountInfo
//
//        mockAccountServiceGrpc.stubCreateAccountResponsePromise = Promise<APBAccountV3CreateAccountResponse>(stubResponse)
//
//        let request = CreateAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.createAccount(request: request) { response in
//            XCTAssertEqual(response.result, CreateAccountResponse.Result.ok)
//            XCTAssertEqual(response.account!.id, stubAccountInfo.accountId.value)
//            XCTAssertEqual(response.account!.balance.amount.quark, stubAccountInfo.balance)
//            XCTAssertEqual(response.account!.sequenceNumber, stubAccountInfo.sequenceNumber)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testCreateAccountExist() {
//        let stubResponse = APBAccountV3CreateAccountResponse()
//        stubResponse.result = .exists
//
//        mockAccountServiceGrpc.stubCreateAccountResponsePromise = Promise<APBAccountV3CreateAccountResponse>(stubResponse)
//
//        let request = CreateAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.createAccount(request: request) { response in
//            XCTAssertEqual(response.result, CreateAccountResponse.Result.exists)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testCreateAccountTransientFailure() {
//        mockAccountServiceGrpc.stubCreateAccountResponsePromise = Promise<APBAccountV3CreateAccountResponse>(GrpcErrors.cancelled.asError())
//
//        let request = CreateAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.createAccount(request: request) { response in
//            XCTAssertEqual(response.result, CreateAccountResponse.Result.transientFailure)
//            XCTAssertNotNil(response.error)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//    
//    func testCreateAccountUndefinedFailure() {
//        mockAccountServiceGrpc.stubCreateAccountResponsePromise = Promise<APBAccountV3CreateAccountResponse>(AgoraKinAccountsApi.Errors.unknown)
//
//        let request = CreateAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.createAccount(request: request) { response in
//            XCTAssertEqual(response.result, CreateAccountResponse.Result.undefinedError)
//            XCTAssertNotNil(response.error)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testGetAccountInfoOk() {
//        let stubAccountInfo = createStubAccountInfo(id: StubObjects.accountId1,
//                                                    balance: 100,
//                                                    sequence: 123)
//        let stubResponse = APBAccountV3GetAccountInfoResponse()
//        stubResponse.result = .ok
//        stubResponse.accountInfo = stubAccountInfo
//
//        mockAccountServiceGrpc.stubGetAccountInfoResponsePromise = Promise<APBAccountV3GetAccountInfoResponse>(stubResponse)
//
//        let request = GetAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.getAccount(request: request) { response in
//            XCTAssertEqual(response.result, GetAccountResponse.Result.ok)
//            XCTAssertEqual(response.account!.id, stubAccountInfo.accountId.value)
//            XCTAssertEqual(response.account!.balance.amount.quark, stubAccountInfo.balance)
//            XCTAssertEqual(response.account!.sequenceNumber, stubAccountInfo.sequenceNumber)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testGetAccountInfoNotFound() {
//        let stubResponse = APBAccountV3GetAccountInfoResponse()
//        stubResponse.result = .notFound
//
//        mockAccountServiceGrpc.stubGetAccountInfoResponsePromise = Promise<APBAccountV3GetAccountInfoResponse>(stubResponse)
//
//        let request = GetAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.getAccount(request: request) { response in
//            XCTAssertEqual(response.result, GetAccountResponse.Result.notFound)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testGetAccountInfoTransientFailure() {
//        mockAccountServiceGrpc.stubGetAccountInfoResponsePromise = Promise<APBAccountV3GetAccountInfoResponse>(GrpcErrors.cancelled.asError())
//
//        let request = GetAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.getAccount(request: request) { response in
//            XCTAssertEqual(response.result, GetAccountResponse.Result.transientFailure)
//            XCTAssertNotNil(response.error)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//    
//    func testGetAccountInfoUndefinedFailure() {
//        mockAccountServiceGrpc.stubGetAccountInfoResponsePromise = Promise<APBAccountV3GetAccountInfoResponse>(AgoraKinAccountsApi.Errors.unknown)
//
//        let request = GetAccountRequest(accountId: StubObjects.accountId1)
//        let expect = expectation(description: "response")
//        sut.getAccount(request: request) { response in
//            XCTAssertEqual(response.result, GetAccountResponse.Result.undefinedError)
//            XCTAssertNotNil(response.error)
//            expect.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    // TODO: remove
//    func testAccountStreamLive() {
//        let env = KinEnvironment.Horizon.testNet()
//        let agoraProxy = AgoraGrpcProxy(network: .testNet)
//        let accountApi = AgoraKinAccountsApi(agoraGrpc: agoraProxy)
//        let transactionApi = AgoraKinTransactionsApi(agoraGrpc: agoraProxy)
//
//        let keypair = try! KinAccount.Key.generateRandomKeyPair()
//        print(keypair.accountId)
//
//        let expectAccountCreation = expectation(description: "create account")
//        var kinAccount = KinAccount(key: keypair)
//        env.service.createAccount(accountId: keypair.accountId)
//            .then { (account) in
//                print("account created")
//                kinAccount = kinAccount.merge(account)
//                expectAccountCreation.fulfill()
//            }
//
//        wait(for: [expectAccountCreation], timeout: 10)
//
//        let expectAccountStream = expectation(description: "account stream")
//        expectAccountStream.assertForOverFulfill = false
//        expectAccountStream.expectedFulfillmentCount = 3
//        let accountStream = accountApi.streamAccount(StubObjects.accountId1)//keypair.accountId)
//            .subscribe { account in
//                print(account.balance.amount)
//                expectAccountStream.fulfill()
//            }
//
//        let expectTransStream = expectation(description: "trans stream")
//        expectTransStream.assertForOverFulfill = false
//        expectTransStream.expectedFulfillmentCount = 3
//        let transactionStream = accountApi.streamNewTransactions(accountId: keypair.accountId)
//            .subscribe { transaction in
//                print(transaction)
//                expectTransStream.fulfill()
//        }
//
//        let expectBuildTrans = expectation(description: "build trans")
//        var transaction: KinTransaction?
//        env.service.buildAndSignTransaction(sourceKinAccount: kinAccount,
//                                            paymentItems: [KinPaymentItem(amount: Kin(100),
//                                                                          destAccountId: StubObjects.accountId1)],
//                                            memo: .none,
//                                            fee: Quark(100))
//            .then { built in
//                transaction = built
//                expectBuildTrans.fulfill()
//        }
//
//        wait(for: [expectBuildTrans], timeout: 1)
//
//        let expectSubmit = expectation(description: "submit")
//        let submitTransRequest = SubmitTransactionRequest(transactionEnvelopeXdr: transaction!.envelopeXdrString)
//        transactionApi.submitTransaction(request: submitTransRequest) { response in
//            expectSubmit.fulfill()
//        }
//
//        waitForExpectations(timeout: 100)
//    }
//
//    func testAccountStreamAccountUpdate() {
//        let stubEventStream = ValueSubject<APBAccountV3Events>()
//        mockAccountServiceGrpc.stubEventsObservable = stubEventStream
//
//        let stubAccountUpdate = APBAccountV3AccountUpdateEvent()
//        stubAccountUpdate.accountInfo = createStubAccountInfo(id: StubObjects.accountId1,
//                                                              balance: 123,
//                                                              sequence: 111)
//
//        let stubEvent = APBAccountV3Event()
//        stubEvent.accountUpdateEvent = stubAccountUpdate
//
//        let stubEvents = APBAccountV3Events()
//        stubEvents.eventsArray = [stubEvent]
//
//        let expect = expectation(description: "account update")
//        expect.expectedFulfillmentCount = 2
//        sut.streamAccount(StubObjects.accountId1)
//            .subscribe { account in
//                XCTAssertEqual(account.id, StubObjects.accountId1)
//                XCTAssertEqual(account.balance.amount, Quark(123).kin)
//                XCTAssertEqual(account.sequenceNumber, 111)
//                expect.fulfill()
//            }
//
//        stubEventStream.onNext(stubEvents)
//        stubEventStream.onNext(stubEvents)
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testTransactionStreamTransactionUpdate() {
//        let stubEventStream = ValueSubject<APBAccountV3Events>()
//        mockAccountServiceGrpc.stubEventsObservable = stubEventStream
//
//        let stubTransEvent = APBAccountV3TransactionEvent()
//        stubTransEvent.envelopeXdr = Data(base64Encoded: StubObjects.transactionEvelope1)
//        stubTransEvent.resultXdr = Data(base64Encoded: StubObjects.transactionResult1)
//
//        let stubEvent = APBAccountV3Event()
//        stubEvent.transactionEvent = stubTransEvent
//
//        let stubEvents = APBAccountV3Events()
//        stubEvents.eventsArray = [stubEvent]
//
//        let expect = expectation(description: "transaction update")
//        expect.expectedFulfillmentCount = 2
//        sut.streamNewTransactions(accountId: StubObjects.accountId1)
//            .subscribe { transaction in
//                XCTAssertEqual(transaction.envelopeXdrString, StubObjects.transactionEvelope1)
//                XCTAssertEqual(transaction.record.resultXdrBytes!, [Byte](Data(base64Encoded: StubObjects.transactionResult1)!))
//                expect.fulfill()
//            }
//
//        stubEventStream.onNext(stubEvents)
//        stubEventStream.onNext(stubEvents)
//
//        waitForExpectations(timeout: 1)
//    }
}

// MARK: - Helpers
extension AgoraKinAccountsApiTests {
    func createStubAccountInfo(id: String, balance: Int64, sequence: Int64) -> APBAccountV3AccountInfo {
        let stubAccountId = APBCommonV3StellarAccountId()
        stubAccountId.value = id
        let stubAccountInfo = APBAccountV3AccountInfo()
        stubAccountInfo.accountId = stubAccountId
        stubAccountInfo.balance = balance
        stubAccountInfo.sequenceNumber = sequence
        return stubAccountInfo
    }
}
