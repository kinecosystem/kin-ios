//
//  HorizonKinApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-03-30.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

public class HorizonKinApi {
    public enum Errors: Int, Error {
        case malformattedResponse
    }

    private let stellarSdk: StellarSdkProxy

    private var accountStreams = [KinAccount.Id: AccountsStreamItem]()
    private var transactionStreams = [KinAccount.Id: TransactionsStreamItem]()

    public init(stellarSdkProxy: StellarSdkProxy) {
        self.stellarSdk = stellarSdkProxy
    }
}

extension HorizonKinApi: KinAccountApi {
    public func getAccount(request: GetAccountRequest,
                    completion: @escaping (GetAccountResponse) -> Void) {
        stellarSdk.getAccountDetails(accountId: request.accountId) { (stellarResponse) in
            switch stellarResponse {
            case .success(let details):
                let kinResponse = GetAccountResponse(result: .ok,
                                                     error: nil,
                                                     account: details.kinAccount)
                completion(kinResponse)
            case .failure(let error):
                if case .serverGone(_, _) = error {
                    let kinResponse = GetAccountResponse(result: .upgradeRequired,
                                                         error: error,
                                                         account: nil)
                    completion(kinResponse)
                } else {
                    let kinResponse = GetAccountResponse(result: .transientFailure,
                                                         error: error,
                                                         account: nil)
                    completion(kinResponse)
                }
            }
        }
    }
}

extension HorizonKinApi: KinTransactionApi {
    private struct Constants {
        static let futureOnlyCursor = "now"
    }

    public func getTransactionHistory(request: GetTransactionHistoryRequest,
                               completion: @escaping (GetTransactionHistoryResponse) -> Void) {
        stellarSdk.getTransactions(forAccount: request.accountId,
                                   from: request.cursor,
                                   order: request.order.stellarOrder) { [weak self] response -> (Void) in
            guard let self = self else { return }

            let completeWithError = { (error: Error) in
                let kinResponse = GetTransactionHistoryResponse(result: .transientFailure,
                                                                error: error,
                                                                kinTransactions: nil)
                completion(kinResponse)
            }

            switch response {
            case .success(let details):
                do {
                    let transactions = try details.records.map { transactionResponse -> KinTransaction in
                        return try transactionResponse.toHistoricalKinTransaction(network: self.stellarSdk.network)
                    }

                    let kinResponse = GetTransactionHistoryResponse(result: .ok,
                                                                    error: nil,
                                                                    kinTransactions: transactions)
                    completion(kinResponse)
                } catch let error {
                    completeWithError(error)
                }
            case .failure(let error):
                if case .serverGone(_, _) = error {
                    let kinResponse = GetTransactionHistoryResponse(result: .upgradeRequired,
                                                                    error: error,
                                                                    kinTransactions: nil)
                    completion(kinResponse)
                } else {
                    completeWithError(error)
                }
            }

        }
    }

    public func getTransaction(request: GetTransactionRequest,
                        completion: @escaping (GetTransactionResponse) -> Void) {
        let data = Data(request.transactionHash.rawValue)
        let hashString = data.hexEncodedString()
        stellarSdk.getTransactionDetails(transactionHash: hashString) { (response) -> (Void) in
            let completeWithError = { (error: Error) in
                let kinResponse = GetTransactionResponse(result: .transientFailure,
                                                         error: error,
                                                         kinTransaction: nil)
                completion(kinResponse)
            }

            switch response {
            case .success(let details):
                do {
                    let transaction = try details.toHistoricalKinTransaction(network: self.stellarSdk.network)
                    let kinResponse = GetTransactionResponse(result: .ok,
                                                             error: nil,
                                                             kinTransaction: transaction)
                    completion(kinResponse)
                } catch let error {
                    completeWithError(error)
                }
            case .failure(let error):
                if case .serverGone(_, _) = error {
                    let kinResponse = GetTransactionResponse(result: .upgradeRequired,
                                                             error: error,
                                                             kinTransaction: nil)
                    completion(kinResponse)
                } else {
                    completeWithError(error)
                }
            }
        }
    }

    public func getTransactionMinFee(completion: @escaping (GetMinFeeForTransactionResponse) -> Void) {
        stellarSdk.getLedgers(order: .descending, limit: 1) { (response) -> (Void) in
            let completeWithError = { (error: Error) in
                let kinResponse = GetMinFeeForTransactionResponse(result: .error,
                                                                  error: error,
                                                                  fee: nil)
                completion(kinResponse)
            }

            switch response {
            case .success(let details):
                guard let fee = details.records.first?.baseFeeInStroops else {
                    completeWithError(Errors.malformattedResponse)
                    return
                }

                let kinResponse = GetMinFeeForTransactionResponse(result: .ok,
                                                                  error: nil,
                                                                  fee: Quark(fee))
                completion(kinResponse)
            case .failure(let error):
                if case .serverGone(_, _) = error {
                    let kinResponse = GetMinFeeForTransactionResponse(result: .upgradeRequired,
                                                                      error: error,
                                                                      fee: nil)
                    completion(kinResponse)
                } else {
                    completeWithError(error)
                }
            }
        }
    }

    public func submitTransaction(request: SubmitTransactionRequest,
                           completion: @escaping (SubmitTransactionResponse) -> Void) {

        stellarSdk.postTransaction(transactionEnvelope: request.transactionEnvelopeXdr) { [weak self] stellarResponse -> (Void) in
            guard let self = self else { return }

            let completeWithError = { (error: Error) in
                let kinResponse = SubmitTransactionResponse(result: .transientFailure,
                                                            error: error,
                                                            kinTransaction: nil)
                completion(kinResponse)
            }

            switch stellarResponse {
            case .success(let details):
                do {
                    let transaction = try details.toAcknowledgedKinTransaction(network: self.stellarSdk.network)
                    let kinResponse = SubmitTransactionResponse(result: .ok,
                                                                error: nil,
                                                                kinTransaction: transaction)
                    completion(kinResponse)
                } catch let error {
                    completeWithError(error)
                }
            case .failure(let error):
                if case let .badRequest(_, errorResponse) = error,
                    let resultXdrString = errorResponse?.extras.resultXdr,
                    let resultData = Data(base64Encoded: resultXdrString),
                    let transactionResult = try? XDRDecoder.decode(TransactionResultXDR.self, data:resultData),
                    case let .success(operationResults) = transactionResult.resultBody,
                    let operationResult = operationResults.first,
                    case let .payment(_, paymentResult) = operationResult,
                    case let .empty(code) = paymentResult,
                    let paymentResultCode = PaymentResultCode(rawValue: code) {

                    let result: SubmitTransactionResponse.Result = {
                        switch paymentResultCode {
                        case .underfunded: return .insufficientBalance
                        default: return .transientFailure
                        }
                    }()

                    let kinResponse = SubmitTransactionResponse(result: result,
                                                                error: error,
                                                                kinTransaction: nil)
                    completion(kinResponse)
                } else if case .serverGone(_, _) = error {
                    let kinResponse = SubmitTransactionResponse(result: .upgradeRequired,
                                                                error: error,
                                                                kinTransaction: nil)
                    completion(kinResponse)
                }
                else {
                    completeWithError(error)
                }
            }
        }
    }
}

extension HorizonKinApi: KinStreamingApi {
    public func streamAccount(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        let accountStreamItem = accountStreams[accountId] ?? stellarSdk.streamAccount(accountId)
        accountStreams[accountId] = accountStreamItem

        let subject = ValueSubject<KinAccount>()
            .doOnDisposed { [weak accountStreamItem, weak self] in
                accountStreamItem?.closeStream()
                self?.accountStreams[accountId] = nil
        }

        accountStreamItem.onReceive { [weak subject] response -> Void in
            switch response {
            case .response( _, let accountResponse):
                subject?.onNext(accountResponse.kinAccount)
            default:
                break
            }
        }

        return subject
    }

    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        let transactionStreamItem = transactionStreams[accountId] ?? stellarSdk.streamTransactions(for: accountId, cursor: Constants.futureOnlyCursor)
        transactionStreams[accountId] = transactionStreamItem

        let subject = ValueSubject<KinTransaction>()
            .doOnDisposed { [weak transactionStreamItem, weak self] in
                transactionStreamItem?.closeStream()
                self?.transactionStreams[accountId] = nil
        }

        transactionStreamItem.onReceive { [weak subject, weak self] response -> Void in
            switch response {
            case .response( _, let transactionResponse):
                if let self = self,
                    let transaction = try? transactionResponse.toHistoricalKinTransaction(network: self.stellarSdk.network) {
                    subject?.onNext(transaction)
                }
            default:
                break
            }
        }

        return subject
    }
}
