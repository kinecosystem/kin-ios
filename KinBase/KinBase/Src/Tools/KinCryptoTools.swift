//
//  Utils.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import CommonCrypto

func sha256(data: Data) -> Data {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = data.withUnsafeBytes {
        CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

protocol HashType {
    init()
    mutating func update(_ data: Data)
    func digestBytes() -> [Byte]
}

extension HashType {
    mutating func update(_ UTF8String: String) {
        update(Data(UTF8String.utf8))
    }
    
    func digestData() -> Data {
        Data(digestBytes())
    }
}

struct SHA256: HashType {
    
    private var context = CC_SHA256_CTX()
    
    init() {
        CC_SHA256_Init(&context)
    }
    
    mutating func update(_ data: Data) {
        data.withUnsafeBytes {
            _ = CC_SHA256_Update(&context, $0.baseAddress, CC_LONG($0.count))
        }
    }
    
    func digestBytes() -> [Byte] {
        var mutableContext = context
        var bytes = [Byte](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256_Final(&bytes, &mutableContext)
        
        return bytes
    }
}
