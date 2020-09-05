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

    private let host: String
    private let authContext: AppUserAuthContext

    public init(host: String, authContext: AppUserAuthContext, userAgentContext: UserAgentContext) {
        self.host = host
        self.authContext = authContext

        self.accountService = APBAccountV3Account(host: host)

        let options = GRPCMutableCallOptions()
        options.interceptorFactories = [authContext, userAgentContext]
        self.transactionService = APBTransactionV3Transaction(host: host,
                                                              callOptions: options)
    }
}
