//
//  UpgradeApiV4Interceptor.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

public class UpgradeApiV4Context: NSObject, GRPCInterceptorFactory {
    public func createInterceptor(with interceptorManager: GRPCInterceptorManager) -> GRPCInterceptor {
        return UpgradeApiV4Interceptor(interceptorManager: interceptorManager)
    }
}

public class UpgradeApiV4Interceptor: GRPCInterceptor {

    private let manager: GRPCInterceptorManager

    init(interceptorManager: GRPCInterceptorManager) {
        self.manager = interceptorManager
        super.init(interceptorManager: interceptorManager,
                   dispatchQueue: .promises)!
    }

    public override func start(with requestOptions: GRPCRequestOptions, callOptions: GRPCCallOptions) {
        let callOptionsWithCreds = callOptions.mutableCopy() as! GRPCMutableCallOptions

        callOptionsWithCreds.initialMetadata = ["desired-kin-version" : "4" ]

        manager.startNextInterceptor(withRequest: requestOptions,
                                     callOptions: callOptionsWithCreds)
    }
}
