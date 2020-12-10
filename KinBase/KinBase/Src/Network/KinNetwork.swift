//
//  KinNetwork.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public enum KinNetwork: Int {
    case mainNet
    case testNet
    case mainNetKin2
    case testNetKin2
}

public extension KinNetwork {
    private static let issuerMainKin2 = try! KeyPair(accountId: "GDF42M3IPERQCBLWFEZKQRK77JQ65SCKTU3CW36HZVCX7XX5A5QXZIVK")
    private static let issuerTestKin2 = try! KeyPair(accountId: "GBC3SG6NGTSZ2OMH3FFGB7UVRQWILW367U4GSOOF4TFSZONV42UJXUH7")
    
    var issuer: KeyPair? {
        switch self {
        case .mainNetKin2:
            return KinNetwork.issuerMainKin2
        case .testNetKin2:
            return KinNetwork.issuerTestKin2
        case .testNet, .mainNet:
            return nil
        }
    }
    
    var isKin2: Bool {
        switch self {
        case .testNetKin2, .mainNetKin2:
            return true
        case .testNet, .mainNet:
            return false
        }
    }
    
    var id: String {
        switch self {
        case .mainNet:
            return "Kin Mainnet ; December 2018"
        case .testNet:
            return "Kin Testnet ; December 2018"
        case .mainNetKin2:
            return "Public Global Kin Ecosystem Network ; June 2018"
        case .testNetKin2:
            return "Kin Playground Network ; June 2018"
        }
    }

    var horizonUrl: String {
        switch self {
        case .mainNet:
            return "https://horizon.kinfederation.com"
        case .testNet:
            return "https://horizon-testnet.kininfrastructure.com"
        case .mainNetKin2, .testNetKin2:
            fatalError("Unsupported: horizon is not supported for Kin 2")
        }
    }

    var agoraUrl: String {
        switch self {
        case .mainNet, .mainNetKin2:
            return "api.agorainfra.net:" + tlsPort
        case .testNet, .testNetKin2:
            return "api.agorainfra.dev:" + tlsPort
        }
    }

    private var tlsPort: String {
        return "443"
    }
}
