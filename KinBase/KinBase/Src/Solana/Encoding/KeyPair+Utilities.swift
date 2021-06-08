//
//  Utils.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public extension KeyPair {
    
    var accountId: String {
        publicKey.base58
    }
    
    func asPublicKey() -> PublicKey {
        publicKey
    }
}
