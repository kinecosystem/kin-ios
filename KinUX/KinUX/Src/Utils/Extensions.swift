//
//  Extensions.swift
//  KinDesign
//
//  Created by Kik Engineering on 2019-11-25.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase
import KinDesign

extension Bundle {
    class func kinUx() -> Bundle? {
        return Bundle(identifier: "org.kin..KinUX")
    }
}

extension Invoice {
    public var displayable: InvoiceDisplayable {
        let lineItemsDisplayables = lineItems.map { $0.displayable }
        return InvoiceDisplayable(lineItems: lineItemsDisplayables,
                                  fee: Decimal(0))
    }
}

extension LineItem {
    public var displayable: InvoiceDisplayable.LineItemDisplayable {
        return .init(title: title,
                     description: description ?? "",
                     amount: amount)
    }
}
