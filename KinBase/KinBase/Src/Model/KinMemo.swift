//
//  KinMemo.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct KinMemo: Equatable {

    let bytes: [Byte]
    let type: MemoType

    public static let none = KinMemo(text: "")

    public var text: String {
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }

    public var data: Data {
        return Data(bytes)
    }

    public init(text: String) {
        guard let data = text.data(using: .utf8) else {
            self.bytes = []
            self.type = .bytes
            return
        }

        self.bytes = [Byte](data)
        self.type = .text
    }

    public init(bytes: [Byte]) {
        self.bytes = bytes
        self.type = .bytes
    }
}

extension KinMemo {
    enum MemoType {
        case text
        case bytes
    }
}

extension KinMemo {
    public var agoraMemo: KinBinaryMemo? {
        switch type {
        case .text:
            return nil
        case .bytes:
            return try? KinBinaryMemo(data: data)
        }
    }
}
