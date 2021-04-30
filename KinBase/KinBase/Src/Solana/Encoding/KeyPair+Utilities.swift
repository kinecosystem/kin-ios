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

public extension PublicKey {
//    var accountId: String {
//        base58
//    }
//    var keypair: KeyPair {
//        KeyPair.init(accountId: accountId)
//    }
}

//public extension KinAccount.Id {
//    func asPublicKey() -> PublicKey {
//        return try! KeyPair.init(accountId: self).asPublicKey()
//    }
//}
