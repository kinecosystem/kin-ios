//
//  Constants.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 13/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinSDK

extension AppId {
    init(network: Network) throws {
        switch network {
        case .testNet: try self.init("test")
        case .mainNet: try self.init("test")
        default:       fatalError()
        }
    }
}

extension URL {
    static func blockchain(_ network: Network) -> URL {
        switch network {
        case .testNet: return URL(string: "https://horizon-testnet.kininfrastructure.com")!
        case .mainNet: return URL(string: "https://horizon-ecosystem.kininfrastructure.com")!
        default:       fatalError()
        }
    }

    static func friendBot(_ network: Network, publicAddress: String) -> URL {
        switch network {
        case .testNet: return URL(string: "http://friendbot-testnet.kininfrastructure.com?addr=\(publicAddress)")!
        default:       fatalError("Friend bot is only supported on test net.")
        }
    }

    static func fund(_ network: Network, publicAddress: String, amount: Kin) -> URL {
        switch network {
        case .testNet: return URL(string: "http://friendbot-testnet.kininfrastructure.com/fund?addr=\(publicAddress)&amount=\(amount)")!
        default:       fatalError("Funding is only supported on test net.")
        }
    }
}
