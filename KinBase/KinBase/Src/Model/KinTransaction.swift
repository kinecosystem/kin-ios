//
//  KinTransaction.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public typealias PagingToken = String

public struct Record: Equatable {

    let recordType: RecordType
    let timestamp: TimeInterval
    let pagingToken: PagingToken?
    
    private init(recordType: RecordType, timestamp: TimeInterval, pagingToken: PagingToken?) {
        self.recordType = recordType
        self.timestamp = timestamp
        self.pagingToken = pagingToken
    }
    
    public static func inFlight(ts: TimeInterval) -> Record {
        Record(
            recordType: .inFlight,
            timestamp: ts,
            pagingToken: nil
        )
    }
    
    public static func acknowledged(ts: TimeInterval) -> Record {
        Record(
            recordType: .acknowledged,
            timestamp: ts,
            pagingToken: nil
        )
    }
    
    public static func historical(ts: TimeInterval, pagingToken: PagingToken) -> Record {
        Record(
            recordType: .historical,
            timestamp: ts,
            pagingToken: pagingToken
        )
    }
}

extension Record {
    enum RecordType: Int {
        case inFlight
        case acknowledged
        case historical
    }
}

public protocol KinTransactionType {
    var record: Record { get }
    var network: KinNetwork { get }
    var envelopeXdrBytes: [Byte] { get }
    var invoiceList: InvoiceList? { get }
    var transactionHash: KinTransactionHash { get }
    var sourceAccount: PublicKey { get }
    var sequenceNumber: Int64 { get }
    var fee: Quark { get }
    var memo: KinMemo { get }
    var paymentOperations: [KinPaymentOperation] { get }
}

extension KinTransactionType {
    public var envelopeXdrString: String {
        return Data(envelopeXdrBytes).base64EncodedString()
    }
}

public class KinTransaction: Equatable, KinTransactionType {
    
    public let solanaTransaction: Transaction
    
    public var record: Record
    public var network: KinNetwork
    public var envelopeXdrBytes: [Byte]
    public var invoiceList: InvoiceList?
    
    public var transactionHash: KinTransactionHash {
        solanaTransaction.transactionHash
    }
    
    public var sourceAccount: PublicKey {
        solanaTransaction.sourceAccount
    }
    
    public var sequenceNumber: Int64 = 0
    
    public var fee: Quark = 0
    
    public var memo: KinMemo {
        solanaTransaction.memo
    }
    
    public var paymentOperations: [KinPaymentOperation] {
       solanaTransaction.paymentOperations
    }
    
    init(envelopeXdrBytes: [Byte], record: Record, network: KinNetwork, invoiceList: InvoiceList? = nil) throws {
        self.envelopeXdrBytes = envelopeXdrBytes
        self.solanaTransaction = Transaction(data: Data(envelopeXdrBytes))!
        self.record = record
        self.network = network
        self.invoiceList = invoiceList
    }
    
    public static func == (lhs: KinTransaction, rhs: KinTransaction) -> Bool {
           return lhs.envelopeXdrBytes == rhs.envelopeXdrBytes &&
               lhs.record == rhs.record &&
               lhs.invoiceList == rhs.invoiceList
    }
}

extension KinTransaction: CustomStringConvertible {
    public var description: String {
        """
        KinTransaction
         - record: \(record)
         - network: \(network)
         - envelopeXdrBytes: ...
         - invoiceList: \(describe(invoiceList))
         - transactionHash: \(describe(transactionHash))
         - sourceAccount: \(sourceAccount)
         - sequenceNumber: \(sequenceNumber)
         - fee: \(fee)
         - memo: \(memo)
         - paymentOperations: \(paymentOperations)
        """
    }
    
    private func describe<T>(_ element: T?) -> String {
        if let element = element {
            return String(describing: element)
        } else {
            return "<null>"
        }
    }
}

public extension Transaction {
    var transactionHash: KinTransactionHash {
        KinTransactionHash(signatures.first!.data)
    }
    
    var sourceAccount: PublicKey {
        message.accounts[1]
    }
    
    var memo: KinMemo {
        guard
            let memoInstruction = message.instructions.filter({
                message.accounts[Int($0.programIndex)] == .memoProgram
            }).first
        else {
            return KinMemo.none
        }
        
        
        if let base64Decoded = Data(base64Encoded: memoInstruction.data) {
            let memo = KinMemo(bytes: [Byte](base64Decoded))
            if memo.agoraMemo != nil {
                return memo
            } else {
                return KinMemo(text: String(data: memoInstruction.data, encoding: .utf8) ?? "memo_parsing_failed")
            }
        } else {
            return KinMemo(text: String(data: memoInstruction.data, encoding: .utf8) ?? "memo_parsing_failed")
        }
    }
    
    var paymentOperations: [KinPaymentOperation] {
        let instructions: [CompiledInstruction] = message.instructions.filter { instruction in
            return message.accounts[Int(instruction.programIndex)] != .memoProgram
                && message.accounts[Int(instruction.programIndex)] != .systemProgram
                && instruction.data.first == UInt8(TokenProgram.Command.transfer.rawValue)
        }
    
        return instructions.map { instruction in
            let amount = Quark(Data(instruction.data[1..<instruction.data.count]).withUnsafeBytes { $0.load(as: UInt64.self) }).kin
            let source = message.accounts[Int(instruction.accountIndexes[0])]
            let destination = message.accounts[Int(instruction.accountIndexes[1])]
            return KinPaymentOperation(amount: amount, source: source, destination: destination, isNonNativeAsset: false)
        }
    }
}

extension KinTransactionType {
    var kinPayments: [KinPayment] {
        var offset: UInt8 = 0

        return paymentOperations.enumerated().map { (index, operation) -> KinPayment in
            let id = KinPayment.Id(transactionHash: transactionHash, offset: offset)
            let invoice: Invoice? = {
                guard let invoices = invoiceList?.invoices, invoices.count > index else {
                    return nil
                }

                return invoices[index]
            }()

            let payment = KinPayment(
                id: id,
                status: .success,
                sourceAccount: operation.source,
                destAccount: operation.destination,
                amount: operation.amount,
                fee: fee,
                memo: memo,
                timestamp: record.timestamp,
                invoice: invoice
            )
            
            offset += 1
            return payment
        }
    }
}

extension Array where Element: KinTransactionType {
    var kinPayments: [KinPayment] {
        self.flatMap { $0.kinPayments }
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
    public let headPagingToken: PagingToken?
    public let tailPagingToken: PagingToken?
}

