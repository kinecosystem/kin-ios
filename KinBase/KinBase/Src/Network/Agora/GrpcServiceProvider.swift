//
//  GrpcServiceProvider.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

public class GrpcServiceProvider {
    public let accountService: APBAccountV3Account2
    public let transactionService: APBTransactionV3Transaction2
    
    public let accountServiceV4: APBAccountV4Account2
    public let transactionServiceV4: APBTransactionV4Transaction2
    public let airdropServiceV4: APBAirdropV4Airdrop2

    private let host: String
    private let interceptorFactories: [GRPCInterceptorFactory]

    public init(host: String, interceptorFactories: [GRPCInterceptorFactory]) {
        self.host = host
        self.interceptorFactories = interceptorFactories

        let options = GRPCMutableCallOptions()
        options.interceptorFactories = interceptorFactories
        
        // V3 Services
        self.accountService = APBAccountV3Account(host: host, callOptions: options)
        self.transactionService = APBTransactionV3Transaction(host: host, callOptions: options)
        
        // V4 Services
        self.accountServiceV4 = APBAccountV4Account(host: host, callOptions: options)
        self.transactionServiceV4 = APBTransactionV4Transaction(host: host, callOptions: options)
        self.airdropServiceV4 = APBAirdropV4Airdrop(host: host, callOptions: options)
    }
}
