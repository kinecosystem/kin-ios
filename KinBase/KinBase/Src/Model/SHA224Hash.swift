//
//  SHA224Hash.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

/// The SHA-224 hash of an `Invoice` or `InvoiceList`.
public struct SHA224Hash: Equatable, Hashable {
    /// UTF-8 String representation of the 29 bytes representing the first 230 bits of a SHA-256
    public let encodedValue: String

    private init(bytes: [Byte]) {
        self.encodedValue = Data(bytes).base64EncodedString()
    }

    public init(encodedValue: String) {
        self.encodedValue = encodedValue
    }

    public static func of(bytes: [Byte]) -> SHA224Hash {
        return SHA224Hash(bytes: Digest.sha224(bytes))
    }

    public static func just(bytes: [Byte]) -> SHA224Hash {
        return SHA224Hash(bytes: bytes)
    }

    public func decode() -> [Byte] {
        return [Byte](Data(base64Encoded: encodedValue)!)
    }
}
