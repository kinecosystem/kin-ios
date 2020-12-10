//
//  KinVersionInterceptorTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import KinGrpcApi
@testable import KinBase

class KinVersionInterceptorTests: XCTestCase {

    var mockManager: MockGRPCInterceptorManager!
    var interceptor: GRPCInterceptor!
    
    private let blockchainVersion = 32

    override func setUpWithError() throws {
        let context = KinVersionContext(blockchainVersion: blockchainVersion)
        mockManager = MockGRPCInterceptorManager(factories: [context],
                                                 previousInterceptor: nil,
                                                 transportID: GRPCDefaultTransportImplList.core_secure)

        interceptor = context.createInterceptor(with: mockManager)
    }

    func testInjectWithExistingOptions() throws {
        interceptor.start(with: createRequestOptions(), callOptions: createCallOptions())
        
        let metadata = try XCTUnwrap(mockManager.calledCallOptions?.initialMetadata)
        
        XCTAssertEqual(metadata.count, 2)
        XCTAssertEqual(metadata["kin-version"] as! String, "32")
        XCTAssertEqual(metadata["existing-key"] as! Int, 123)
    }
    
    func testInjectWithoutExistingOptions() throws {
        interceptor.start(with: createRequestOptions(), callOptions: .init())
        
        let metadata = try XCTUnwrap(mockManager.calledCallOptions?.initialMetadata)
        
        XCTAssertEqual(metadata.count, 1)
        XCTAssertEqual(metadata["kin-version"] as! String, "32")
    }
    
    private func createRequestOptions() -> GRPCRequestOptions {
        return GRPCRequestOptions(host: "host", path: "/", safety: .default)
    }
    
    private func createCallOptions() -> GRPCCallOptions {
        let options = GRPCMutableCallOptions()
        options.initialMetadata = ["existing-key": 123]
        return options.copy() as! GRPCCallOptions
    }
}
