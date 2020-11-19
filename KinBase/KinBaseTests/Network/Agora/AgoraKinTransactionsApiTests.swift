//
//  AgoraKinTransactionsApiTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Promises
import KinGrpcApi
@testable import KinBase

class MockAgoraTransactionServiceGrpcProxy: AgoraTransactionServiceGrpcProxy {
    var network: KinNetwork = .testNet
    var stubGetHistoryResponsePromise: Promise<APBTransactionV3GetHistoryResponse>?
    var stubSubmitTransactionResponsePromise: Promise<APBTransactionV3SubmitTransactionResponse>?
    var stubGetTransactionResponsePromise: Promise<APBTransactionV3GetTransactionResponse>?

    func getHistory(_ request: APBTransactionV3GetHistoryRequest) -> Promise<APBTransactionV3GetHistoryResponse> {
        return stubGetHistoryResponsePromise!
    }

    func submitTransaction(_ request: APBTransactionV3SubmitTransactionRequest) -> Promise<APBTransactionV3SubmitTransactionResponse> {
        return stubSubmitTransactionResponsePromise!
    }

    func getTransaction(_ request: APBTransactionV3GetTransactionRequest) -> Promise<APBTransactionV3GetTransactionResponse> {
        return stubGetTransactionResponsePromise!
    }
    
    // V4 Apis
    var stubGetHistoryResponsePromiseV4: Promise<APBTransactionV4GetHistoryResponse>?
    var stubSubmitTransactionResponsePromiseV4: Promise<APBTransactionV4SubmitTransactionResponse>?
    var stubGetTransactionResponsePromiseV4: Promise<APBTransactionV4GetTransactionResponse>?
    var stubGetServiceConfigResponsePromise: Promise<APBTransactionV4GetServiceConfigResponse>?
    var stubGetMinBalanceForRentExemptionResponsePromise: Promise<APBTransactionV4GetMinimumBalanceForRentExemptionResponse>?
    var stubGetRecentBlockHashResponsePromise: Promise<APBTransactionV4GetRecentBlockhashResponse>?
    var stubGetMinVersionePromise: Promise<APBTransactionV4GetMinimumKinVersionResponse>?
    
    func getHistory(_ request: APBTransactionV4GetHistoryRequest) -> Promise<APBTransactionV4GetHistoryResponse> {
        return stubGetHistoryResponsePromiseV4!
    }
    
    func submitTransaction(_ request: APBTransactionV4SubmitTransactionRequest) -> Promise<APBTransactionV4SubmitTransactionResponse> {
        return stubSubmitTransactionResponsePromiseV4!
    }
    
    func getTransaction(_ request: APBTransactionV4GetTransactionRequest) -> Promise<APBTransactionV4GetTransactionResponse> {
        return stubGetTransactionResponsePromiseV4!
    }
    
    func getServiceConfig(_ request: APBTransactionV4GetServiceConfigRequest) -> Promise<APBTransactionV4GetServiceConfigResponse> {
        return stubGetServiceConfigResponsePromise!
    }
    
    func getMinimumBalanceForRentExemptionRequest(_ request: APBTransactionV4GetMinimumBalanceForRentExemptionRequest) -> Promise<APBTransactionV4GetMinimumBalanceForRentExemptionResponse> {
        return stubGetMinBalanceForRentExemptionResponsePromise!
    }
    
    func getRecentBlockHashRequest(_ request: APBTransactionV4GetRecentBlockhashRequest) -> Promise<APBTransactionV4GetRecentBlockhashResponse> {
        return stubGetRecentBlockHashResponsePromise!
    }
    
    func getMinimumVersion(_ request: APBTransactionV4GetMinimumKinVersionRequest) -> Promise<APBTransactionV4GetMinimumKinVersionResponse> {
        return stubGetMinVersionePromise!
    }
}

class AgoraKinTransactionsApiTests: XCTestCase {

    var mockTransactionServiceGrpc: MockAgoraTransactionServiceGrpcProxy!
    var sut: AgoraKinTransactionsApi!

    override func setUpWithError() throws {
        mockTransactionServiceGrpc = MockAgoraTransactionServiceGrpcProxy()
        sut = AgoraKinTransactionsApi(agoraGrpc: mockTransactionServiceGrpc)
    }

    func testGetHistoryOk() {
        let stubItem1 = APBTransactionV3HistoryItem()
        stubItem1.envelopeXdr = Data(base64Encoded: StubObjects.transactionEvelope1)
        stubItem1.resultXdr = Data(base64Encoded: StubObjects.transactionResult1)

        let stubItem2 = APBTransactionV3HistoryItem()
        stubItem2.envelopeXdr = Data(base64Encoded: StubObjects.transactionEvelope2)
        stubItem2.resultXdr = Data(base64Encoded: StubObjects.transactionResult1)

        let stubResponse = APBTransactionV3GetHistoryResponse()
        stubResponse.result = .ok
        stubResponse.itemsArray = [stubItem1, stubItem2]

        mockTransactionServiceGrpc.stubGetHistoryResponsePromise = .init(stubResponse)

        let expect = expectation(description: "transactions")
        let request = GetTransactionHistoryRequest(accountId: StubObjects.accountId1,
                                                   cursor: nil,
                                                   order: .ascending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.ok)
            XCTAssertEqual(response.kinTransactions!.count, 2)
            XCTAssertEqual(response.kinTransactions!.first!.envelopeXdrBytes, [Byte](stubItem1.envelopeXdr))
            XCTAssertEqual(response.kinTransactions!.first!.network, KinNetwork.testNet)
            XCTAssertEqual(response.kinTransactions!.first!.record.resultXdrBytes, [Byte](stubItem1.resultXdr))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetHistoryNotFound() {
        let stubResponse = APBTransactionV3GetHistoryResponse()
        stubResponse.result = .notFound

        mockTransactionServiceGrpc.stubGetHistoryResponsePromise = .init(stubResponse)

        let expect = expectation(description: "transactions")
        let request = GetTransactionHistoryRequest(accountId: StubObjects.accountId1,
                                                   cursor: nil,
                                                   order: .ascending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.notFound)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetHistoryTransientFailure() {
        mockTransactionServiceGrpc.stubGetHistoryResponsePromise = .init(GrpcErrors.cancelled.asError())

        let expect = expectation(description: "transactions")
        let request = GetTransactionHistoryRequest(accountId: StubObjects.accountId1,
                                                   cursor: nil,
                                                   order: .ascending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testGetHistoryUnknownFailure() {
        mockTransactionServiceGrpc.stubGetHistoryResponsePromise = .init(AgoraKinTransactionsApi.Errors.unknown)

        let expect = expectation(description: "transactions")
        let request = GetTransactionHistoryRequest(accountId: StubObjects.accountId1,
                                                   cursor: nil,
                                                   order: .ascending)
        sut.getTransactionHistory(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionHistoryResponse.Result.undefinedError)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionSuccess() {
        let transaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope1)

        let stubItem = APBTransactionV3HistoryItem()
        stubItem.envelopeXdr = Data(base64Encoded: StubObjects.transactionEvelope1)
        stubItem.resultXdr = Data(base64Encoded: StubObjects.transactionResult1)
        stubItem.invoiceList = StubObjects.stubInvoiceListProto

        let stubResponse = APBTransactionV3GetTransactionResponse()
        stubResponse.state = .success
        stubResponse.item = stubItem

        mockTransactionServiceGrpc.stubGetTransactionResponsePromise = .init(stubResponse)

        let expect = expectation(description: "transactions")
        let request = GetTransactionRequest(transactionHash: transaction.transactionHash!)
        sut.getTransaction(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.ok)
            XCTAssertEqual(response.kinTransaction!.envelopeXdrBytes, transaction.envelopeXdrBytes)
            XCTAssertEqual(response.kinTransaction!.invoiceList, StubObjects.stubInvoiceListProto.invoiceList)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionNotFound() {
        let transaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope1)
        let stubResponse = APBTransactionV3GetTransactionResponse()
        stubResponse.state = .unknown

        mockTransactionServiceGrpc.stubGetTransactionResponsePromise = .init(stubResponse)

        let expect = expectation(description: "transactions")
        let request = GetTransactionRequest(transactionHash: transaction.transactionHash!)
        sut.getTransaction(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.notFound)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetTransactionTransientFailure() {
        let transaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope1)
        mockTransactionServiceGrpc.stubGetTransactionResponsePromise = .init(GrpcErrors.cancelled.asError())

        let expect = expectation(description: "transactions")
        let request = GetTransactionRequest(transactionHash: transaction.transactionHash!)
        sut.getTransaction(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.transientFailure)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testGetTransactionUnknownFailure() {
        let transaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope1)
        mockTransactionServiceGrpc.stubGetTransactionResponsePromise = .init(AgoraKinTransactionsApi.Errors.unknown)

        let expect = expectation(description: "transactions")
        let request = GetTransactionRequest(transactionHash: transaction.transactionHash!)
        sut.getTransaction(request: request) { response in
            XCTAssertEqual(response.result, GetTransactionResponse.Result.undefinedError)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionOk() {
        let transaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope1)

        let stubResponse = APBTransactionV3SubmitTransactionResponse()
        stubResponse.result = .ok
        stubResponse.resultXdr = StubObjects.transactionResult1.data(using: .utf8)!

        mockTransactionServiceGrpc.stubSubmitTransactionResponsePromise = .init(stubResponse)

        let expect = expectation(description: "submit")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: StubObjects.transactionEvelope1,
                                               invoiceList: StubObjects.stubInvoiceList1)
        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.ok)
            XCTAssertEqual(response.kinTransaction?.envelopeXdrBytes, transaction.envelopeXdrBytes)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionResultError() {
        let stubResponse = APBTransactionV3SubmitTransactionResponse()
        stubResponse.result = .failed

        mockTransactionServiceGrpc.stubSubmitTransactionResponsePromise = .init(stubResponse)

        let expect = expectation(description: "submit")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: StubObjects.transactionEvelope1)
        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.transientFailure)
            XCTAssertNil(response.kinTransaction)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionInvoiceError() {
        var invoiceErrors = [APBCommonV3InvoiceError]()
        for i in 0...2 {
            let error = APBCommonV3InvoiceError()
            error.opIndex = UInt32(i)
            error.reason = .skuNotFound
            error.invoice = StubObjects.stubInvoiceProto
            invoiceErrors.append(error)
        }

        let stubResponse = APBTransactionV3SubmitTransactionResponse()
        stubResponse.result = .invoiceError
        stubResponse.invoiceErrorsArray = NSMutableArray(array: invoiceErrors)

        mockTransactionServiceGrpc.stubSubmitTransactionResponsePromise = .init(stubResponse)

        let expect = expectation(description: "submit")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: StubObjects.transactionEvelope1)
        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.invoiceError)
            XCTAssertNotNil(response.error)
            XCTAssertNil(response.kinTransaction)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubmitTransactionTransientFailure() {
        mockTransactionServiceGrpc.stubSubmitTransactionResponsePromise = .init(GrpcErrors.cancelled.asError())

        let expect = expectation(description: "submit")
        let request = SubmitTransactionRequest(transactionEnvelopeXdr: StubObjects.transactionEvelope1)
        sut.submitTransaction(request: request) { response in
            XCTAssertEqual(response.result, SubmitTransactionResponse.Result.transientFailure)
            XCTAssertNil(response.kinTransaction)
            XCTAssertNotNil(response.error)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testSubmitTransactionUnknownFailure() {
           mockTransactionServiceGrpc.stubSubmitTransactionResponsePromise = .init(AgoraKinTransactionsApi.Errors.unknown)

           let expect = expectation(description: "submit")
           let request = SubmitTransactionRequest(transactionEnvelopeXdr: StubObjects.transactionEvelope1)
           sut.submitTransaction(request: request) { response in
               XCTAssertEqual(response.result, SubmitTransactionResponse.Result.undefinedError)
               XCTAssertNil(response.kinTransaction)
               XCTAssertNotNil(response.error)
               expect.fulfill()
           }

           waitForExpectations(timeout: 1)
       }

    func testGetTransactionMinFeeOk() {
        let expect = expectation(description: "min fee")
        sut.getTransactionMinFee(completion: { (response: GetMinFeeForTransactionResponse) in
            XCTAssertEqual(response.result, GetMinFeeForTransactionResponse.Result.ok)
            XCTAssertEqual(response.fee, Quark(100))
            expect.fulfill()
        })

        waitForExpectations(timeout: 1)
    }

    func testIsWhitelistingAvailable() {
        XCTAssertTrue(sut.isWhitelistingAvailable)
    }

    func testWhitelistTransaction() {
        let expect = expectation(description: "whitelist")
        let request = WhitelistTransactionRequest(transactionEnvelope: StubObjects.transactionEvelope1)
        sut.whitelistTransaction(request: request) { response in
            XCTAssertEqual(response.result, WhitelistTransactionResponse.Result.ok)
            XCTAssertEqual(response.whitelistedTransactionEnvelope, request.transactionEnvelope)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
