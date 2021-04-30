//
//  KinAccountContextTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Promises
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
                                 dispatchQueue: .main,
                                 logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag.dispose()
    }

    // TODO: remove
//    func testSubmitTransactionLive() {
//        let key = KeyPair.generate()!
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
//        let context = KinAccountContext.Builder(env: agoraEnv)
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
//        let key = KeyPair.generate()!
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
//        let context = KinAccountContext.Builder(env: agoraEnv)
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
        let key = KeyPair.generate()!
        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)

        let expectAccount = KinAccount(publicKey: key.publicKey)
        mockKinService.stubGetAccountResult = expectAccount
        
        mockKinStorage.stubUpdateAccountResult = expectAccount

        let expect = expectation(description: "callback")
        sut.getAccount().then { account in
            XCTAssertEqual(account, expectAccount)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testGetAccountInStorageRegistered() {
        let key = KeyPair.generate()!
        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)

        let expectAccount = KinAccount(publicKey: key.publicKey, privateKey: key.privateKey,
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

    func testGetPaymentsForTransactionHashSucceed() {
        sut = KinAccountContext(environment: mockEnv, account: StubObjects.account1)

        let expectTransaction = StubObjects.transaction
        mockKinService.stubGetTransactionResult = expectTransaction

        let expect = expectation(description: "callback")
        let hash = KinTransactionHash(Data(repeating: 7, count: 64))
        sut.getPaymentsForTransactionHash(hash).then { payments in
            XCTAssertEqual(payments, expectTransaction.kinPayments)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentsSucceed() {
        // Set up account in storage
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)

        // Set up signed transaction returned by service
        let payments = [
            KinPaymentItem(amount: Kin(1000), destAccount: StubObjects.account1),
            KinPaymentItem(amount: Kin(990), destAccount: StubObjects.account2),
        ]
        let memo = KinMemo.none
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: StubObjects.transactionEnvelopeSigned)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: StubObjects.transactionEnvelopeSigned)
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
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 25)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(payments, stubAckedTransaction.kinPayments)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentSucceed() {
        // Set up account in storage
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)

        // Set up signed transaction returned by service
        let payment = KinPaymentItem(amount: Kin(1000), destAccount: StubObjects.account2)
        let memo = KinMemo.none
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: StubObjects.transactionEnvelopeSigned)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: StubObjects.transactionEnvelopeSigned)
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
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 25)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(resultPayment, stubAckedTransaction.kinPayments.first)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSendKinPaymentUpgradeRequired() {
        // Set up account in storage
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(publicKey: key.publicKey, privateKey: key.privateKey,
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)

        // Set up signed transaction returned by service
        let payment = KinPaymentItem(amount: Kin(1000), destAccount: StubObjects.account2)
        let memo = KinMemo.none
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: StubObjects.transactionEnvelopeSigned)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: StubObjects.transactionEnvelopeSigned)
        mockKinService.stubSubmitTransactionResult = .init(KinServiceV4.Errors.upgradeRequired)
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
            XCTAssertEqual(error as! KinServiceV4.Errors, KinServiceV4.Errors.upgradeRequired)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPayInvoiceSucceed() {
        // Set up account in storage
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(publicKey: key.publicKey, privateKey: key.privateKey,
                                            balance: KinBalance(Kin(10000)),
                                            status: .registered,
                                            sequence: 1)

        mockKinStorage.stubGetAccountResult = expectAccount

        sut = KinAccountContext(environment: mockEnv,
                                account: key.publicKey)
        
        let stubInFlightTransaction = StubObjects.inFlightTransaction(from: StubObjects.transactionEnvelopeSigned)

        mockKinService.stubBuildAndSignTransactionResult = stubInFlightTransaction
        mockKinService.stubGetAccountResult = expectAccount

        // Set up submited transaction on serivce
        let stubAckedTransaction = StubObjects.ackedTransaction(from: StubObjects.transactionEnvelopeSigned, withInvoice: true)
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
        sut.payInvoice(processingAppIdx: .testApp, destinationAccount: StubObjects.account2, invoice: StubObjects.stubInvoice, type: .p2p).then { resultPayment in
            XCTAssertTrue(self.mockKinStorage.sequenceAdvanced)
            XCTAssertEqual(self.mockKinStorage.remainingBalance, KinBalance(Kin(10000 - 25)))
            XCTAssertEqual(self.mockKinStorage.transactionInserted, stubAckedTransaction)
            XCTAssertEqual(resultPayment, stubAckedTransaction.kinPayments.first)
            XCTAssertNotNil(resultPayment.invoice)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testObserveBalancePassive() {
        // Set up account in storage
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )

        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinService.stubGetAccountResult = expectAccount


        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)

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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )
        
        let updatedAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(999)),
            status: .registered,
            sequence: 2
        )
        
        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubUpdateAccountResult = expectAccount
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)

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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )
        
        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = nil
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []

        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject

        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)

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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )
        
        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = KinTransactions(
            items: [StubObjects.transaction],
            headPagingToken: nil,
            tailPagingToken: nil
        )
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []
        
        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject
        
        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)
        
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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )
        
        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = KinTransactions(
            items: [StubObjects.transaction],
            headPagingToken: "head",
            tailPagingToken: "tail"
        )
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = []
        let stubNextTransaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope2)
        mockKinService.stubGetTransactionPageResult = [stubNextTransaction]
        
        let stubAccountSubject = ValueSubject<KinAccount>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject
        
        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)

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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(publicKey: key.publicKey, privateKey: key.privateKey,
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

        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)

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
        let key = KeyPair(seed: StubObjects.seed1)
        let expectAccount = KinAccount(
            publicKey: key.publicKey, privateKey: key.privateKey,
            balance: KinBalance(Kin(10000)),
            status: .registered,
            sequence: 1
        )
        
        mockKinStorage.stubGetAccountResult = expectAccount
        mockKinStorage.stubGetStoredTransactionsResult = nil
        mockKinService.stubGetAccountResult = expectAccount
        mockKinService.stubGetLatestTransactions = [StubObjects.transaction]
        
        let stubAccountSubject = ValueSubject<KinAccount>()
        let stubPaymentSubject = ValueSubject<KinTransaction>()
        mockKinService.stubStreamAccountObservable = stubAccountSubject
        mockKinService.stubStreamTransactionObservable = stubPaymentSubject
        
        sut = KinAccountContext(environment: mockEnv, account: expectAccount.publicKey)
        
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
        sut = KinAccountContext(environment: mockEnv, account: StubObjects.account1)
        _ = sut.clearStorage().then {
            XCTAssertEqual(self.mockKinStorage.accountRemoved, StubObjects.account1)
        }
    }

    func testNewAccountBuilder() {
        XCTAssertNoThrow(try KinAccountContext.Builder(env: mockEnv).createNewAccount().build())
    }

    func testExistingAccountBuilder() {
        sut = KinAccountContext.Builder(env: mockEnv)
            .useExistingAccount(StubObjects.account1)
            .build()

        XCTAssertEqual(sut.accountPublicKey, StubObjects.account1)
    }

    func testImportKeyBuilder() {
        let key = StubObjects.keyPair1
        XCTAssertNoThrow(try KinAccountContext.Builder(env: mockEnv).importExistingPrivateKey(key).build())
    }
}
