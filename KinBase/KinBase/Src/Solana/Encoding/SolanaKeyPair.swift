//
//  SolanaKeyPair.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Sodium
import stellarsdk

struct SolanaKeyPair {
    let publicKey: SolanaPublicKey
    let privateKey: SolanaPrivateKey
}

extension SolanaKeyPair: SolanaCodable {
    init(_ keyPair: KeyPair) {
        self.publicKey = SolanaPublicKey(keyPair.publicKey.bytes)!
        self.privateKey = SolanaPrivateKey(keyPair.privateKey!.bytes)!
    }
    
    init(_ keyPair: Sign.KeyPair) {
        self.publicKey = SolanaPublicKey(keyPair.publicKey)!
        self.privateKey = SolanaPrivateKey(keyPair.secretKey)!
    }

    init?(data: Data) {
        var index = 0
        let publicKeyPart = data.subdata(in: index..<Int(SolanaPublicKey.Length))

        index = Int(SolanaPublicKey.Length)
        let privateKeyPart = data.subdata(in: index..<(index + Int(SolanaPrivateKey.Length)))

        guard let pk = SolanaPublicKey(data: publicKeyPart),
            let sk = SolanaPrivateKey(data: privateKeyPart) else {
                return nil
        }

        self.publicKey = pk
        self.privateKey = sk
    }
    
    func signature(message: [Byte]) -> [Byte]? {
    
               
        var signature = [UInt8](repeating: 0, count: 64)

//        if (privateKey == nil) { return signature}

        signature.withUnsafeMutableBufferPointer { signature in
           privateKey.value.withUnsafeBufferPointer { priv in
               publicKey.value.withUnsafeBufferPointer { pub in
                   message.withUnsafeBufferPointer { msg in
                       ed25519_sign(signature.baseAddress,
                                    msg.baseAddress,
                                    message.count,
                                    pub.baseAddress,
                                    priv.baseAddress)
                   }
               }
           }
        }

        return signature
        
//        return Sodium().sign.signature(message: message, secretKey: privateKey.value)
    }

    func encode() -> Data {
        var data = publicKey.encode()
        data.append(privateKey.encode())
        return data
    }

    static func == (lhs: SolanaKeyPair, rhs: SolanaKeyPair) -> Bool {
        return lhs.publicKey == rhs.publicKey && lhs.privateKey == rhs.privateKey
    }
    
    public var description: String {
        return "SolanaKeyPair(publicKey: \(publicKey), privateKey: \(privateKey)"
    }
}
