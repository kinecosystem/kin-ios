//
//  AgoraKinTransactionsApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

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

extension AgoraKinTransactionsApi: KinTransactionApiV4 {
    public func getMinKinVersion(request: GetMinimumKinVersionRequestV4, completion: @escaping (GetMinimumKinVersionResponseV4) -> Void) {
        agoraGrpc.getMinimumVersion(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4GetMinimumKinVersionResponse) in
                completion(GetMinimumKinVersionResponseV4(result: GetMinimumKinVersionResponseV4.Result.ok, error: nil, version: Int(grpcResponse.version)))
            }
    }
    
    public func getServiceConfig(request: GetServiceConfigRequestV4, completion: @escaping (GetServiceConfigResponseV4) -> Void) {
        agoraGrpc.getServiceConfig(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4GetServiceConfigResponse)  in
                  let subsidizer = grpcResponse.subsidizerAccount.publicKey
                  let tokenProgram = grpcResponse.tokenProgram.publicKey
                  let token = grpcResponse.token.publicKey
                
                completion(GetServiceConfigResponseV4(result: GetServiceConfigResponseV4.Result.ok, subsidizerAccount: subsidizer, tokenProgram: tokenProgram, token: token))
            }
            .catch { error in
                var result = GetServiceConfigResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                completion(GetServiceConfigResponseV4(result: result, subsidizerAccount: nil, tokenProgram: nil, token: nil))
            }
    }
    
    public func getRecentBlockHash(request: GetRecentBlockHashRequestV4, completion: @escaping (GetRecentBlockHashResonseV4) -> Void) {
        agoraGrpc.getRecentBlockHashRequest(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4GetRecentBlockhashResponse)  in
                let recentBlockHash = Hash([Byte](grpcResponse.blockhash.value))
                
                completion(GetRecentBlockHashResonseV4(result: GetRecentBlockHashResonseV4.Result.ok, blockHash: recentBlockHash))
            }
            .catch { error in
                var result = GetRecentBlockHashResonseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                completion(GetRecentBlockHashResonseV4(result: result, blockHash: nil))
            }
    }
    
    public func getMinimumBalanceForRentExemption(request: GetMinimumBalanceForRentExemptionRequestV4, completion: @escaping (GetMinimumBalanceForRentExemptionResponseV4) -> Void) {
        agoraGrpc.getMinimumBalanceForRentExemptionRequest(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4GetMinimumBalanceForRentExemptionResponse)  in
                completion(GetMinimumBalanceForRentExemptionResponseV4(result: GetMinimumBalanceForRentExemptionResponseV4.Result.ok, lamports: grpcResponse.lamports))
            }
            .catch { error in
                var result = GetMinimumBalanceForRentExemptionResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                completion(GetMinimumBalanceForRentExemptionResponseV4(result: result, lamports: 0))
            }
    }
    
    public func getTransactionHistory(request: GetTransactionHistoryRequestV4, completion: @escaping (GetTransactionHistoryResponseV4) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.getHistory(request.protoRequest)
            .then { grpcResponse in
                switch grpcResponse.result {
                case .ok:
                    let transactions = grpcResponse.itemsArray.compactMap {
                        ($0 as? APBTransactionV4HistoryItem)?.toKinTransactionHistorical(network: network)
                    }
                    
                    let response = GetTransactionHistoryResponseV4(
                        result: .ok,
                        error: nil,
                        kinTransactions: transactions
                    )
                    
                    completion(response)
                    
                default:
                    let response = GetTransactionHistoryResponseV4(
                        result: .notFound,
                        error: nil,
                        kinTransactions: nil
                    )
                    
                    completion(response)
                }
            }
            .catch { error in
                var result = GetTransactionHistoryResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                
                let response = GetTransactionHistoryResponseV4(
                    result: result,
                    error: error,
                    kinTransactions: nil
                )
                
                completion(response)
            }
    }
    
    public func getTransaction(request: GetTransactionRequestV4, completion: @escaping (GetTransactionResponseV4) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.getTransaction(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4GetTransactionResponse)  in
                switch grpcResponse.state {
                case .success:
                    let transaction = grpcResponse.hasItem ? grpcResponse.item.toKinTransactionHistorical(network: network) : nil
                    let response = GetTransactionResponseV4(result: .ok,
                                                          error: nil,
                                                          kinTransaction: transaction)
                    completion(response)
                default:
                    let response = GetTransactionResponseV4(result: .notFound,
                                                          error: nil,
                                                          kinTransaction: nil)
                    completion(response)
                }
            }
            .catch { error in
                var result = GetTransactionResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                let response = GetTransactionResponseV4(result: result,
                                                      error: error,
                                                      kinTransaction: nil)
                completion(response)
            }
    }
    
    public func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponseV4) -> Void) {
        let response = GetMinFeeForTransactionResponseV4(result: .ok,
                                                       error: nil,
                                                       fee: Quark(0))
        completion(response)
    }

    public func signTransaction(request: SignTransactionRequestV4, completion: @escaping (SignTransactionResponseV4) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.signTransaction(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4SignTransactionResponse) in
                switch grpcResponse.result {
                case .invoiceError:
                    let invoiceErrors = grpcResponse.invoiceErrorsArray.compactMap { item -> InvoiceError? in
                        guard let error = item as? APBCommonV3InvoiceError else {
                            return nil
                        }
                        return error.invoiceError
                    }
                    let response = SignTransactionResponseV4(result: .invoiceError, error: Errors.invoiceErrors(errors: invoiceErrors), kinTransaction: nil)
                    completion(response)

                case .rejected:
                    let response = SignTransactionResponseV4(result: .webhookRejected, error: nil, kinTransaction: nil)
                    completion(response)

                case .ok:
                    guard let signature = Signature(grpcResponse.signature.value) else {
                        fallthrough
                    }
                    let solanaTransaction = request.transaction.updatingSignature(signature: signature)
                    guard let transaction = grpcResponse.toKinTransactionAcknowledged(solanaTransaction: solanaTransaction, network: network) else {
                        fallthrough
                    }
                    let response = SignTransactionResponseV4(result: .ok, error: nil, kinTransaction: transaction)
                    completion(response)

                default:
                    let response = SignTransactionResponseV4(result: .undefinedError, error: nil, kinTransaction: nil)
                    completion(response)
                }
            }
            .catch { error in
                var result = SignTransactionResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                completion(SignTransactionResponseV4(result: result, error: error, kinTransaction: nil))
            }
    }
    
    public func submitTransaction(request: SubmitTransactionRequestV4, completion: @escaping (SubmitTransactionResponseV4) -> Void) {
        let network = agoraGrpc.network
        agoraGrpc.submitTransaction(request.protoRequest)
            .then { (grpcResponse: APBTransactionV4SubmitTransactionResponse)  in
                switch grpcResponse.result {
                case .ok:
                    fallthrough
                case .alreadySubmitted:
                    guard let signature = Signature(grpcResponse.signature.value) else {
                        fallthrough
                    }
                    let solanaTransaction = request.transaction.updatingSignature(signature: signature)
                    guard let transaction = grpcResponse.toKinTransactionAcknowledged(solanaTransaction: solanaTransaction, network: network) else {
                        fallthrough
                    }

                    let response = SubmitTransactionResponseV4(result: .ok, error: nil, kinTransaction: transaction)
                    completion(response)
                
                case .failed:
                    let result: SubmitTransactionResponseV4.Result
                    switch grpcResponse.transactionError.reason {
                    case .insufficientFunds:
                        result = .insufficientBalance
                    case .invalidAccount:
                        result = .noAccount
                    case .badNonce:
                        result = .badSequenceNumber
                    default:
                        result = .transientFailure
                    }
                    let response = SubmitTransactionResponseV4(
                        result: result,
                        error: nil,
                        kinTransaction: nil
                    )

                    completion(response)
                    
                case .invoiceError:
                    let invoiceErrors = grpcResponse.invoiceErrorsArray.compactMap { item -> InvoiceError? in
                        guard let error = item as? APBCommonV3InvoiceError else {
                            return nil
                        }

                        return error.invoiceError
                    }

                    let response = SubmitTransactionResponseV4(result: .invoiceError,
                                                             error: Errors.invoiceErrors(errors: invoiceErrors),
                                                             kinTransaction: nil)
                    completion(response)
                case .rejected:
                    let response = SubmitTransactionResponseV4(result: .webhookRejected,
                                                             error: nil,
                                                             kinTransaction: nil)
                    completion(response)
                default:
                    let response = SubmitTransactionResponseV4(result: .undefinedError,
                                                             error: nil,
                                                             kinTransaction: nil)
                    completion(response)
                }
            }
            .catch { error in
                var result = SubmitTransactionResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                completion(SubmitTransactionResponseV4(result: result, error: error, kinTransaction: nil))
            }
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
