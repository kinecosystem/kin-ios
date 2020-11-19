//
//  WhitelistPayload.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

/**
 `WhitelistEnvelope` wraps a `TransactionEnvelope` and the `Network.Id`.
 */
public struct WhitelistEnvelope {

    /**
     The `Transaction.Envelope`.
     */
    public let transactionEnvelope: TransactionEnvelope

    /**
     The `Network.Id`.
     */
    public let networkId: Network.Id

    /**
     Initializes the `WhitelistEnvelope`.

     - Parameter transactionEnvelope:
     - Parameter networkId:
     */
    public init(transactionEnvelope: TransactionEnvelope, networkId: Network.Id) {
        self.transactionEnvelope = transactionEnvelope
        self.networkId = networkId
    }
}

extension WhitelistEnvelope {
    enum CodingKeys: String, CodingKey {
        case transactionEnvelope = "tx_envelope"
        case networkId = "network_id"
    }
}

extension WhitelistEnvelope: Decodable {
    /**
     Initializes the `WhitelistEnvelope` with a Decoder.

     - Parameter from: The `Decoder` object to decode from.
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let transactionEnvelopeData = try values.decode(Data.self, forKey: .transactionEnvelope)
        networkId = try values.decode(Network.Id.self, forKey: .networkId)
        var kinNetwork: KinNetwork
        if (networkId == KinNetwork.mainNet.id) {
            kinNetwork = KinNetwork.mainNet
        } else {
            kinNetwork = KinNetwork.testNet
        }
        let transaction = try! KinTransaction(envelopeXdrBytes: [Byte](transactionEnvelopeData),
                                              record: Record.inFlight(ts: Date().timeIntervalSince1970),
                                              network: kinNetwork)
        transactionEnvelope = TransactionEnvelope(envelopeXdrBytes: [Byte](transactionEnvelopeData), transaction: transaction)
        
    }
}

extension WhitelistEnvelope: Encodable {
    /**
     Encode the `WhitelistEnvelope` into the given Encoder.

     - Parameter to: The `Encoder`.

     - Throws:
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let transactionEnvelopeData = Data(transactionEnvelope.envelopeXdrBytes)
        try container.encode(transactionEnvelopeData, forKey: .transactionEnvelope)
        try container.encode(networkId, forKey: .networkId)
    }
}
