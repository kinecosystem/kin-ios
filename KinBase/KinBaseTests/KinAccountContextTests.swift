//
//  KinAccountContextTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Promises
import stellarsdk
@testable import KinBase

class KinAccountContextTests: XCTestCase {

    var mockKinService: MockKinService!
    var mockKinStorage: MockKinStorage!
    var mockEnv: KinEnvironment!
    var sut: KinAccountContext!
    var disposeBag: DisposeBag!

    override func setUp() {
        mockKinService = MockKinService()
        mockKinStorage = MockKinStorage()
        mockEnv = KinEnvironment(network: .testNet,
                                 service: mockKinService,
                                 storage: mockKinStorage,
                                 networkHandler: NetworkOperationHandler(),
                                 dispatchQueue: .main)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag.dispose()
    }

    // TODO: remove
//    func testSubmitTransactionLive() {
//        let key = try! KeyPair.generateRandomKeyPair()
//        var account = KinAccount(key: key)
//        print(account.id)
//
//        let agoraEnv = KinEnvironment.Agora.testNet()
//
//        let expectCreateAccount = expectation(description: "create account")
//        agoraEnv.service.createAccount(accountId: account.id)
//            .then { resultAccount in
//                account = account.merge(resultAccount)
//                expectCreateAccount.fulfill()
//                print("account created")
//            }
//
//        wait(for: [expectCreateAccount], timeout: 20)
//
//        let context = try! KinAccountContext.Builder(env: agoraEnv)
//            .importExistingPrivateKey(key)
//            .build()
//
//        let expectPay = expectation(description: "pay")
//        context.sendKinPayment(KinPaymentItem(amount: Kin(100),
//                                              destAccountId: StubObjects.badAccountId),
//                               memo: .none)
//            .then { payment in
//                print(payment)
//                expectPay.fulfill()
//            }
//            .catch { error in
//                print(error)
//                expectPay.fulfill()
//            }
//
//        wait(for: [expectPay], timeout: 300)
//    }
//
    // TODO: remove
//    func testPayInvoiceLive() {
//        let key = try! KeyPair.generateRandomKeyPair()
//        var account = KinAccount(key: key)
//        print(account.id)
//
//        var horizonEnv: KinEnvironment? = KinEnvironment.Horizon.testNet()
////        let agoraEnv = KinEnvironment.Agora.testNet()
//
//        let expectCreateAccount = expectation(description: "create account")
//        horizonEnv!.service.createAccount(accountId: account.id)
//            .then { resultAccount in
//                account = account.merge(resultAccount)
//                expectCreateAccount.fulfill()
//                print("account created")
//            }
//
//        wait(for: [expectCreateAccount], timeout: 20)
//
//        horizonEnv = nil
//
//        let agoraEnv = KinEnvironment.Agora.testNet()
//        let context = try! KinAccountContext.Builder(env: agoraEnv)
//            .importExistingPrivateKey(key)
//            .build()
//
////        let lineItem = try! LineItem(title: "ios invoice title",
////                                     description: "ios invoice desc",
////                                     amount: Kin(100),
////                                     sku: SKU(bytes: [0, 2, 3]))
////        let invoice = try! Invoice(lineItems: [lineItem])
////        let expectPay = expectation(description: "pay invoice")
////        var resultPayment: KinPayment?
////        context.payInvoice(processingAppIdx: .testApp,
////                           destinationAccount: StubObjects.androidTestAccountId,
////                           invoice: invoice,
////                           type: .spend)
////            .then { result  in
////                print(result)
////                resultPayment = result
////                expectPay.fulfill()
////            }
////            .catch { error in
////                print(error)
////            }
//        var resultPayment: KinPayment?
//        context.sendKinPayment(KinPaymentItem(amount: Kin(100),
//                                              destAccountId: StubObjects.androidTestAccountId),
//                               memo: .none)
//            .then { result in
//                print(result)
//                resultPayment = result
//                expectPay.fulfill()
//
//            }
//            .catch { error in
//                print(error)
//                expectPay.fulfill()
//            }
//
//        wait(for: [expectPay], timeout: 300)
//
//        let expectRecord = expectation(description: "transaction record")
//        context.getPaymentsForTransactionHash(resultPayment!.id.transactionHash)
//            .then { payment  in
//                expectRecord.fulfill()
//        }
//        wait(for: [expectRecord], timeout: 300)
//    }

    func testGetAccountNotInStorage() {
        let key = try! KeyPair.generateRandomKeyPair()
        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId))
        mockKinService.stubGetAccountResult = expectAccount

        let expect = expectation(description: "callback")
        sut.getAccount().then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetAccountInStorageRegistered() {
        let key = try! KeyPair.generateRandomKeyPair()
        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: .zero,
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        let expect = expectation(description: "callback")
        sut.getAccount().then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetAccountInStorageUnregistered() {
        let key = try! KeyPair.generateRandomKeyPair()
        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        let storageAccount = KinAccount(key: key,
                                        balance: .zero,
                                        status: .unregistered,
                                        sequence: nil)

        mockKinStorage.stubGetAccountResult = storageAccount

        mockKinService.stubGetAccountResultPromise = .init(KinService.Errors.unknown)

        let serviceAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                             balance: .zero,
                                             status: .registered,
                                             sequence: 1)

        mockKinService.stubCreateAccountResult = serviceAccount

        let expectAccount = KinAccount(key: key,
                                       balance: .zero,
                                       status: .registered,
                                       sequence: 1)

        mockKinStorage.stubUpdateAccountResult = expectAccount

        let expect = expectation(description: "callback")
        sut.getAccount().then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetPaymentsForTransactionHashSucceed() {
        sut = KinAccountContext(environment: mockEnv,
                                accountId: StubObjects.accountId1)

        let expectTransaction = StubObjects.transaction
        mockKinService.stubGetTransactionResult = expectTransaction

        let expect = expectation(description: "callback")
        sut.getPaymentsForTransactionHash(KinTransactionHash(Data([0, 1]))).then { payments in
            XCTAssertEqual(payments, expectTransaction.kinPayments)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentsSucceed() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        // Set up signed transaction returned by service
        let payments = [KinPaymentItem(amount: Kin(1000), destAccountId: StubObjects.accountId1),
                        KinPaymentItem(amount: Kin(990), destAccountId: StubObjects.accountId2)]
        let memo = KinMemo.none

        let signedEnvelope = "AAAAAOg2QBm0NeppntiRBPTrzbkKvo3F8SZyGqHco/tuLdJtAAAAyABeTpgAAAABAAAAAAAAAAEAAAAAAAAAAgAAAAEAAAAA6DZAGbQ16mme2JEE9OvNuQq+jcXxJnIaodyj+24t0m0AAAABAAAAALtbiTuSmfPON/HqV6oaTugti96HN5aanCPaf56BGgfLAAAAAAAAAAAF9eEAAAAAAQAAAADoNkAZtDXqaZ7YkQT06825Cr6NxfEmchqh3KP7bi3SbQAAAAEAAAAAR6WHVa6MpbuxC1Kl/Q/dpN0FXPKlgjBixmVl1B04vzwAAAAAAAAAAAXmnsAAAAAAAAAAAW4t0m0AAABAejXsRsLudrJhseIcXJ7hwxpTAmg15XKST1/PipJBF3ZAMHVQj2gKOHEaBouMDGeQ7/4Pi30X38nJHBmY4Hn5DA=="
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: signedEnvelope)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: signedEnvelope)
        mockKinService.stubSubmitTransactionResult = .init(stubAckedTransaction)
        mockKinService.stubCanWhitelistTransactionResult = false
        mockKinService.stubMinFee = Quark(100)

        // Set up account updates in storage
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinStorage.stubAdvanceSequenceResult = expectAccount
        mockKinStorage.stubDeductFromBalanceResult = expectAccount
        mockKinStorage.stubInsertNewTransactionResult = [stubAckedTransaction]

        // Test
        let expect = expectation(description: "callback")
        sut.sendKinPayments(payments, memo: memo).then { payments in
            XCTAssertTrue(self.mockKinStorage.sequenceAdvanced)
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 1000 - 990)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(payments, stubAckedTransaction.kinPayments)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentSucceed() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        // Set up signed transaction returned by service
        let payment = KinPaymentItem(amount: Kin(1000), destAccountId: StubObjects.accountId2)
        let memo = KinMemo.none

        let signedEnvelope = "AAAAAOg2QBm0NeppntiRBPTrzbkKvo3F8SZyGqHco/tuLdJtAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA6DZAGbQ16mme2JEE9OvNuQq+jcXxJnIaodyj+24t0m0AAAABAAAAAEelh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88AAAAAAAAAAAF9eEAAAAAAAAAAAFuLdJtAAAAQGUUccKOuGODuCBE/qJ6bczgvkIuBSHrUHICVwYdjNb0BdvcpQd/tznSmqtl0zfrVIVvSEAnlOmeIDw8WyzWEwQ="
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: signedEnvelope)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: signedEnvelope)
        mockKinService.stubSubmitTransactionResult = .init(stubAckedTransaction)
        mockKinService.stubCanWhitelistTransactionResult = false

        // Set up account updates in storage
        mockKinStorage.stubAdvanceSequenceResult = expectAccount
        mockKinStorage.stubDeductFromBalanceResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinStorage.stubInsertNewTransactionResult = [stubAckedTransaction]
        mockKinStorage.stubGetFeeResult = Quark(99)

        // Test
        let expect = expectation(description: "callback")
        sut.sendKinPayment(payment, memo: memo).then { resultPayment in
            XCTAssertTrue(self.mockKinStorage.sequenceAdvanced)
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 1000)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(resultPayment, stubAckedTransaction.kinPayments.first)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentUpgradeRequired() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        // Set up signed transaction returned by service
        let payment = KinPaymentItem(amount: Kin(1000), destAccountId: StubObjects.accountId2)
        let memo = KinMemo.none

        let signedEnvelope = "AAAAAOg2QBm0NeppntiRBPTrzbkKvo3F8SZyGqHco/tuLdJtAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA6DZAGbQ16mme2JEE9OvNuQq+jcXxJnIaodyj+24t0m0AAAABAAAAAEelh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88AAAAAAAAAAAF9eEAAAAAAAAAAAFuLdJtAAAAQGUUccKOuGODuCBE/qJ6bczgvkIuBSHrUHICVwYdjNb0BdvcpQd/tznSmqtl0zfrVIVvSEAnlOmeIDw8WyzWEwQ="
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: signedEnvelope)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: signedEnvelope)
        mockKinService.stubSubmitTransactionResult = .init(KinService.Errors.upgradeRequired)
        mockKinService.stubCanWhitelistTransactionResult = false

        // Set up account updates in storage
        mockKinStorage.stubAdvanceSequenceResult = expectAccount
        mockKinStorage.stubDeductFromBalanceResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinStorage.stubInsertNewTransactionResult = [stubAckedTransaction]
        mockKinStorage.stubGetFeeResult = Quark(99)

        // Test
        let expect = expectation(description: "callback")
        sut.sendKinPayment(payment, memo: memo).catch { error in
            XCTAssertEqual(error as! KinService.Errors, KinService.Errors.upgradeRequired)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPayInvoiceSucceed() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                accountId: key.accountId)

        // Set up signed transaction returned by service
        let signedEnvelope = "AAAAAOg2QBm0NeppntiRBPTrzbkKvo3F8SZyGqHco/tuLdJtAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAEAAAAA6DZAGbQ16mme2JEE9OvNuQq+jcXxJnIaodyj+24t0m0AAAABAAAAAEelh1WujKW7sQtSpf0P3aTdBVzypYIwYsZlZdQdOL88AAAAAAAAAAAF9eEAAAAAAAAAAAFuLdJtAAAAQGUUccKOuGODuCBE/qJ6bczgvkIuBSHrUHICVwYdjNb0BdvcpQd/tznSmqtl0zfrVIVvSEAnlOmeIDw8WyzWEwQ="
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: signedEnvelope)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: signedEnvelope, withInvoice: true)
        mockKinService.stubSubmitTransactionResult = .init(stubAckedTransaction)
        mockKinService.stubCanWhitelistTransactionResult = false

        // Set up account updates in storage
        mockKinStorage.stubAdvanceSequenceResult = expectAccount
        mockKinStorage.stubDeductFromBalanceResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinStorage.stubInsertNewTransactionResult = [stubAckedTransaction]
        mockKinStorage.stubGetFeeResult = Quark(99)

        // Test
        let expect = expectation(description: "callback")
        sut.payInvoice(processingAppIdx: .testApp,
                       destinationAccount: StubObjects.accountId2,
                       invoice: StubObjects.stubInvoice,
                       type: .p2p).then { resultPayment in
            XCTAssertTrue(self.mockKinStorage.sequenceAdvanced)
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 1000)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(resultPayment, stubAckedTransaction.kinPayments.first)
            XCTAssertNotNil(resultPayment.invoice)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testObserveBalancePassive() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinService.stubGetAccountResult = expectAccount


        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectBalance = expectation(description: "balance")
        sut.observeBalance(mode: .passive)
            .subscribe { balance in
                XCTAssertEqual(balance, expectAccount.balance)
                expectBalance.fulfill()
            }
            .disposedBy(disposeBag)

        waitForExpectations(timeout: 1)
    }

    func testObserveBalanceActive() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        let updatedAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                             balance: KinBalance(Kin(999)),
                                             status: .registered,
                                             sequence: 2)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectBalance = expectation(description: "balance")
        expectBalance.expectedFulfillmentCount = 3
        var returnedBalances = [KinBalance]()
        sut.observeBalance(mode: .active)
            .subscribe { balance in
                returnedBalances.append(balance)
                expectBalance.fulfill()
            }
            .disposedBy(disposeBag)

        stubAccountSubject.onNext(updatedAccount)
        mockKinStorage.stubGetAccountResult = updatedAccount
        mockKinStorage.stubUpdateAccountResult = updatedAccount
        mockKinService.stubGetAccountResult = updatedAccount

        waitForExpectations(timeout: 1)

        XCTAssertEqual(returnedBalances, [KinBalance(Kin(10000)), KinBalance(Kin(10000)), KinBalance(Kin(999))])
    }

    func testObservePaymentsPassiveEmpty() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = nil
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectPayments = expectation(description: "expect payments")
        _ = sut.observePayments(mode: .passive)
            .subscribe { resultPayments in
                XCTAssertTrue(resultPayments.isEmpty)
                expectPayments.fulfill()
            }
            .disposedBy(disposeBag)

        waitForExpectations(timeout: 1)
    }

    func testObservePaymentsPassiveTransactions() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = KinTransactions(items: [StubObjects.transaction],
                                                                         headPagingToken: nil,
                                                                         tailPagingToken: nil)
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectPayments = expectation(description: "expect payments")
        let paymentObservable = sut.observePayments(mode: .passive)
            .subscribe { resultPayments in
                XCTAssertEqual(resultPayments.first!.id.transactionHash, StubObjects.transaction.transactionHash)
                expectPayments.fulfill()
        }

        waitForExpectations(timeout: 1)
        paymentObservable.dispose()
    }

    func testObservePaymentsNextPage() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = KinTransactions(items: [StubObjects.transaction],
                                                                         headPagingToken: "head",
                                                                         tailPagingToken: "tail")
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []
        let stubNextTransaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope2)
        mockKinService.stubGetTransactionPageResult = [stubNextTransaction]

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectNextPage = expectation(description: "Next page")
        expectNextPage.expectedFulfillmentCount = 2
        expectNextPage.assertForOverFulfill = false

        var resultPayments = [KinPayment]()
        let nextPageObservable = sut.observePayments(mode: .passive)
            .subscribe { payments in
                resultPayments += payments
                expectNextPage.fulfill()
            }
            .requestNextPage()

        waitForExpectations(timeout: 1)
        nextPageObservable.dispose()

        XCTAssertEqual(resultPayments.first!.id.transactionHash, StubObjects.transaction.transactionHash)
        XCTAssertEqual(resultPayments[1].id.transactionHash, stubNextTransaction.transactionHash)
    }

    func testObservePaymentsPreviousPage() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = KinTransactions(items: [StubObjects.transaction],
                                                                         headPagingToken: nil,
                                                                         tailPagingToken: "tail")
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []
        let stubPrevTransaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope2)
        mockKinService.stubGetTransactionPageResult = [stubPrevTransaction]

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectPrevPage = expectation(description: "prev page")
        expectPrevPage.expectedFulfillmentCount = 2
        expectPrevPage.assertForOverFulfill = false

        var resultPayments = [KinPayment]()
        let prevPageObservable = sut.observePayments(mode: .passive)
            .subscribe { payments in
                resultPayments += payments
                expectPrevPage.fulfill()
            }
            .requestPreviousPage()

        waitForExpectations(timeout: 1)
        prevPageObservable.dispose()

        XCTAssertEqual(resultPayments.first!.id.transactionHash, StubObjects.transaction.transactionHash)
        XCTAssertEqual(resultPayments[1].id.transactionHash, stubPrevTransaction.transactionHash)
    }

    func testObservePaymentsActiveNewOnlyTransactions() {
        // Set up account in storage
        let key = try! KeyPair(secretSeed: StubObjects.seed1)
        let expectAccount = try! KinAccount(key: KinAccount.Key(accountId: key.accountId),
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = nil
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = [StubObjects.transaction]

        let stubAccountSubject = ValueSubject<KinAccount>()
        let stubPaymentSubject = ValueSubject<KinTransaction>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject
        mockKinService.stubStreamTransactionObservable = stubPaymentSubject

        sut = KinAccountContext(environment: mockEnv, accountId: expectAccount.id)

        let expectPayments = expectation(description: "expect payments")
        let paymentObservable = sut.observePayments(mode: .activeNewOnly)
            .subscribe { resultPayments in
                XCTAssertEqual(resultPayments.first!.id.transactionHash, StubObjects.transaction.transactionHash)
                expectPayments.fulfill()
        }

        stubPaymentSubject.onNext(StubObjects.transaction)

        waitForExpectations(timeout: 1)

        paymentObservable.dispose()
    }

    func testClearStorage() {
        sut = KinAccountContext(environment: mockEnv, accountId: StubObjects.accountId1)
        _ = sut.clearStorage().then {
            XCTAssertEqual(self.mockKinStorage.accountRemoved, StubObjects.accountId1)
        }
    }

    func testNewAccountBuilder() {
        XCTAssertNoThrow(try KinAccountContext.Builder(env: mockEnv).createNewAccount().build())
    }

    func testExistingAccountBuilder() {
        sut = KinAccountContext.Builder(env: mockEnv)
            .useExistingAccount(StubObjects.accountId1)
            .build()

        XCTAssertEqual(sut.accountId, StubObjects.accountId1)
    }

    func testImportKeyBuilder() {
        let key = try! KinAccount.Key(secretSeed: StubObjects.seed1)
        XCTAssertNoThrow(try KinAccountContext.Builder(env: mockEnv).importExistingPrivateKey(key).build())
    }
}
