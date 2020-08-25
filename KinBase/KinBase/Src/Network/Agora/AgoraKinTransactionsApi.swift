//
//  AgoraKinTransactionsApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
import KinGrpcApi

public class AgoraKinTransactionsApi {
    public enum Errors: Equatable, Error {
        case unknown
        case invoiceErrors(errors: [InvoiceError])

        public static func == (lhs: AgoraKinTransactionsApi.Errors,
                               rhs: AgoraKinTransactionsApi.Errors) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown):
                return true
            case (.invoiceErrors(let lhs_errors), .invoiceErrors(let rhs_errors)):
                return lhs_errors == rhs_errors
            default:
                return false
            }
        }
    }

    private let agoraGrpc: AgoraTransactionServiceGrpcProxy

    init(agoraGrpc: AgoraTransactionServiceGrpcProxy) {
        self.agoraGrpc = agoraGrpc
    }
}

extension AgoraKinTransactionsApi: KinTransactionApi {
    public func getTransactionHistory(request: GetTransactionHistoryRequest,
                                      completion: @escaping (GetTransactionHistoryResponse) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.getHistory(request.protoRequest)
            .then { (grpcResponse: APBTransactionV3GetHistoryResponse)  in
                switch grpcResponse.result {
                case .ok:
                    let transactions = grpcResponse.itemsArray
                        .compactMap { item -> KinTransaction? in
                            guard let item = item as? APBTransactionV3HistoryItem else {
                                return nil
                            }

                            return item.toKinTransactionHistorical(network: network)
                    }
                    let response = GetTransactionHistoryResponse(result: .ok,
                                                                 error: nil,
                                                                 kinTransactions: transactions)
                    completion(response)
                default:
                    let response = GetTransactionHistoryResponse(result: .notFound,
                                                                 error: nil,
                                                                 kinTransactions: nil)
                    completion(response)
                }
            }
            .catch { error in
                let response = GetTransactionHistoryResponse(result: .transientFailure,
                                                             error: error,
                                                             kinTransactions: nil)
                completion(response)
            }
    }

    public func getTransaction(request: GetTransactionRequest,
                               completion: @escaping (GetTransactionResponse) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.getTransaction(request.protoRequest)
            .then { (grpcResponse: APBTransactionV3GetTransactionResponse)  in
                switch grpcResponse.state {
                case .success:
                    let transaction = grpcResponse.hasItem ? grpcResponse.item.toKinTransactionHistorical(network: network) : nil
                    let response = GetTransactionResponse(result: .ok,
                                                          error: nil,
                                                          kinTransaction: transaction)
                    completion(response)
                default:
                    let response = GetTransactionResponse(result: .notFound,
                                                          error: nil,
                                                          kinTransaction: nil)
                    completion(response)
                }
            }
            .catch { error in
                let response = GetTransactionResponse(result: .transientFailure,
                                                      error: error,
                                                      kinTransaction: nil)
                completion(response)
            }
    }

    public func submitTransaction(request: SubmitTransactionRequest,
                                  completion: @escaping (SubmitTransactionResponse) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.submitTransaction(request.protoRequest)
            .then { (grpcResponse: APBTransactionV3SubmitTransactionResponse) in
                switch grpcResponse.result {
                case .ok:
                    guard let transaction =
                        grpcResponse.toKinTransactionAcknowledged(envelopeXdrFromRequest: request.transactionEnvelopeXdr,
                                                                  network: network) else {
                            fallthrough
                    }

                    let response = SubmitTransactionResponse(result: .ok,
                                                             error: nil,
                                                             kinTransaction: transaction)
                    completion(response)
                case .failed:
                    var result: SubmitTransactionResponse.Result = .transientFailure
                    if let transactionResult = try? XDRDecoder.decode(TransactionResultXDR.self,
                                                                      data: grpcResponse.resultXdr) {
                        switch transactionResult.code {
                        case .insufficientBalance:
                            result = .insufficientBalance
                        case .insufficientFee:
                            result = .insufficientFee
                        case .noAccount:
                            result = .noAccount
                        case .badSeq:
                            result = .badSequenceNumber
                        default:
                            break
                        }
                    }

                    let response = SubmitTransactionResponse(result: result,
                                                             error: nil,
                                                             kinTransaction: nil)

                    completion(response)
                case .invoiceError:
                    let invoiceErrors = grpcResponse.invoiceErrorsArray.compactMap { item -> InvoiceError? in
                        guard let error = item as? APBTransactionV3SubmitTransactionResponse_InvoiceError else {
                            return nil
                        }

                        return error.invoiceError
                    }

                    let response = SubmitTransactionResponse(result: .invoiceError,
                                                             error: Errors.invoiceErrors(errors: invoiceErrors),
                                                             kinTransaction: nil)
                    completion(response)
                case .rejected:
                    let response = SubmitTransactionResponse(result: .webhookRejected,
                                                             error: nil,
                                                             kinTransaction: nil)
                    completion(response)
                default:
                    let response = SubmitTransactionResponse(result: .undefinedError,
                                                             error: nil,
                                                             kinTransaction: nil)
                    completion(response)
                }
            }
            .catch { error in
                let response = SubmitTransactionResponse(result: .transientFailure,
                                                         error: error,
                                                         kinTransaction: nil)
                completion(response)
            }
    }

    public func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponse) -> Void) {
        // TODO: we need an rpc to fetch this from Agora
        let response = GetMinFeeForTransactionResponse(result: .ok,
                                                       error: nil,
                                                       fee: Quark(100))
        completion(response)
    }
}

extension AgoraKinTransactionsApi: KinTransactionWhitelistingApi {
    public var isWhitelistingAvailable: Bool {
        return true
    }

    public func whitelistTransaction(request: WhitelistTransactionRequest,
                                     completion: @escaping (WhitelistTransactionResponse) -> Void) {
        /**
         * Effectively a no-op, just passing through since white-listing a transaction
         * is done in Agora's submitTransaction operation.
         */
        let response = WhitelistTransactionResponse(result: .ok,
                                                    error: nil,
                                                    whitelistedTransactionEnvelope: request.transactionEnvelope)
        completion(response)
    }
}

public struct InvoiceError: Equatable, Error {
    public enum Reason: String {
        case unknown = "Unknown"
        case alreadyPaid = "The provided invoice has already been paid for."
        case wrongDestination = "The destination in the operation corresponding to this invoice is incorrect."
        case skuNotFound = "One or more SKUs in the invoice was not found."
    }

    public let operationIndex: Int
    public let invoice: Invoice
    public let reason: Reason
}
