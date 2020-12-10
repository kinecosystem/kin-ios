//
//  KinTransaction.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

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

    private init(recordType: RecordType,
                 timestamp: TimeInterval,
                 resultXdrBytes: [Byte]?,
                 pagingToken: PagingToken?) {
        self.recordType = recordType
        self.timestamp = timestamp
        self.resultXdrBytes = resultXdrBytes
        self.pagingToken = pagingToken
    }

    public static func inFlight(ts: TimeInterval) -> Record {
        return Record(recordType: .inFlight,
                      timestamp: ts,
                      resultXdrBytes: nil,
                      pagingToken: nil)
    }

    public static func acknowledged(ts: TimeInterval,
                             resultXdrBytes: [Byte]) -> Record {
        return Record(recordType: .acknowledged,
                      timestamp: ts,
                      resultXdrBytes: resultXdrBytes,
                      pagingToken: nil)
    }

    public static func historical(ts: TimeInterval,
                           resultXdrBytes: [Byte],
                           pagingToken: PagingToken) -> Record {
        return Record(recordType: .historical,
                      timestamp: ts,
                      resultXdrBytes: resultXdrBytes,
                      pagingToken: pagingToken)
    }
}

public protocol KinTransactionType {
    var record: Record { get }
    var network: KinNetwork { get }
    var envelopeXdrBytes: [Byte] { get }
    var invoiceList: InvoiceList? { get }
    var transactionHash: KinTransactionHash? { get }
    var sourceAccount: KinAccount.Id { get }
    var sequenceNumber: Int64 { get }
    var fee: Quark { get }
    var memo: KinMemo { get }
    var paymentOperations: [KinPaymentOperation] { get }
    var resultCode: ResultCode? { get }
}

public class KinTransaction: Equatable, CustomStringConvertible, KinTransactionType {
    
    public static func == (lhs: KinTransaction, rhs: KinTransaction) -> Bool {
        guard lhs.stellar != nil && rhs.stellar != nil else {
            return lhs.solana == rhs.solana
        }
        
        return lhs.stellar == rhs.stellar
    }

    public var record: Record {
        return innerTxn().record
    }
    
    public var network: KinNetwork{
        return innerTxn().network
    }
    
    public var envelopeXdrBytes: [Byte] {
        return innerTxn().envelopeXdrBytes
    }
    public var invoiceList: InvoiceList? {
        return innerTxn().invoiceList
    }

    public var envelopeXdrString: String {
        return Data(envelopeXdrBytes).base64EncodedString()
    }

    public var transactionHash: KinTransactionHash? {
        return innerTxn().transactionHash
    }

    public var sourceAccount: KinAccount.Id {
        return innerTxn().sourceAccount
    }

    public var sequenceNumber: Int64 {
        return innerTxn().sequenceNumber
    }

    public var fee: Quark {
        return innerTxn().fee
    }

    public var memo: KinMemo {
        return innerTxn().memo
    }

    public var paymentOperations: [KinPaymentOperation] {
        return innerTxn().paymentOperations
    }

    public var resultCode: ResultCode? {
        return innerTxn().resultCode
    }
    
    private let stellar: StellarKinTransaction?
    private let solana: SolanaKinTransaction?
    
    private func innerTxn() -> KinTransactionType {
        if (solana != nil) {
            return solana!
        } else {
            return stellar!
        }
    }
    
    public init(envelopeXdrBytes: [Byte],
         record: Record,
         network: KinNetwork,
         invoiceList: InvoiceList? = nil) throws {
        
        do {
            self.stellar = try StellarKinTransaction(envelopeXdrBytes: envelopeXdrBytes, record: record, network: network, invoiceList: invoiceList)
            self.solana = nil
        } catch _ {
            self.stellar = nil
            self.solana = try SolanaKinTransaction(envelopeXdrBytes: envelopeXdrBytes, record: record, network: network, invoiceList: invoiceList)
        }
    }
    
    public var description: String {
        get {
            return "KinTransaction(record=\(record)), network=\(network), envelopeXdrBytes=(...), invoiceList=\(describe(invoiceList)), transactionHash=\(describe(transactionHash)), sourceAccount=\(sourceAccount), sequenceNumber=\(sequenceNumber), fee=\(fee), memo=\(memo), paymentOperations=\(paymentOperations), resultCode=\(describe(resultCode))"
        }
    }
    
    private func describe<T>(_ element: T?) -> String {
        if let element = element {
            return String(describing: element)
        } else {
            return "<null>"
        }
    }
}

public extension SolanaTransaction {
    var transactionHash: KinTransactionHash? {
        return KinTransactionHash(signatures.first!.encode())
    }
    
    var sourceAccount: KinAccount.Id {
        return message.accounts[1].accountId
    }
    
    var memo: KinMemo {
        guard let memoInstruction = message.instructions.filter({ (it) -> Bool in
            return message.accounts[Int(it.programIndex)] == MemoProgram.PROGRAM_KEY
        }).first else {
            return KinMemo.none
        }
        
        let base64Decoded = Data(base64Encoded: Data(memoInstruction.data.value))
        if (base64Decoded != nil) {
            let memo = KinMemo(bytes: [Byte](base64Decoded!))
            if (memo.agoraMemo != nil) {
                return memo
            } else {
                return KinMemo(text: String(bytes: memoInstruction.data.value, encoding: .utf8) ?? "memo_parsing_failed")
            }
        } else {
            return KinMemo(text: String(bytes: memoInstruction.data.value, encoding: .utf8) ?? "memo_parsing_failed")
        }
    }
    
    var paymentOperations: [KinPaymentOperation] {
        
        let instructions: [CompiledInstruction] = message.instructions.filter({ (it) -> Bool in
            return message.accounts[Int(it.programIndex)] != MemoProgram.PROGRAM_KEY
                && message.accounts[Int(it.programIndex)] != SystemProgram.PROGRAM_KEY
                && it.data.value.first == UInt8(TokenProgram.Command.Transfer.rawValue)
        })
    
        return instructions.map { it in
            let amount = Quark(Data(it.data.value[1..<it.data.value.count]).withUnsafeBytes {$0.load(as: UInt64.self)}).kin
            let source = message.accounts[Int(it.accounts.value[0])].accountId
            let destination = message.accounts[Int(it.accounts.value[1])].accountId
            return KinPaymentOperation(amount: amount, source: source, destination: destination, isNonNativeAsset: false)
        }
    }
}

public struct SolanaKinTransaction: Equatable, KinTransactionType {
    
    public let solanaTransaction: SolanaTransaction
    
    public var record: Record
    public var network: KinNetwork
    public var envelopeXdrBytes: [Byte]
    public var invoiceList: InvoiceList?
    
    public var transactionHash: KinTransactionHash? {
        return solanaTransaction.transactionHash
    }
    
    public var sourceAccount: KinAccount.Id {
        return solanaTransaction.sourceAccount
    }
    
    public var sequenceNumber: Int64 = 0
    
    public var fee: Quark = 0
    
    public var memo: KinMemo {
        return solanaTransaction.memo
    }
    
    public var paymentOperations: [KinPaymentOperation] {
       return solanaTransaction.paymentOperations
    }
    
    public var resultCode: ResultCode? {
         guard record.recordType == .historical || record.recordType == .acknowledged,
           let resultData = record.resultXdrBytes,
           let result = try? XDRDecoder.decode(TransactionResultXDR.self, data: resultData) else {
               return nil
        }

        return result.code
    }
    
    init(envelopeXdrBytes: [Byte],
         record: Record,
         network: KinNetwork,
         invoiceList: InvoiceList? = nil) throws {
        self.envelopeXdrBytes = envelopeXdrBytes
        self.solanaTransaction = SolanaTransaction(data: Data(envelopeXdrBytes))!
        self.record = record
        self.network = network
        self.invoiceList = invoiceList
    }
    
    public static func == (lhs: SolanaKinTransaction, rhs: SolanaKinTransaction) -> Bool {
           return lhs.envelopeXdrBytes == rhs.envelopeXdrBytes &&
               lhs.record == rhs.record &&
               lhs.invoiceList == rhs.invoiceList
    }
}

public struct StellarKinTransaction: Equatable, KinTransactionType {

    public typealias PagingToken = String
    public typealias ResultCode = TransactionResultCode

    public let stellarTransaction: Transaction

    public var record: Record
    public let network: KinNetwork
    public let envelopeXdrBytes: [Byte]
    public let invoiceList: InvoiceList?

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
        switch stellarTransaction.memo {
        case .text(let text):
            return .init(text: text)
        case .hash(let data):
            return .init(bytes: [Byte](data))
        default:
            return .none
        }
    }

    public var paymentOperations: [KinPaymentOperation] {
        return stellarTransaction.operations.compactMap { operation -> KinPaymentOperation? in
            guard let operationXdr = try? operation.toXDR(),
                case let .payment(paymentOperation) = operationXdr.body else {
                return nil
            }

            return KinPaymentOperation(amount: Quark(paymentOperation.amount).kin,
                                       source: operation.sourceAccount?.accountId ?? "",
                                       destination: paymentOperation.destination.accountId,
                                       isNonNativeAsset: paymentOperation.asset.assetCode == "KIN")
        }
    }

    public var resultCode: ResultCode? {
        guard record.recordType == .historical || record.recordType == .acknowledged,
            let resultData = record.resultXdrBytes,
            let result = try? XDRDecoder.decode(TransactionResultXDR.self, data: resultData) else {
                return nil
        }

        return result.code
    }

    init(envelopeXdrBytes: [Byte],
         record: Record,
         network: KinNetwork,
         invoiceList: InvoiceList? = nil) throws {
        self.envelopeXdrBytes = envelopeXdrBytes
        self.stellarTransaction = try Transaction(envelopeXdr: Data(envelopeXdrBytes).base64EncodedString())
        self.record = record
        self.network = network
        self.invoiceList = invoiceList
    }

    public static func inFlightTransaction(envelope: [Byte], network: KinNetwork) throws -> KinTransaction {
        return try KinTransaction(envelopeXdrBytes: envelope,
                                  record: .inFlight(ts: Date().timeIntervalSince1970),
                                  network: network)
    }

    public static func == (lhs: StellarKinTransaction, rhs: StellarKinTransaction) -> Bool {
        return lhs.envelopeXdrBytes == rhs.envelopeXdrBytes &&
            lhs.record == rhs.record &&
            lhs.invoiceList == rhs.invoiceList
    }
}

extension KinTransaction {
    var kinPayments: [KinPayment] {
        guard let transactionHash = transactionHash else {
            return []
        }

        var offset: UInt8 = 0

        return paymentOperations.enumerated().map { (index, operation) -> KinPayment in
            let id = KinPayment.Id(transactionHash: transactionHash, offset: offset)
            let invoice: Invoice? = {
                guard let invoices = invoiceList?.invoices, invoices.count > index else {
                    return nil
                }

                return invoices[index]
            }()

            let amount = (network.isKin2 && operation.isNonNativeAsset) ? operation.amount / 100 : operation.amount
            let payment = KinPayment(id: id,
                                     status: .success,
                                     sourceAccountId: operation.source,
                                     destAccountId: operation.destination,
                                     amount: amount,
                                     fee: fee,
                                     memo: memo,
                                     timestamp: record.timestamp,
                                     invoice: invoice)
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
    public let headPagingToken: PagingToken?
    public let tailPagingToken: PagingToken?
}

