//
//  KinTypes.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

fileprivate struct Constants {
    static let kinAmountMaxPrecision: Int = 5
    static let quarkToKinConversion: Int = 100000
}

public typealias Byte = UInt8

public typealias Kin = Decimal

public typealias Quark = Int64

public extension Kin {
    var quark: Quark {
        return NSDecimalNumber(decimal: self * Decimal(Constants.quarkToKinConversion)).int64Value
    }
}

public extension Quark {
    var kin: Kin {
        return Decimal(self) / Decimal(Constants.quarkToKinConversion)
    }
}
