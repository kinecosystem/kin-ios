//
//  SHA512.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import Foundation
import CommonCrypto

public struct SHA512: HashType {
    
    private var context = CC_SHA512_CTX()
    
    public init() {
        CC_SHA512_Init(&context)
    }
    
    public mutating func update(_ data: Data) {
        data.withUnsafeBytes {
            _ = CC_SHA512_Update(&context, $0.baseAddress, CC_LONG($0.count))
        }
    }
    
    public func digestBytes() -> [Byte] {
        var mutableContext = context
        var bytes = [Byte](repeating: 0,  count: Int(CC_SHA512_DIGEST_LENGTH))
        
        CC_SHA512_Final(&bytes, &mutableContext)
        
        return bytes
    }
}
