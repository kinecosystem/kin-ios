//
//  MockTransactionStreamItem.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

class MockTransactionStreamItem: TransactionsStreamItem {
    var stubResponse: StreamResponseEnum<TransactionResponse>?

    override func onReceive(response: @escaping StreamResponseEnum<TransactionResponse>.ResponseClosure) {
        response(stubResponse!)
    }
}
