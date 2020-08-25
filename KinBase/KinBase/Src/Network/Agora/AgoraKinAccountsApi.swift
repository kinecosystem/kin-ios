//
//  AgoraKinAccountsApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
import KinGrpcApi

class AgoraEvent {
    private let event: APBAccountV3Event

    init(event: APBAccountV3Event) {
        self.event = event
    }

    class AccountUpdate: AgoraEvent {
        let kinAccount: KinAccount

        init(event: APBAccountV3Event,
             kinAccount: KinAccount) {
            self.kinAccount = kinAccount
            super.init(event: event)
        }
    }

    class TransactionUpdate: AgoraEvent {
        let kinTransaction: KinTransaction

        init(event: APBAccountV3Event,
             kinTransaction: KinTransaction) {
            self.kinTransaction = kinTransaction
            super.init(event: event)
        }
    }
}

public class AgoraKinAccountsApi {
    public enum Errors: Int, Error {
        case unknown
    }

    private let agoraGrpc: AgoraAccountServiceGrpcProxy

    init(agoraGrpc: AgoraAccountServiceGrpcProxy) {
        self.agoraGrpc = agoraGrpc
    }
}

extension AgoraKinAccountsApi: KinAccountApi {
    public func getAccount(request: GetAccountRequest,
                           completion: @escaping (GetAccountResponse) -> Void) {
        agoraGrpc.getAccountInfo(request.protoRequest)
            .then { (grpcResponse: APBAccountV3GetAccountInfoResponse) in
                switch grpcResponse.result {
                case .ok:
                    let response = GetAccountResponse(result: .ok,
                                                         error: nil,
                                                         account: grpcResponse.accountInfo.kinAccount)
                    completion(response)
                default:
                    let response = GetAccountResponse(result: .notFound,
                                                      error: nil,
                                                      account: nil)
                    completion(response)
                }
            }
            .catch { error in
                let response = GetAccountResponse(result: .transientFailure,
                                                  error: error,
                                                  account: nil)
                completion(response)
            }
    }
}

extension AgoraKinAccountsApi: KinAccountCreationApi {
    public func createAccount(request: CreateAccountRequest,
                              completion: @escaping (CreateAccountResponse) -> Void) {
        agoraGrpc.createAccount(request.protoRequest)
            .then { (grpcResponse: APBAccountV3CreateAccountResponse) in
                switch grpcResponse.result {
                case .ok:
                    let response = CreateAccountResponse(result: .ok,
                                                         error: nil,
                                                         account: grpcResponse.accountInfo.kinAccount)
                    completion(response)
                default:
                    let response = CreateAccountResponse(result: .exists,
                                                         error: nil,
                                                         account: nil)
                    completion(response)
                }
            }
            .catch { error in
                let response = CreateAccountResponse(result: .transientFailure,
                                                     error: error,
                                                     account: nil)
                completion(response)
            }
    }
}

extension AgoraKinAccountsApi: KinStreamingApi {
    private func openEventStream(accountId: KinAccount.Id) -> Observable<AgoraEvent> {
        let valueSubject = ValueSubject<AgoraEvent>()

        let request = APBAccountV3GetEventsRequest()
        request.accountId = accountId.proto

        let network = agoraGrpc.network

        let eventsStream = agoraGrpc.getEvents(request).subscribe { (events: APBAccountV3Events) in
            events.eventsArray.forEach { element in
                guard let event = element as? APBAccountV3Event else {
                    return
                }

                if event.typeOneOfCase == .accountUpdateEvent,
                    event.accountUpdateEvent.hasAccountInfo,
                    let kinAccount = event.accountUpdateEvent.accountInfo.kinAccount {
                    let agoraEvent = AgoraEvent.AccountUpdate(event: event,
                                                              kinAccount: kinAccount)
                    valueSubject.onNext(agoraEvent)
                }

                if event.typeOneOfCase == .transactionEvent,
                    let kinTransaction = event.transactionEvent.toKinTransactionAcknowledged(network: network) {
                    let agoraEvent = AgoraEvent.TransactionUpdate(event: event,
                                                                  kinTransaction: kinTransaction)
                    valueSubject.onNext(agoraEvent)
                }
            }
        }

        valueSubject.doOnDisposed { [weak eventsStream] in
            eventsStream?.dispose()
        }

        return valueSubject
    }

    public func streamAccount(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        return openEventStream(accountId: accountId)
            .filter { $0 is AgoraEvent.AccountUpdate }
            .map { ($0 as! AgoraEvent.AccountUpdate).kinAccount }
    }

    public func streamNewTransactions(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return openEventStream(accountId: accountId)
            .filter { $0 is AgoraEvent.TransactionUpdate }
            .map { ($0 as! AgoraEvent.TransactionUpdate).kinTransaction }
    }
}
