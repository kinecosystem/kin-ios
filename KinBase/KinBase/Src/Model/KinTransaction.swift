//
//  KinTransaction.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public struct KinTransaction: Equatable {

    public typealias PagingToken = String
    public typealias ResultCode = TransactionResultCode

    public struct Record: Equatable {
        enum RecordType: Int {
            case inFlight
            case acknowledged
            case historical
        }

        let recordType: RecordType
        let timestamp: TimeInterval
        let resultXdrBytes: [Byte]?
        let pagingToken: PagingToken?

        static func inFlight(ts: TimeInterval) -> Record {
            return Record(recordType: .inFlight,
                          timestamp: ts,
                          resultXdrBytes: nil,
                          pagingToken: nil)
        }

        static func acknowledged(ts: TimeInterval,
                                 resultXdrBytes: [Byte]) -> Record {
            return Record(recordType: .acknowledged,
                          timestamp: ts,
                          resultXdrBytes: resultXdrBytes,
                          pagingToken: nil)
        }

        static func historical(ts: TimeInterval,
                               resultXdrBytes: [Byte],
                               pagingToken: PagingToken) -> Record {
            return Record(recordType: .historical,
                          timestamp: ts,
                          resultXdrBytes: resultXdrBytes,
                          pagingToken: pagingToken)
        }
    }

    let stellarTransaction: Transaction

    public let envelopeXdrBytes: [Byte]
    public let record: Record
    public let network: KinNetwork

    public var transactionHash: KinTransactionHash? {
        guard let data = try? stellarTransaction.getTransactionHashData(network: network.stellarNetwork) else {
            return nil
        }

        return KinTransactionHash(data)
    }

    public var sourceAccount: KinAccount.Id {
        return stellarTransaction.sourceAccount.keyPair.accountId
    }

    public var sequenceNumber: Int64 {
        return stellarTransaction.sourceAccount.sequenceNumber
    }

    public var fee: Quark {
        return Quark(stellarTransaction.fee)
    }

    public var memo: KinMemo {
        guard case let Memo.text(text) = stellarTransaction.memo else {
            return KinMemo.none
        }

        return KinMemo(text: text)
    }

    public var paymentOperations: [KinPaymentOperation] {
        return stellarTransaction.operations.compactMap { operation -> KinPaymentOperation? in
            guard let operationXdr = try? operation.toXDR(),
                let sourceAccountId = operation.sourceAccount?.accountId,
                case let .payment(paymentOperation) = operationXdr.body else {
                return nil
            }

            return KinPaymentOperation(amount: Quark(paymentOperation.amount).kin,
                                       source: sourceAccountId,
                                       destination: paymentOperation.destination.accountId)
        }
    }

    public var resultCode: ResultCode? {
        guard record.recordType == .historical,
            let resultData = record.resultXdrBytes,
            let result = try? XDRDecoder.decode(TransactionResultXDR.self, data: resultData) else {
                return nil
        }

        return result.code
    }

    init(envelopeXdrBytes: [Byte],
         record: Record,
         network: KinNetwork) throws {
        self.envelopeXdrBytes = envelopeXdrBytes
        self.record = record
        self.network = network
        self.stellarTransaction = try Transaction(envelopeXdr: Data(envelopeXdrBytes).base64EncodedString())
    }

    public static func inFlightTransaction(envelope: [Byte], network: KinNetwork) throws -> KinTransaction {
        return try KinTransaction(envelopeXdrBytes: envelope,
                                  record: .inFlight(ts: Date().timeIntervalSince1970),
                                  network: network)
    }

    public static func == (lhs: KinTransaction, rhs: KinTransaction) -> Bool {
        return lhs.envelopeXdrBytes == rhs.envelopeXdrBytes &&
            lhs.record == rhs.record
    }
}

extension KinTransaction {
    var kinPayments: [KinPayment] {
        guard let transactionHash = transactionHash else {
            return []
        }

        var offset: UInt8 = 0

        return paymentOperations.map { operation -> KinPayment in
            let id = KinPayment.Id(transactionHash: transactionHash, offset: offset)
            let payment = KinPayment(id: id,
                                     status: .success,
                                     sourceAccountId: operation.source,
                                     destAccountId: operation.destination,
                                     amount: operation.amount,
                                     fee: fee,
                                     memo: memo,
                                     timestamp: record.timestamp)
            offset += 1
            return payment
        }
    }
}

extension Array where Element == KinTransaction {
    var kinPayments: [KinPayment] {
        return self.flatMap { $0.kinPayments }
    }
}

public struct KinTransactionHash: Equatable {
    public let rawValue: [Byte]

    public var data: Data {
        return Data(rawValue)
    }

    init(_ data: Data) {
        self.rawValue = [Byte](data)
    }
}

extension KinTransactionHash: CustomStringConvertible {
    public var description: String {
        return Data(rawValue).hexEncodedString()
    }
}

public struct KinTransactions {
    public let items: [KinTransaction]
    public let headPagingToken: KinTransaction.PagingToken?
    public let tailPagingToken: KinTransaction.PagingToken?
}

