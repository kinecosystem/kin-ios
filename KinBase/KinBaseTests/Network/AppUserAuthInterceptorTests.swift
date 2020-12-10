//
//  AppUserAuthInterceptorTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import KinGrpcApi
@testable import KinBase

class AppUserAuthInterceptorTests: XCTestCase {

    var appInfoProvider = DummyAppInfoProvider()
    var mockManager: MockGRPCInterceptorManager!
    var sut: AppUserAuthInterceptor!

    override func setUpWithError() throws {
        let context = AppUserAuthContext(appInfoProvider: appInfoProvider)
        mockManager = MockGRPCInterceptorManager(factories: [context],
                                                 previousInterceptor: nil,
                                                 transportID: GRPCDefaultTransportImplList.core_secure)

        sut = AppUserAuthInterceptor(interceptorManager: mockManager,
                                     appInfoProvider: appInfoProvider)
    }

    func testDontInjectAppCredentials() {
        let requestOptions: GRPCRequestOptions = .init(host: "host",
                                                       path: "/kin.agora.transaction.v3.Transaction/GetHistory",
                                                       safety: .default)
        sut.start(with: requestOptions,
                  callOptions: .init())

        XCTAssertEqual(mockManager.calledRequestOptions, requestOptions)
        XCTAssertTrue(mockManager.calledCallOptions!.initialMetadata!.isEmpty)
    }

    func testInjectAppCredentials() {
        let requestOptions: GRPCRequestOptions = .init(host: "host",
                                                       path: "/kin.agora.transaction.v3.Transaction/SubmitTransaction",
                                                       safety: .default)
        sut.start(with: requestOptions,
                  callOptions: .init())
        let creds = appInfoProvider.getPassthroughAppUserCredentials()
        XCTAssertEqual(mockManager.calledRequestOptions, requestOptions)
        XCTAssertEqual(mockManager.calledCallOptions!.initialMetadata!["app-user-id"] as! String, creds.appUserId)
        XCTAssertEqual(mockManager.calledCallOptions!.initialMetadata!["app-user-passkey"] as! String, creds.appUserPasskey)
    }
}
