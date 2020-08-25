//
//  KinDesignInvoiceTableView.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinDesign

class KinDesignInvoiceTableView: UIViewController {

    var invoice: InvoiceDisplayable = {
        var invoices = [InvoiceDisplayable.LineItemDisplayable]()
        for i in 0...10 {
            if i % 2 == 0 {
                let lineItem1 = InvoiceDisplayable.LineItemDisplayable(title: "Item \(i)",
                                                                       description: "Item description \(i).",
                                                                       amount: Decimal(integerLiteral: 25 * i))
                invoices.append(lineItem1)
            } else {
                let lineItem2 = InvoiceDisplayable.LineItemDisplayable(title: "Item \(i) a long long long long long long title",
                                                                       description: "Item description \(i), a long long long long long long long description, two lines max.",
                                                                       amount: Decimal(integerLiteral: 25000))
                invoices.append(lineItem2)
            }
        }

        return InvoiceDisplayable(lineItems: invoices)
    }()

    lazy var tableViewController: InvoiceTableViewController = {
        let table = InvoiceTableViewController()
        table.invoice = self.invoice
        table.delegate = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(tableViewController)

        view.addSubview(tableViewController.view)
    }
}

extension KinDesignInvoiceTableView: InvoiceTableViewControllerDelegate {
    func invoiceTablePayTapped() {
        print("pay now tapped")
    }
}
