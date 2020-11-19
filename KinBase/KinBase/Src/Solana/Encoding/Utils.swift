//
//  Utils.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public extension KeyPair {
    func asPublicKey() -> SolanaPublicKey {
        return SolanaPublicKey(self.publicKey.bytes)!
    }
}

public extension SolanaPublicKey {
    var accountId: String {
        try! PublicKey(value).accountId
    }
    var keypair: KeyPair {
        try! KeyPair.init(accountId: accountId)
    }
}

public extension KinAccount.Id {
    func asPublicKey() -> SolanaPublicKey {
        return try! KeyPair.init(accountId: self).asPublicKey()
    }
}
