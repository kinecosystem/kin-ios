//
//  Transaction.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

/**
 `Memo` is a encodable data type used to attach arbitrary details `Transaction` such as an order number.
 */
public enum Memo {
    case MEMO_NONE
    case MEMO_TEXT (String)
    case MEMO_ID (UInt64)
    case MEMO_HASH (Data)
    case MEMO_RETURN (Data)

    /**
     The `String` representation of the `Memo`, either text when the `Memo` is of type text, or the hash value for other data types.
     */
    public var text: String? {
        if case let .MEMO_TEXT(text) = self {
            return text
        }

        if case let .MEMO_HASH(data) = self, let s = String(data: data, encoding: .utf8) {
            return s
        }

        return nil
    }

    /**
     The `Data` representation of the `Memo`.
     */
    public var data: Data? {
        if case let .MEMO_HASH(data) = self {
            return data
        }

        return nil
    }

    /**
     Initializer to instantiate a `Memo` of the text type with a `String`

     - Parameter string: the text string.

     - Throws: `StellarError.memoTooLong` if the `String` provided is longer than 28 characters.
     */
    public init(_ string: String) throws {
        guard string.utf8.count <= 28 else {
            throw StellarError.memoTooLong(string)
        }

        self = .MEMO_TEXT(string)
    }

    /**
     Initializer to instantiate a `Memo` of the data type with a `Data`.

     - Parameter data: the `Data` object.

     - Throws: `StellarError.memoTooLong` if the `Data` provided is longer than 32.
     */
    public init(_ data: Data) throws {
        guard data.count <= 32 else {
            throw StellarError.memoTooLong(data)
        }

        self = .MEMO_HASH(data)
    }

    /**
     Maximum length of a `Memo` object.
     */
    public static let maxMemoLength = 28
}

/**
 A `Transaction` represents a transaction that modifies the ledger in the blockchain network.
 A Kin `Transaction` is used to send payments.

 Deprecated. All functionalities moved to `BaseTransaction`. This struct is only kept to ensure backward-compatible API.
 */
public struct TransactionEnvelope {
    public let envelopeXdrBytes: [Byte]
    public let transaction: KinTransaction

    public init(envelopeXdrBytes: [Byte], transaction: KinTransaction) {
        self.envelopeXdrBytes = envelopeXdrBytes
        self.transaction = transaction
    }
}
