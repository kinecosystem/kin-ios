//
//  KinMemo.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public struct KinMemo: Equatable {
    enum MemoType {
        case text
        case bytes
    }

    let rawValue: [Byte]
    let type: MemoType

    public static let none = KinMemo(text: "")

    public var text: String {
        return String(bytes: rawValue, encoding: .utf8) ?? ""
    }

    public var data: Data {
        return Data(rawValue)
    }

    public var stellarMemo: Memo? {
        switch type {
        case .text:
            return try? Memo(text: text)
        case .bytes:
            return try? Memo(hash: Data(rawValue))
        }
    }

    public var agoraMemo: KinBinaryMemo? {
        switch type {
        case .text:
            return nil
        case .bytes:
            return try? KinBinaryMemo(data: data)
        }
    }

    public init(text: String) {
        guard let data = text.data(using: .utf8) else {
            self.rawValue = []
            self.type = .bytes
            return
        }

        self.rawValue = [Byte](data)
        self.type = .text
    }

    public init(bytes: [Byte]) {
        self.rawValue = bytes
        self.type = .bytes
    }
}
