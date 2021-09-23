//
//  KeyUtils.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinSodium

public enum KeyUtilsError: Error {
    case encodingFailed (String)
    case decodingFailed (String)
    case hashingFailed
    case passphraseIncorrect
    case unknownError
    case signingFailed
}

public struct KeyUtils {
    public struct AccountData: Codable {
        let pkey: String
        let seed: String
        let salt: String
        let extra: Data?
    }

    public static func keyPair(from seed: Bytes) -> Sign.KeyPair? {
        return Sodium().sign.keyPair(seed: seed)
    }

    public static func seed(from passphrase: String,
                            encryptedSeed: String,
                            salt: String) throws -> Bytes {
        guard let encryptedSeedData = Data(fromHexEncodedString: encryptedSeed) else {
            throw KeyUtilsError.decodingFailed(encryptedSeed)
        }

        let sodium = Sodium()

        let skey = try KeyUtils.keyHash(passphrase: passphrase, salt: salt)

        guard let seed = sodium.secretBox.open(nonceAndAuthenticatedCipherText: Array(encryptedSeedData),
                                               secretKey: skey) else {
                                                throw KeyUtilsError.passphraseIncorrect
        }

        return seed
    }

    public static func keyHash(passphrase: String, salt: String) throws -> Bytes {
        guard let passphraseData = passphrase.data(using: .utf8) else {
            throw KeyUtilsError.encodingFailed(passphrase)
        }

        guard let saltData = Data(fromHexEncodedString: salt) else {
            throw KeyUtilsError.decodingFailed(salt)
        }

        let sodium = Sodium()

        guard let hash = sodium.pwHash.hash(outputLength: 32,
                                            passwd: Array(passphraseData),
                                            salt: Array(saltData),
                                            opsLimit: sodium.pwHash.OpsLimitInteractive,
                                            memLimit: sodium.pwHash.MemLimitInteractive) else {
                                                throw KeyUtilsError.hashingFailed
        }

        return hash
    }

    public static func encryptSeed(_ seed: Bytes, secretKey: SecretBox.Key) -> Bytes? {
        return Sodium().secretBox.seal(message: seed, secretKey: secretKey)
    }

    public static func seed() -> Bytes? {
        return Sodium().randomBytes.buf(length: 32)
    }

    public static func salt() -> String? {
        if let bytes = Sodium().randomBytes.buf(length: 16) {
            return Data(bytes).hexEncodedString()
        }

        return nil
    }

    public static func sign(message: Bytes, signingKey: Sign.SecretKey) throws -> Bytes {
        guard let signature = Sodium().sign.signature(message: message, secretKey: signingKey) else {
            throw KeyUtilsError.signingFailed
        }

        return signature
    }
}
