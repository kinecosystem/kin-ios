//
//  Network.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `Network` represents the block chain network to which `KinClient` will connect.
 */
public enum Network {
    /**
     Kik's private production network.
     */
    case mainNet

    /**
     Kik's private test network.
     */
    case testNet

    /**
     Kik's private playground network.
     */
    case playground

    /**
     A network with a custom identifier.
     */
    case custom(String)
}

extension Network {
    public typealias Id = String

    fileprivate enum CodingKeys: String, CodingKey {
        case mainNet
        case testNet
        case playground
        case custom
    }

    /**
     Id of this network
     */
    public var id: Id {
        switch self {
        case .mainNet:
            return "Kin Mainnet ; December 2018"
        case .testNet:
            return "Kin Testnet ; December 2018"
        case .playground:
            return ""
        case .custom(let id):
            return id
        }
    }
}

extension Network: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? container.decode(String.self, forKey: .mainNet) {
            self = .mainNet
        }
        else if let _ = try? container.decode(String.self, forKey: .testNet) {
            self = .testNet
        }
        else if let _ = try? container.decode(String.self, forKey: .playground) {
            self = .playground
        }
        else if let id = try? container.decode(String.self, forKey: .custom) {
            self = .custom(id)
        }
        else {
            throw StellarError.dataDencodingFailed
        }
    }

    internal init(from id: String) throws {
        switch id {
        case Network.mainNet.id:
            self = .mainNet
        case Network.testNet.id:
            self = .testNet
        case Network.playground.id:
            self = .playground
        default:
            throw StellarError.dataDencodingFailed
        }
    }
}

extension Network: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .mainNet:
            try container.encode(self.description, forKey: .mainNet)
        case .testNet:
            try container.encode(self.description, forKey: .testNet)
        case .playground:
            try container.encode(self.description, forKey: .playground)
        case .custom(let id):
            try container.encode(id, forKey: .custom)
        }
    }
}

extension Network: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .mainNet:
            return "main"
        case .testNet:
            return "test"
        case .playground:
            return "playground"
        case .custom(_):
            return "custom"
        }
    }
}

extension Network: Equatable {
    public static func ==(lhs: Network, rhs: Network) -> Bool {
        switch lhs {
        case .mainNet:
            switch rhs {
            case .mainNet:
                return true
            default:
                return false
            }
        case .testNet:
            switch rhs {
            case .testNet:
                return true
            default:
                return false
            }
        case .playground:
            switch rhs {
            case .playground:
                return true
            default:
                return false
            }
        case .custom(_):
            return false
        }
    }
}
