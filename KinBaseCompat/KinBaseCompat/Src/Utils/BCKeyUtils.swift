//
//  KeyUtils.swift
//  StellarKit
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

public struct BCKeyUtils {
    public static func base32(publicKey: [UInt8]) -> String {
        return dataToBase32(publicKey, type: VersionBytes.ed25519PublicKey)
    }

    public static func base32(seed: [UInt8]) -> String {
        return dataToBase32(seed, type: VersionBytes.ed25519SecretSeed)
    }

    public static func key(base32: String) -> [UInt8] {
        // Stellar represents a key in base32 using a leading type identifier and a trailing 2-byte
        // checksum, for a total of 35 bytes.  The actual key is stored in bytes 2-33.

        let binary: String = base32.reduce("") { $0 + fromTable[String($1)]! }

        var a = [UInt8]()

        for i: Int in stride(from: 8, to: 264, by: 8) {
            let s: String = binary[i..<(i + 8)]
            a.append(UInt8(s, radix: 2)!)
        }

        return a
    }
}

private struct VersionBytes {
    static let ed25519PublicKey: UInt8 = 6 << 3         // G
    static let ed25519SecretSeed: UInt8 = 18 << 3       // S
    static let preAuthTx: UInt8 = 19 << 3               // T
    static let sha256Hash: UInt8 =  23 << 3             // X
}

private func dataToBase32(_ data: [UInt8], type: UInt8) -> String {
    var d = Data([type])

    d.append(Data(data))
    d.append(contentsOf: d.crc16)

    return dataToBase32(d)
}

private let fromTable: [String: String] = [
    "A": "00000", "B": "00001", "C": "00010", "D": "00011", "E": "00100", "F": "00101",
    "G": "00110", "H": "00111", "I": "01000", "J": "01001", "K": "01010", "L": "01011",
    "M": "01100", "N": "01101", "O": "01110", "P": "01111", "Q": "10000", "R": "10001",
    "S": "10010", "T": "10011", "U": "10100", "V": "10101", "W": "10110", "X": "10111",
    "Y": "11000", "Z": "11001", "2": "11010", "3": "11011", "4": "11100", "5": "11101",
    "6": "11110", "7": "11111",
]

private let toTable: [String: String] = {
    var t = [String: String]()

    for (k, v) in fromTable { t[v] = k }

    return t
}()

private func dataToBase32(_ data: Data) -> String {
    guard (data.count * UInt8.bitWidth) % 5 == 0 else {
        fatalError("Number of bits not a multiple of 5.  This method intended for encoding Stellar public keys.")
    }

    let binary = data.binaryString
    var s = ""

    for i in stride(from: 0, to: binary.count, by: 5) {
        s += toTable[binary[i..<(i + 5)]]!
    }

    return s
}
