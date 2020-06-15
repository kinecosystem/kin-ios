//
//  KinMemo.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct KinMemo: Equatable {
    let rawValue: [Byte]

    public static let none = KinMemo(text: "")

    public var text: String {
        return String(bytes: rawValue, encoding: .utf8) ?? ""
    }

    public var data: Data {
        return Data(rawValue)
    }

    public init(text: String) {
        guard let data = text.data(using: .utf8) else {
            self.rawValue = []
            return
        }

        self.rawValue = [Byte](data)
    }
}
