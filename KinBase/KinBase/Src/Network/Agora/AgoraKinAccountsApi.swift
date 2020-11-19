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

class AgoraEventV4 {
    private let event: APBAccountV4Event

    init(event: APBAccountV4Event) {
        self.event = event
    }

    class AccountUpdate: AgoraEventV4 {
        let kinAccount: KinAccount

        init(event: APBAccountV4Event,
             kinAccount: KinAccount) {
            self.kinAccount = kinAccount
            super.init(event: event)
        }
    }

    class TransactionUpdate: AgoraEventV4 {
        let kinTransaction: KinTransaction

        init(event: APBAccountV4Event,
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
                var result = GetAccountResponse.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                let response = GetAccountResponse(result: result,
                                                  error: error,
                                                  account: nil)
                completion(response)
            }
    }
}

extension AgoraKinAccountsApi: KinAccountApiV4 {
    public func getAccount(request: GetAccountRequestV4,
                           completion: @escaping (GetAccountResponseV4) -> Void) {
        agoraGrpc.getAccountInfo(request.protoRequest)
            .then { (grpcResponse: APBAccountV4GetAccountInfoResponse) in
                switch grpcResponse.result {
                case .ok:
                    let response = GetAccountResponseV4(result: .ok,
                                                         error: nil,
                                                         account: grpcResponse.accountInfo.kinAccount)
                    completion(response)
                default:
                    let response = GetAccountResponseV4(result: .notFound,
                                                      error: nil,
                                                      account: nil)
                    completion(response)
                }
            }
            .catch { error in
                var result = GetAccountResponseV4.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                let response = GetAccountResponseV4(result: result,
                                                  error: error,
                                                  account: nil)
                completion(response)
            }
    }
    
    public func resolveTokenAccounts(request: ResolveTokenAccountsRequestV4, completion: @escaping (ResolveTokenAccountsResponseV4) -> Void) {
        agoraGrpc.resolveTokenAccounts(request.protoRequest)
                .then { (grpcResponse: APBAccountV4ResolveTokenAccountsResponse) in
                    let accounts = (grpcResponse.tokenAccountsArray as NSArray as! [APBCommonV4SolanaAccountId]).map { (account:APBCommonV4SolanaAccountId) -> SolanaPublicKey in
                        return account.solanaPublicKey
                    }
                    
                    let response = ResolveTokenAccountsResponseV4(result: .ok,
                                                                  error: nil,
                                                                accounts: accounts)
                    completion(response)
                }
                .catch { error in
                    var result = ResolveTokenAccountsResponseV4.Result.undefinedError
                    if error.canRetry() {
                        result = .transientFailure
                    } else if error.isForcedUpgrade() {
                        result = .upgradeRequired
                    }
                    let response = ResolveTokenAccountsResponseV4(result: result,
                                                     error: error,
                                                     accounts: nil)
                    completion(response)
                }
    }
}

extension AgoraKinAccountsApi: KinAccountCreationApiV4 {
    public func createAccount(request: CreateAccountRequestV4,
                              completion: @escaping (CreateAccountResponseV4) -> Void) {
        agoraGrpc.createAccount(request.protoRequest)
        .then { (grpcResponse: APBAccountV4CreateAccountResponse) in
            switch grpcResponse.result {
            case .ok:
                let response = CreateAccountResponseV4(result: .ok,
                                                     error: nil,
                                                     account: grpcResponse.accountInfo.kinAccount)
                completion(response)
            default:
                let response = CreateAccountResponseV4(result: .exists,
                                                     error: nil,
                                                     account: nil)
                completion(response)
            }
        }
        .catch { error in
            var result = CreateAccountResponseV4.Result.undefinedError
            if error.canRetry() {
                result = .transientFailure
            } else if error.isForcedUpgrade() {
                result = .upgradeRequired
            }
            let response = CreateAccountResponseV4(result: result,
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
                var result = CreateAccountResponse.Result.undefinedError
                if error.canRetry() {
                    result = .transientFailure
                } else if error.isForcedUpgrade() {
                    result = .upgradeRequired
                }
                let response = CreateAccountResponse(result: result,
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

extension AgoraKinAccountsApi: KinStreamingApiV4 {
    private func openEventStreamV4(accountId: KinAccount.Id) -> Observable<AgoraEventV4> {
        let valueSubject = ValueSubject<AgoraEventV4>()

        let request = APBAccountV4GetEventsRequest()
        request.accountId = accountId.solanaAccountId

        let network = agoraGrpc.network

        let eventsStream = agoraGrpc.getEvents(request).subscribe { (events: APBAccountV4Events) in
            events.eventsArray.forEach { element in
                guard let event = element as? APBAccountV4Event else {
                    return
                }

                if event.typeOneOfCase == .accountUpdateEvent,
                    event.accountUpdateEvent.hasAccountInfo,
                    let kinAccount = event.accountUpdateEvent.accountInfo.kinAccount {
                    let agoraEvent = AgoraEventV4.AccountUpdate(event: event,
                                                                kinAccount: kinAccount)
                    valueSubject.onNext(agoraEvent)
                }

                if event.typeOneOfCase == .transactionEvent,
                    let kinTransaction = event.transactionEvent.toKinTransactionAcknowledged(network: network) {
                    let agoraEvent = AgoraEventV4.TransactionUpdate(event: event,
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

    public func streamAccountV4(_ accountId: KinAccount.Id) -> Observable<KinAccount> {
        return openEventStreamV4(accountId: accountId)
            .filter { $0 is AgoraEventV4.AccountUpdate }
            .map { ($0 as! AgoraEventV4.AccountUpdate).kinAccount }
    }

    public func streamNewTransactionsV4(accountId: KinAccount.Id) -> Observable<KinTransaction> {
        return openEventStreamV4(accountId: accountId)
            .filter { $0 is AgoraEventV4.TransactionUpdate }
            .map { ($0 as! AgoraEventV4.TransactionUpdate).kinTransaction }
    }
}
