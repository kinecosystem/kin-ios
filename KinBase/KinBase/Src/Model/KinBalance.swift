//
//  KinBalance.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct KinBalance: Equatable {
    public let amount: Kin
    public let pendingAmount: Kin

    public static let zero: KinBalance = KinBalance()

    init(_ amount: Kin) {
        self.amount = amount
        self.pendingAmount = amount
    }

    init(amount: Kin = .zero, pendingAmount: Kin = .zero) {
        self.amount = amount
        self.pendingAmount = pendingAmount
    }
}
