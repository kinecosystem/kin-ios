//
//  KinStreamingApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol KinStreamingApi {
    func streamAccount(_ account: PublicKey) -> Observable<KinAccount>
    func streamNewTransactions(account: PublicKey) -> Observable<KinTransaction>
}

public protocol KinStreamingApiV4 {
    func streamAccountV4(_ account: PublicKey) -> Observable<KinAccount>
    func streamNewTransactionsV4(account: PublicKey) -> Observable<KinTransaction>
}
