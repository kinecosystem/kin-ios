//
//  AppInfoProvider.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol AppInfoProvider {
    var appInfo: AppInfo { get }
    func getPassthroughAppUserCredentials() -> AppUserCredentials
}

public class DummyAppInfoProvider: AppInfoProvider {
    public var appInfo: AppInfo {
        return .testApp
    }

    public init() {}

    public func getPassthroughAppUserCredentials() -> AppUserCredentials {
        return .init(appUserId: "dummyuserid", appUserPasskey: "fakepasskey")
    }
}
