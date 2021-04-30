//
//  AgoraMemo.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/**
 * A memo format understood by the Agora services.
 * @param magicByteIndicator    2 bits   | < 4
 * @param version               3 bits   | < 8
 * @param typeId                5 bits   | < 32
 * @param appIdx                16 bits  | < 65,536
 * @param foreignKey            230 bits | Base64 Encoded String of [230 bits + (2 zeros padding)]
*/
public struct KinBinaryMemo {
    struct Constants {
        static let magicByteIndicatorBitLength: Int = 2
        static let versionBitLength: Int            = 3
        static let typeIdBitLength: Int             = 5
        static let appIdxBitLength: Int             = 16
        static let foreignKeyBitLength: Int         = 230

        static let maxMagicByteIndicatorSize: Int   = 1 << magicByteIndicatorBitLength
        static let maxVersionSize: Int              = 1 << versionBitLength
        static let maxTypeIdSize: Int               = 1 << typeIdBitLength
        static let maxAppIdxSize: Int               = 1 << appIdxBitLength

        static let byteLengthForeignKey: Int        = Int(ceil(Double(foreignKeyBitLength) / 8.0))

        static let magicByteIndicatorMask: Int      = 0x3
        static let versionMask: Int                 = 0x1C
        static let typeIdMask: Int                  = 0x3E0
        static let appIdxMask: Int                  = 0x3FFFC00

        static let magicByteIndicatorBitOffset: Int = 0
        static let versionBitOffset: Int            = magicByteIndicatorBitLength
        static let typeIdBitOffset: Int             = versionBitOffset + versionBitLength
        static let appIdxBitOffset: Int             = typeIdBitOffset + typeIdBitLength
        static let foreignKeyBitOffset: Int         = appIdxBitOffset + appIdxBitLength

        static let totalLowerByteCount: Int         =
            Int(ceil(Double(magicByteIndicatorBitLength + versionBitLength + typeIdBitLength + appIdxBitLength) / 8.0))
        static let totalByteCount: Int =
            Int(ceil(Double(magicByteIndicatorBitLength + versionBitLength + typeIdBitLength + appIdxBitLength + foreignKeyBitLength) / 8.0))
    }

    public enum AgoraMemoFormatError: String, Error {
        case invalidMagicByteIndicator = "Invalid magicByteIndicator. Valid range is [0, 4)."
        case invalidVersion = "Invalid version. Valid range is [0, 8)."
        case invalidTypeId = "Invalid typeId. Valid range is [0, 32)."
        case invalidAppIdx = "Invalid appIdx. Valid range is [0, 65,536)."
    }

    public enum TransferType: Int8 {
        /// An unclassified transfer of Kin.
        case unknown    = -1
        /// When none of the other types are appropriate for the use case.
        case none       = 0
        /// Use when transferring Kin to a user for some performed action.
        case earn       = 1
        /// Use when transferring Kin due to purchasing something.
        case spend      = 2
        /// Use when transferring Kin where it does not constitute an `earn` or `spend`.
        case p2p        = 3

        public init?(rawValue: Int8) {
            switch rawValue {
            case 0:
                self = .none
            case 1:
                self = .earn
            case 2:
                self = .spend
            case 3:
                self = .p2p
            default:
                self = .unknown
            }
        }
    }

    public let magicByteIndicator: UInt8
    public let version: UInt8
    public let typeId: TransferType
    public let appIdx: UInt16
    public let foreignKeyBytes: [Byte]

    public var foreignKeyString: String {
        return Data(foreignKeyBytes).base64EncodedString()
    }

    public var foreignKeySHA224: SHA224Hash {
        var sha224Bytes = [Byte].init(repeating: 0, count: 28)
        _ = sha224Bytes.withUnsafeMutableBytes {
            foreignKeyBytes.copyBytes(to: $0, count: 28)
        }

        return SHA224Hash.just(bytes: sha224Bytes)
    }

    public var kinMemo: KinMemo {
        return KinMemo(bytes: [Byte](encode()))
    }

    public init(magicByteIndicator: UInt8 = 0x1,
                version: UInt8 = 0,
                typeId: Int8,
                appIdx: UInt16,
                foreignKeyBytes: [Byte] = []) throws {
        guard magicByteIndicator >= 0, magicByteIndicator < Constants.maxMagicByteIndicatorSize else {
            throw AgoraMemoFormatError.invalidMagicByteIndicator
        }

        self.magicByteIndicator = magicByteIndicator

        self.version = version

        guard let transferType = TransferType(rawValue: typeId), transferType != TransferType.unknown else {
            throw AgoraMemoFormatError.invalidTypeId
        }

        self.typeId = transferType

        self.appIdx = appIdx

        // Pad with zeros or truncate foreignKeyBytes
        var foreignKeyBytesPadded = [Byte].init(repeating: 0, count: Constants.byteLengthForeignKey)
        _ = foreignKeyBytesPadded.withUnsafeMutableBytes {
            foreignKeyBytes.copyBytes(to: $0,
                                      count: min(foreignKeyBytes.count, $0.count))
        }

        // Trim last two bits, they don't fit
        foreignKeyBytesPadded[28] = foreignKeyBytesPadded[28] & 0x3F

        self.foreignKeyBytes = foreignKeyBytesPadded
    }

    public init?(data: Data) throws {
        let bytes = [Byte](data)
        var firstFourBytes: Int = 0
        _ = withUnsafeMutableBytes(of: &firstFourBytes) {
            data.copyBytes(to: $0, count: 4)
        }

        let magicByteIndicator = (firstFourBytes & Constants.magicByteIndicatorMask) >> 0
        let version = (firstFourBytes & Constants.versionMask) >> 2
        let typeId = (firstFourBytes & Constants.typeIdMask) >> 5
        let appIdx = (firstFourBytes & Constants.appIdxMask) >> 10

        var foreignKey = [Byte](repeating: 0, count: 29)
        for i in 0...27 {
            foreignKey[i] = foreignKey[i] | (bytes[i + 3] >> 2) & 0x3F
            foreignKey[i] = foreignKey[i] | ((bytes[i + 4] & 0x3) << 6)
        }
        foreignKey[28] = foreignKey[28] | ((bytes[31] >> 2) & 0x3F)

        try self.init(magicByteIndicator: UInt8(magicByteIndicator),
                      version: UInt8(version),
                      typeId: Int8(typeId),
                      appIdx: UInt16(appIdx),
                      foreignKeyBytes: foreignKey)
    }

    /**
     * Fields below are packed from LSB to MSB order:
     * magicByteIndicator             2 bits | less than 4
     * version                        3 bits | less than 8
     * typeId                         5 bits | less than 32
     * appIdx                        16 bits | less than 65,536
     * foreignKey                   230 bits | Often a SHA-224 of an [InvoiceList] but could be anything
     */
    public func encode() -> Data {

        var result = [Byte](repeating: 0, count: Constants.totalByteCount)

        result[0] = Byte(magicByteIndicator)
        result[0] |= Byte(version) << 2
        result[0] |= (Byte(typeId.rawValue) & 0x7) << 5

        result[1] = (Byte(typeId.rawValue) & 0x1c) >> 2
        result[1] |= Byte(appIdx & 0x3f) << 2

        result[2] = Byte((appIdx & 0x3fc0) >> 6)

        result[3] = Byte((appIdx & 0xc000) >> 14)

        // Encode foreign key
        let fkBytes = foreignKeyBytes
        result[3] |= (fkBytes[0] & 0x3f) << 2

        // Insert the rest of the fk. since each loop references fk[n] and fk[n+1], the upper bound is offset by 3 instead of 4.
        for i in 4..<3+fkBytes.count {
            // apply last 2-bits of current byte
            // apply first 6-bits of next byte
            result[i] = (fkBytes[i-4] >> 6) & 0x3
            result[i] |= (fkBytes[i-3] & 0x3f) << 2
        }

        // If the foreign key is less than 29 bytes, the last 2 bits of the FK can be included in the memo
        if fkBytes.count < 29 {
            result[fkBytes.count+3] = (fkBytes[fkBytes.count-1] >> 6) & 0x3
        }

        return Data(result)
    }
}
