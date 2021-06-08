//
//  AgoraKinAccountsApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

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
                    let accounts = (grpcResponse.tokenAccountInfosArray as NSArray as! [APBAccountV4AccountInfo]).map {
                        AccountDescription(
                            publicKey: $0.accountId.publicKey,
                            balance: $0.balance.kin,
                            closeAuthority: $0.closeAuthority.value.isEmpty ? nil : $0.closeAuthority.publicKey
                        )
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

extension AgoraKinAccountsApi: KinStreamingApiV4 {
    private func openEventStreamV4(account: PublicKey) -> Observable<AgoraEventV4> {
        let valueSubject = ValueSubject<AgoraEventV4>()

        let request = APBAccountV4GetEventsRequest()
        request.accountId = account.solanaAccountId

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

    public func streamAccountV4(_ account: PublicKey) -> Observable<KinAccount> {
        return openEventStreamV4(account: account)
            .filter { $0 is AgoraEventV4.AccountUpdate }
            .map { ($0 as! AgoraEventV4.AccountUpdate).kinAccount }
    }

    public func streamNewTransactionsV4(account: PublicKey) -> Observable<KinTransaction> {
        return openEventStreamV4(account: account)
            .filter { $0 is AgoraEventV4.TransactionUpdate }
            .map { ($0 as! AgoraEventV4.TransactionUpdate).kinTransaction }
    }
}
