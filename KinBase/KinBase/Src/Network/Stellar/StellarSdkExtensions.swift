//
//  StellarSdkExtensions.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-03-30.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

// MARK: StellarSdk Extentions

extension stellarsdk.KeyPair: Equatable {
    public static func == (lhs: KeyPair, rhs: KeyPair) -> Bool {
        return lhs.secretSeed == rhs.secretSeed
    }
}

extension stellarsdk.Seed {
    public var data: Data {
        return Data(bytes: self.bytes, count: self.bytes.count)
    }
}

extension stellarsdk.Transaction {
    static let defaultOperationFee: UInt32 = 100
}

extension stellarsdk.AccountResponse {
    var kinAccount: KinAccount {
        get {
            var kinBalance = KinBalance.zero

            let nativeBalances = balances.filter { (response) -> Bool in
                return response.assetType == "native"
            }

            if let nativeBalance = nativeBalances.first,
                let kin = Kin(string: nativeBalance.balance) {
                kinBalance = KinBalance(kin)
            }

            return KinAccount(key: keyPair,
                              balance: kinBalance,
                              status: .registered,
                              sequence: sequenceNumber)
        }
    }
}

extension stellarsdk.TransactionResponse {
    func toHistoricalKinTransaction(network: KinNetwork) throws -> KinTransaction {
        do {
            let transactionEnvelopeData = try XDREncoder.encode(transactionEnvelope)
            let transactionResultData = [Byte](transactionResultRawData)
            let timestamp = createdAt.timeIntervalSince1970

            return try KinTransaction(envelopeXdrBytes: transactionEnvelopeData,
                                      record: .historical(ts: timestamp,
                                                          resultXdrBytes: transactionResultData,
                                                          pagingToken: pagingToken),
                                      network: network)
        } catch let error {
            throw error
        }

    }
}

extension stellarsdk.SubmitTransactionResponse {
    func toAcknowledgedKinTransaction(network: KinNetwork) throws -> KinTransaction {
        let transactionEnvelopeData = try XDREncoder.encode(transactionEnvelope)
        let transactionResultData = [Byte](transactionResultRawData)
        let timestamp = Date().timeIntervalSince1970

        return try KinTransaction(envelopeXdrBytes: transactionEnvelopeData,
                                  record: .acknowledged(ts: timestamp,
                                                        resultXdrBytes: transactionResultData),
                                  network: network)
    }
}

extension stellarsdk.Transaction {
    func toInFlightKinTransaction(network: KinNetwork) throws -> KinTransaction {
        let transactionEnvelopeData = try XDREncoder.encode(transactionXDR.toEnvelopeXDR())
        return try KinTransaction(envelopeXdrBytes: transactionEnvelopeData,
                                  record: .inFlight(ts: Date().timeIntervalSince1970),
                                  network: network)
    }
}

// MARK: Kin Extensions

extension KinNetwork {
    var stellarNetwork: Network {
        return Network.custom(networkId: id)
    }
}

extension TransactionOrder {
    var stellarOrder: stellarsdk.Order {
        switch self {
        case .ascending:
            return Order.ascending
        case .descending:
            return Order.descending
        }
    }
}
