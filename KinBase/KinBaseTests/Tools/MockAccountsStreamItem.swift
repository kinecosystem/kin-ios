//
//  MockAccountsStreamItem.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

class MockAccountsStreamItem: AccountsStreamItem {

    var stubResponse: StreamResponseEnum<AccountResponse>?

    override func onReceive(response:@escaping StreamResponseEnum<AccountResponse>.ResponseClosure) {
        response(stubResponse!)
    }
}
