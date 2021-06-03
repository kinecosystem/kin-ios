//
//  MockGRPCInterceptorManager.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import KinBase

class MockGRPCInterceptorManager: GRPCInterceptorManager {
    var calledRequestOptions: GRPCRequestOptions?
    var calledCallOptions: GRPCCallOptions?

    override func startNextInterceptor(withRequest requestOptions: GRPCRequestOptions,
                                       callOptions: GRPCCallOptions) {
        calledRequestOptions = requestOptions
        calledCallOptions = callOptions
    }
}
