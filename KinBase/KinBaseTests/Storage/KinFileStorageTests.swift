//
//  KinFileStorageTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class KinFileStorageTests: XCTestCase {
    var sut: KinFileStorage!

    override func setUp() {
        sut = KinFileStorage(directory: FileManager.default.temporaryDirectory,
                             network: .testNet)
    }

    override func tearDown() {
        _ = sut.clearStorage()
    }

    func testAddAndRetrieveAccountSucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let expectAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(expectAccount).then { account in
            XCTAssertEqual(account, expectAccount)
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let expectRetrieve = expectation(description: "account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertEqual(account, expectAccount)
            expectRetrieve.fulfill()
        }

        wait(for: [expectRetrieve], timeout: 1)
    }

    func testAddAndRetrieveAccountNoPrivateKeySucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let publicOnlyKey = KinAccount.Key(publicKey: key.publicKey)
        let expectAccount = KinAccount(key: publicOnlyKey,
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(expectAccount).then { account in
            XCTAssertEqual(account, expectAccount)
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let expectRetrieve = expectation(description: "account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertEqual(account, expectAccount)
            expectRetrieve.fulfill()
        }

        wait(for: [expectRetrieve], timeout: 1)
    }

    func testGetAccountEmpty() {
        let accountId = StubObjects.accountId1
        let expectRetrieve = expectation(description: "account retrieved")
        sut.getAccount(accountId).then { account in
            XCTAssertNil(account)
            expectRetrieve.fulfill()
        }

        wait(for: [expectRetrieve], timeout: 1)
    }

    func testUpdateAccountSucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let oldAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "0")!),
                                       status: .unregistered,
                                       sequence: 0)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(oldAccount).then { account in
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let updateAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "999")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let expectUpdate = expectation(description: "account updated")
        sut.updateAccount(updateAccount).then { account in
            XCTAssertEqual(account, updateAccount)
            expectUpdate.fulfill()
        }

        wait(for: [expectUpdate], timeout: 1)

        let expectGet = expectation(description: "updated account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertEqual(account, updateAccount)
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testRemoveAccountSucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let oldAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "0")!),
                                       status: .unregistered,
                                       sequence: 0)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(oldAccount).then { account in
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let expectRemove = expectation(description: "account removed")
        sut.removeAccount(accountId: key.accountId).then { _ in
            expectRemove.fulfill()
        }

        wait(for: [expectRemove], timeout: 1)

        let expectGet = expectation(description: "account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertNil(account)
            expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testGetAllAccountIdsEmpty() {
        let expectEmpty = expectation(description: "no account id retrieved")
        sut.getAllAccountIds().then { ids in
            XCTAssertTrue(ids.isEmpty)
            expectEmpty.fulfill()
        }

        wait(for: [expectEmpty], timeout: 1)
    }

    func testGetAllAccountIdsSucceed() {
        for i in 0...2 {
            let key = try! KeyPair.generateRandomKeyPair()
            let expectAccount = KinAccount(key: key,
                                           balance: KinBalance(Kin(string: "9999.99400")!),
                                           status: .registered,
                                           sequence: Int64(i))
            let expectAdd = expectation(description: "account added \(i)")
            sut.addAccount(expectAccount).then { account in
                expectAdd.fulfill()
            }
        }

        waitForExpectations(timeout: 1)

        let expectIds = expectation(description: "account ids retrieved")
        sut.getAllAccountIds().then { ids in
            XCTAssertEqual(ids.count, 3)
            expectIds.fulfill()
        }

        wait(for: [expectIds], timeout: 1)
    }

    func testStoreAndGetTransactionsSucceed() {
        let accountId = StubObjects.accountId1

        let expectEnvelope1 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAANhAAAg/dXTMFwEyDLyL0+Yr+f1f4LYZEEubaO47gaTAQAAAAEAAAABAAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAAQAAAAAhBy6pDvoUUywETo/12Fol9ti5cGuxfxDfxT3Gt4ogLwAAAAAAAAAAALuu4AAAAAAAAAABwhjv+wAAAEDQ3WmCKQd8CSd4+uF/Oj3WxgG5o4XirKsO0H37ke9PZ8QG3CYMOgAPrAA0YD3cfx/87x8VIW/NMj69RRLtZL4G"
        let invoice = StubObjects.stubInvoice
        let invoiceList = try! InvoiceList(invoices: [invoice])
        let transaction1 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope1)!),
                                              record: .historical(ts: 123456789,
                                                                  resultXdrBytes: [2, 1],
                                                                  pagingToken: "page1"),
                                              network: .testNet,
                                              invoiceList: invoiceList)
        let expectEnvelope2 = "AAAAAF3F+luUcf1MXVhQNVM5hmYFAGO8h2DL5wv4rCHCGO/7AAAAZAA65AMAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIQcuqQ76FFMsBE6P9dhaJfbYuXBrsX8Q38U9xreKIC8AAAAAAAAAAAC7ruAAAAAAAAAAAcIY7/sAAABA6Qs1HI1B40fJNBc0RR0R7WfLDqKgniTGcT7yWa5ogAlEHwIuX54fHPv+sqKmCXa9JRadOmnPxi0/24UGFuUrDw=="
        let transaction2 = try! KinTransaction(envelopeXdrBytes: [Byte](Data(base64Encoded: expectEnvelope2)!),
                                               record: .historical(ts: 1234567890,
                                                                   resultXdrBytes: [2, 1],
                                                                   pagingToken: "page2"),
                                               network: .testNet)

        let expectStore = expectation(description: "transactions stored")
        let expectTransactions = [transaction1, transaction2]
        sut.storeTransactions(accountId: accountId, transactions: expectTransactions)
            .then { transactions in
                XCTAssertEqual(transactions, expectTransactions)
                expectStore.fulfill()
        }

        wait(for: [expectStore], timeout: 1000)

        let expectGet = expectation(description: "transactions retrieved")
        sut.getStoredTransactions(accountId: accountId)
            .then { transactions in
                XCTAssertEqual(transactions?.items, expectTransactions)
                XCTAssertEqual(transactions?.headPagingToken, "page1")
                XCTAssertEqual(transactions?.tailPagingToken, "page2")
                expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1000)
    }

    func testGetTransactionEmpty() {
        let accountId = StubObjects.accountId1
        let expectGet = expectation(description: "transactions retrieved")
        sut.getStoredTransactions(accountId: accountId)
            .then { transactions in
                XCTAssertNil(transactions)
                expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testInsertNewTransaction() {
        let accountId = StubObjects.accountId1
        let transaction1 = StubObjects.transaction

        let expectStore = expectation(description: "transactions stored")
        sut.insertNewTransaction(accountId: accountId, newTransaction: transaction1)
            .then { transactions in
                XCTAssertEqual(transactions.first, transaction1)
                expectStore.fulfill()
        }

        wait(for: [expectStore], timeout: 1)

        let expectGet = expectation(description: "transactions retrieved")
        sut.getStoredTransactions(accountId: accountId)
            .then { transactions in
                XCTAssertEqual(transactions?.items.first, transaction1)
                XCTAssertEqual(transactions?.headPagingToken, transaction1.record.pagingToken)
                XCTAssertEqual(transactions?.tailPagingToken, transaction1.record.pagingToken)
                expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testUpsertNewTransaction() {
        let accountId = StubObjects.accountId1
        let transaction1 = StubObjects.transaction
        let transaction2 = StubObjects.ackedTransaction(from: StubObjects.transactionEvelope2)

        let expectStore = expectation(description: "transactions stored")
        sut.storeTransactions(accountId: accountId, transactions: [transaction1, transaction2])
            .then { transactions in
                expectStore.fulfill()
        }

        wait(for: [expectStore], timeout: 1)

        let expectUpsert = expectation(description: "transactions upserted")
        let updatedTransaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope2)
        sut.upsertNewTransactions(accountId: accountId, newTransactions: [updatedTransaction])
            .then { transactions in
                XCTAssertEqual(transactions, [updatedTransaction, transaction1])
                expectUpsert.fulfill()
        }

        wait(for: [expectUpsert], timeout: 1)

        let expectGet = expectation(description: "transactions retrieved")
        sut.getStoredTransactions(accountId: accountId)
            .then { transactions in
                XCTAssertEqual(transactions?.items, [updatedTransaction, transaction1])
                expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testUpsertOldTransaction() {
        let accountId = StubObjects.accountId1
        let transaction1 = StubObjects.transaction
        let transaction2 = StubObjects.ackedTransaction(from: StubObjects.transactionEvelope2)

        let expectStore = expectation(description: "transactions stored")
        sut.storeTransactions(accountId: accountId, transactions: [transaction1, transaction2])
            .then { transactions in
                expectStore.fulfill()
        }

        wait(for: [expectStore], timeout: 1)

        let expectUpsert = expectation(description: "transactions upserted")
        let updatedTransaction = StubObjects.historicalTransaction(from: StubObjects.transactionEvelope2)
        sut.upsertOldTransactions(accountId: accountId, oldTransactions: [updatedTransaction])
            .then { transactions in
                XCTAssertEqual(transactions, [transaction1, updatedTransaction])
                expectUpsert.fulfill()
        }

        wait(for: [expectUpsert], timeout: 1)

        let expectGet = expectation(description: "transactions retrieved")
        sut.getStoredTransactions(accountId: accountId)
            .then { transactions in
                XCTAssertEqual(transactions?.items, [transaction1, updatedTransaction])
                expectGet.fulfill()
        }

        wait(for: [expectGet], timeout: 1)
    }

    func testAdvanceSequenceSucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let expectAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(expectAccount).then { account in
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let expectAdvance = expectation(description: "sequence advanced")
        sut.advanceSequence(accountId: key.accountId).then { account in
            XCTAssertEqual(account.sequence, 24497836326387719)
            expectAdvance.fulfill()
        }

        wait(for: [expectAdvance], timeout: 1)

        let expectRetrieve = expectation(description: "account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertEqual(account!.sequence, 24497836326387719)
            expectRetrieve.fulfill()
        }

        wait(for: [expectRetrieve], timeout: 1)
    }

    func testDeductBalanceSucceed() {
        let key = try! KeyPair.generateRandomKeyPair()
        let expectAccount = KinAccount(key: key,
                                       balance: KinBalance(Kin(string: "9999.99400")!),
                                       status: .registered,
                                       sequence: 24497836326387718)
        let expectAdd = expectation(description: "account added")
        sut.addAccount(expectAccount).then { account in
            expectAdd.fulfill()
        }

        wait(for: [expectAdd], timeout: 1)

        let expectAdvance = expectation(description: "balance deducted")
        sut.deductFromAccountBalance(accountId: key.accountId, amount: Kin(string: "999.99400")!).then { account in
            XCTAssertEqual(account.balance.amount, Kin(string: "9000"))
            expectAdvance.fulfill()
        }

        wait(for: [expectAdvance], timeout: 1)

        let expectRetrieve = expectation(description: "account retrieved")
        sut.getAccount(key.accountId).then { account in
            XCTAssertEqual(account!.balance.amount, Kin(string: "9000"))
            expectRetrieve.fulfill()
        }

        wait(for: [expectRetrieve], timeout: 1)
    }

    func testSetAndGetMinFee() {
        XCTAssertNil(sut.getMinFee())
        sut.setMinFee(1000)
        XCTAssertEqual(sut.getMinFee(), 1000)
    }
    
    func testSetAndGetCID() {
        let cid1 = sut.getOrCreateCID()
        let cid2 = sut.getOrCreateCID()
        XCTAssertEqual(cid1, cid2)
    }

    func testAddAndGetInvoices() {
        let expectInvoiceLists = [StubObjects.stubInvoiceList1]
        let expectAdd = expectation(description: "add invoice")
        sut.addInvoiceLists(accountId: StubObjects.accountId1,
                            invoiceLists: [StubObjects.stubInvoiceList1])
            .then { (invoiceLists) in
                XCTAssertEqual(invoiceLists, expectInvoiceLists)
                expectAdd.fulfill()
            }

        wait(for: [expectAdd], timeout: 1)

        let expectGet = expectation(description: "get invoice")
        sut.getInvoiceListsMapForAccountId(account: StubObjects.accountId1)
            .then { invoiceMap in
                XCTAssertEqual(invoiceMap[StubObjects.stubInvoiceList1.id], StubObjects.stubInvoiceList1)
                expectGet.fulfill()
            }

        wait(for: [expectGet], timeout: 1)
    }

    func testAddToExistingInvoices() {
        let expectInvoiceLists = [StubObjects.stubInvoiceList1]
        let expectAdd = expectation(description: "add invoice1")
        sut.addInvoiceLists(accountId: StubObjects.accountId1,
                            invoiceLists: [StubObjects.stubInvoiceList1])
            .then { (invoiceLists) in
                XCTAssertEqual(invoiceLists, expectInvoiceLists)
                expectAdd.fulfill()
            }

        wait(for: [expectAdd], timeout: 1)

        let expectInvoiceLists2 = [StubObjects.stubInvoiceList2]
        let expectAdd2 = expectation(description: "add invoice2")
        sut.addInvoiceLists(accountId: StubObjects.accountId1,
                            invoiceLists: [StubObjects.stubInvoiceList2])
            .then { (invoiceLists) in
                XCTAssertEqual(invoiceLists, expectInvoiceLists2)
                expectAdd2.fulfill()
            }

        wait(for: [expectAdd2], timeout: 1)

        let expectGet = expectation(description: "get invoice")
        sut.getInvoiceListsMapForAccountId(account: StubObjects.accountId1)
            .then { invoiceMap in
                XCTAssertEqual(invoiceMap[StubObjects.stubInvoiceList1.id], StubObjects.stubInvoiceList1)
                XCTAssertEqual(invoiceMap[StubObjects.stubInvoiceList2.id], StubObjects.stubInvoiceList2)
                expectGet.fulfill()
            }

        wait(for: [expectGet], timeout: 1)
    }

    func testAddAndGetInvoiceDifferentAccounts() {
        let expectInvoiceLists = [StubObjects.stubInvoiceList1]
        let expectAdd = expectation(description: "add invoice1")
        sut.addInvoiceLists(accountId: StubObjects.accountId1,
                            invoiceLists: [StubObjects.stubInvoiceList1])
            .then { (invoiceLists) in
                XCTAssertEqual(invoiceLists, expectInvoiceLists)
                expectAdd.fulfill()
            }

        wait(for: [expectAdd], timeout: 1)

        let expectInvoiceLists2 = [StubObjects.stubInvoiceList2]
        let expectAdd2 = expectation(description: "add invoice2")
        sut.addInvoiceLists(accountId: StubObjects.accountId2,
                            invoiceLists: [StubObjects.stubInvoiceList2])
            .then { (invoiceLists) in
                XCTAssertEqual(invoiceLists, expectInvoiceLists2)
                expectAdd2.fulfill()
            }

        wait(for: [expectAdd2], timeout: 1)

        let expectGet1 = expectation(description: "get invoice 1")
        sut.getInvoiceListsMapForAccountId(account: StubObjects.accountId1)
            .then { invoiceMap in
                XCTAssertEqual(invoiceMap[StubObjects.stubInvoiceList1.id], StubObjects.stubInvoiceList1)
                XCTAssertNil(invoiceMap[StubObjects.stubInvoiceList2.id])
                expectGet1.fulfill()
            }

        wait(for: [expectGet1], timeout: 1)

        let expectGet2 = expectation(description: "get invoice 2")
        sut.getInvoiceListsMapForAccountId(account: StubObjects.accountId2)
            .then { invoiceMap in
                XCTAssertEqual(invoiceMap[StubObjects.stubInvoiceList2.id], StubObjects.stubInvoiceList2)
                XCTAssertNil(invoiceMap[StubObjects.stubInvoiceList1.id])
                expectGet2.fulfill()
            }

        wait(for: [expectGet2], timeout: 1)
    }

    func testGetInvoiceListEmpty() {
        let expect = expectation(description: "get empty invoice")
        sut.getInvoiceListsMapForAccountId(account: StubObjects.accountId1)
            .then { map in
                XCTAssertTrue(map.isEmpty)
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)
    }
}
