//
//  KinVersionInterceptor.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinGrpcApi

public class KinVersionContext: NSObject, GRPCInterceptorFactory {
    private let blockchainVersion: Int

    public init(blockchainVersion: Int) {
        self.blockchainVersion = blockchainVersion
        super.init()
    }

    public func createInterceptor(with interceptorManager: GRPCInterceptorManager) -> GRPCInterceptor {
        return KinVersionInterceptor(interceptorManager: interceptorManager, blockchainVersion: blockchainVersion)
    }
}

public class KinVersionInterceptor: GRPCInterceptor {

    private let manager: GRPCInterceptorManager
    private let blockchainVersion: Int

    init(interceptorManager: GRPCInterceptorManager, blockchainVersion: Int) {
        self.manager = interceptorManager
        self.blockchainVersion = blockchainVersion
        super.init(interceptorManager: interceptorManager, dispatchQueue: .promises)!
    }

    public override func start(with requestOptions: GRPCRequestOptions, callOptions: GRPCCallOptions) {
        let newCallOptions = callOptions.mutableCopy() as! GRPCMutableCallOptions
        
        var headers = newCallOptions.initialMetadata ?? [:]
        headers["kin-version"] = "\(blockchainVersion)"
        newCallOptions.initialMetadata = headers
        manager.startNextInterceptor(withRequest: requestOptions, callOptions: newCallOptions)
    }
}

