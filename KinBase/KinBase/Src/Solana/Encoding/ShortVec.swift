//
//  ShortVec.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

enum ShortVecError: Error {
    case invalidLength
}

struct ShortVec {
    static func encodeLength(_ length: Int) throws -> Data {
        guard length <= UInt16.max else {
            throw ShortVecError.invalidLength
        }

        var rem_len = length
        var encoded = [UInt8]()

        while true {
            var elem = rem_len & Int(0x7f)
            rem_len >>= 7

            if rem_len == 0 {
                encoded.append(UInt8(elem))
                return Data(bytes: encoded, count: encoded.count)
            }

            elem |= 0x80
            encoded.append(UInt8(elem))
        }
    }

    static func decodeLength(_ data: Data) throws -> (length: Int, remainingData: Data) {
        var encoded = [UInt8](data)

        guard encoded.count > 0 else {
            throw ShortVecError.invalidLength
        }

        var length: Int = 0
        var size: Int = 0

        while true {
            guard let elem = encoded.shift() else {
                break
            }

            length |= (Int(elem) & 0x7f) << (size * 7)
            size += 1

            if ((elem & 0x80) == 0) {
              break;
            }
        }

        return (length, Data(encoded))
    }
}

extension Array {
    mutating func shift() -> Element? {
        guard let offsetIndex = index(startIndex, offsetBy: 1, limitedBy: endIndex) else {
            return nil
        }

        let firstElement = self[startIndex]

        self = Array(self[offsetIndex ..< endIndex] + self[startIndex ..< offsetIndex])

        return firstElement
    }
}
