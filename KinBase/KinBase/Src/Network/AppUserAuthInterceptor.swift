//
//  AppUserAuthInterceptor.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

public class AppUserAuthContext: NSObject, GRPCInterceptorFactory {
    private let appInfoProvider: AppInfoProvider

    public init(appInfoProvider: AppInfoProvider) {
        self.appInfoProvider = appInfoProvider
        super.init()
    }

    public func createInterceptor(with interceptorManager: GRPCInterceptorManager) -> GRPCInterceptor {
        return AppUserAuthInterceptor(interceptorManager: interceptorManager,
                                      appInfoProvider: appInfoProvider)
    }
}

public class AppUserAuthInterceptor: GRPCInterceptor {

    private let manager: GRPCInterceptorManager
    private let appInfoProvider: AppInfoProvider

    init(interceptorManager: GRPCInterceptorManager,
         appInfoProvider: AppInfoProvider) {
        self.manager = interceptorManager
        self.appInfoProvider = appInfoProvider
        super.init(interceptorManager: interceptorManager,
                   dispatchQueue: .promises)!
    }

    public override func start(with requestOptions: GRPCRequestOptions, callOptions: GRPCCallOptions) {
        let callOptionsWithCreds = callOptions.mutableCopy() as! GRPCMutableCallOptions

        if requestOptions.path == "/kin.agora.transaction.v3.Transaction/SubmitTransaction" {
            let creds = appInfoProvider.getPassthroughAppUserCredentials()
            callOptionsWithCreds.initialMetadata = ["app-user-id": creds.appUserId,
                                                    "app-user-passkey": creds.appUserPasskey]
        }

        manager.startNextInterceptor(withRequest: requestOptions,
                                     callOptions: callOptionsWithCreds)
    }
}
