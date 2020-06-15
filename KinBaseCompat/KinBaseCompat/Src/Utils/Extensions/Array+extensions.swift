//
// Array+extensions.swift
// KinUtil
//
// Created by Kik Interactive Inc.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

public extension Array where Element == UInt8 {
    var hexString: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
