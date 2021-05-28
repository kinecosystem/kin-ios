//
//  SHA256.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import Foundation
import CommonCrypto

public struct SHA256: HashType {
    
    private var context = CC_SHA256_CTX()
    
    public init() {
        CC_SHA256_Init(&context)
    }
    
    public mutating func update(_ data: Data) {
        data.withUnsafeBytes {
            _ = CC_SHA256_Update(&context, $0.baseAddress, CC_LONG($0.count))
        }
    }
    
    public func digestBytes() -> [Byte] {
        var mutableContext = context
        var bytes = [Byte](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256_Final(&bytes, &mutableContext)
        
        return bytes
    }
}
