//
//  KinStreamingApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol KinStreamingApi {
    func streamAccount(_ accountId: KinAccount.Id) -> Observable<KinAccount>
    func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction>
}
