//
//  AppInfo.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct AppIndex {
    public static let testApp: AppIndex = .init(value: 0)
    public let value: UInt16
    
    public init(value: UInt16) {
        self.value = value
    }
}

public struct AppInfo {
    public let appIdx: AppIndex
    public let kinAccount: PublicKey
    public let name: String
    public let appIconData: Data

    public init(appIdx: AppIndex, kinAccount: PublicKey, name: String, appIconData: Data) {
        self.appIdx = appIdx
        self.kinAccount = kinAccount
        self.name = name
        self.appIconData = appIconData
    }

    public static let testApp: AppInfo = AppInfo(
        appIdx: .testApp,
        kinAccount: .zero,
        name: "Test App",
        appIconData: Data()
    )
}

public struct AppUserCredentials {
    public let appUserId: String
    public let appUserPasskey: String

    public init(appUserId: String, appUserPasskey: String) {
        self.appUserId = appUserId
        self.appUserPasskey = appUserPasskey
    }
}
