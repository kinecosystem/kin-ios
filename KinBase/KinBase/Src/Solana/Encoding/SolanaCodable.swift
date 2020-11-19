//
//  SolanaCodable.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

protocol SolanaCodable: Equatable, CustomStringConvertible {
    // TODO: maybe try init?(data: inout Data)  OR   static func decode(_ data: inout Data) -> Self
    init?(data: Data)   // decode
    func encode() -> Data
}

/// Encode and decode using short-vec convention
public class ByteArray: SolanaCodable {
    let value: [Byte]

    init(_ value: [Byte]) {
        self.value = value
    }

    required init?(data: Data) {
        let shortVecDecoded = try! ShortVec.decodeLength(data)
        self.value = [Byte](shortVecDecoded.remainingData.subdata(in: 0..<shortVecDecoded.length))
    }

    func encode() -> Data {
        var data = (try? ShortVec.encodeLength(value.count)) ?? Data()
        data.append(Data(value))

        return data
    }

    public static func == (lhs: ByteArray, rhs: ByteArray) -> Bool {
        return lhs.value.elementsEqual(rhs.value)
    }
    
    public var description: String {
        "\(value)"
    }
}


/// Encodes elements only. Length is not encoded.
public class FixedLengthByteArray: SolanaCodable {
    class var Length: UInt {
        fatalError("must specify length")
    }

    let value: [Byte]

    init() {
        self.value = [Byte](repeating: 0, count: Int(Self.Length))
    }

    init?(_ value: [Byte]) {
        guard value.count == Self.Length else {
            return nil
        }

        self.value = value
    }

    required init?(data: Data) {
        let byteArray = [Byte](data)
        guard byteArray.count == Self.Length else {
            return nil
        }

        self.value = byteArray
    }

    func encode() -> Data {
        return Data(value)
    }

    public static func == (lhs: FixedLengthByteArray, rhs: FixedLengthByteArray) -> Bool {
        return lhs.value.elementsEqual(rhs.value)
    }
    
    public var description: String {
        "\(value)"
    }
}
