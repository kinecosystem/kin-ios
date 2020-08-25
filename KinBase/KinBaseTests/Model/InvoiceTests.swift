//
//  InvoiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class InvoiceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testLineItemValidation() {
        var longTitle: String = ""
        for _ in 0...128 {
            longTitle.append("a")
        }
        XCTAssertThrowsError(try LineItem(title: longTitle, amount: Kin(1)), "invalid title") { error in
            XCTAssertEqual(error as! LineItem.LineItemFormatError, LineItem.LineItemFormatError.invalidTitle)
        }

        var longDesc: String = ""
        for _ in 0...256 {
            longDesc.append("a")
        }
        XCTAssertThrowsError(try LineItem(title: "title", description: longDesc, amount: Kin(1)), "descriptionTooLong") { error in
            XCTAssertEqual(error as! LineItem.LineItemFormatError, LineItem.LineItemFormatError.descriptionTooLong)
        }

        var longSku = [Byte]()
        for _ in 0...128 {
            longSku.append(1)
        }
        let sku = SKU(bytes: longSku)
        XCTAssertThrowsError(try LineItem(title: "title", description: "description", amount: Kin(1), sku: sku), "long sku") { error in
            XCTAssertEqual(error as! LineItem.LineItemFormatError, LineItem.LineItemFormatError.skuTooLong)
        }
    }

    func testInvoiceValidation() {
        XCTAssertThrowsError(try Invoice(lineItems: []), "no line item") { error in
            XCTAssertEqual(error as! Invoice.InvoiceFormatError, Invoice.InvoiceFormatError.atLeastOneLineItem)
        }

        var items = [LineItem]()
        for _ in 0...1024 {
            items.append(try! LineItem(title: "title", amount: Kin(1)))
        }

        XCTAssertThrowsError(try Invoice(lineItems: items), "too many line items") { error in
            XCTAssertEqual(error as! Invoice.InvoiceFormatError, Invoice.InvoiceFormatError.tooManyLineItems)
        }
    }
}
