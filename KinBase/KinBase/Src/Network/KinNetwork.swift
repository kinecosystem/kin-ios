//
//  KinNetwork.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public enum KinNetwork: Int {
    case mainNet
    case testNet
}

public extension KinNetwork {
    var id: String {
        switch self {
        case .mainNet:
            return "Kin Mainnet ; December 2018"
        case .testNet:
            return "Kin Testnet ; December 2018"
        }
    }

    var horizonUrl: String {
        switch self {
        case .mainNet:
            return "https://horizon.kinfederation.com"
        case .testNet:
            return "https://horizon-testnet.kininfrastructure.com"
        }
    }

    var agoraUrl: String {
        switch self {
        case .mainNet:
            return "api.agorainfra.net:" + tlsPort
        case .testNet:
            return "api.agorainfra.dev:" + tlsPort
        }
    }

    private var tlsPort: String {
        return "443"
    }
}
