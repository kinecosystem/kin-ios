//
//  MD5.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import Foundation
import CommonCrypto

public struct MD5: HashType {
    
    private var context = CC_MD5_CTX()
    
    public init() {
        CC_MD5_Init(&context)
    }
    
    public mutating func update(_ data: Data) {
        data.withUnsafeBytes {
            _ = CC_MD5_Update(&context, $0.baseAddress, CC_LONG($0.count))
        }
    }
    
    public func digestBytes() -> [Byte] {
        var mutableContext = context
        var bytes = [Byte](repeating: 0,  count: Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5_Final(&bytes, &mutableContext)
        
        return bytes
    }
}
