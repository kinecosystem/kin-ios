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

public class BasicAppInfoProvider: AppInfoProvider {
    public var appInfo: AppInfo
    private var appUserCredentials: AppUserCredentials

    public func getPassthroughAppUserCredentials() -> AppUserCredentials {
        return self.appUserCredentials
    }

    public init(appInfo: AppInfo, appUserId: String, appUserPasskey: String) {
        self.appInfo = appInfo
        self.appUserCredentials = AppUserCredentials.init(appUserId: appUserId, appUserPasskey: appUserPasskey)
    }
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
