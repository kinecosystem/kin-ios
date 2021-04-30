//
//  KinTransactionTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import stellarsdk
@testable import KinBase

class KinTransactionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testTransactionToKinPayments() {
        let transaction = StubObjects.transaction
        let payments = transaction.kinPayments

        XCTAssertEqual(payments.count, 1)
        XCTAssertEqual(payments.first!.id.offset, 0)
        XCTAssertEqual(payments.first!.id.transactionHash, transaction.transactionHash)
        XCTAssertEqual(payments.first!.id.value, transaction.transactionHash.rawValue + [0])
        XCTAssertEqual(payments.first!.amount, transaction.paymentOperations.first!.amount)
        XCTAssertEqual(payments.first!.fee, transaction.fee)
        XCTAssertEqual(payments.first!.sourceAccountId, transaction.sourceAccount)
        XCTAssertEqual(payments.first!.destAccountId, transaction.paymentOperations.first?.destination)
        XCTAssertEqual(payments.first!.memo, transaction.memo)
        XCTAssertEqual(payments.first!.timestamp, transaction.record.timestamp)
    }
}
