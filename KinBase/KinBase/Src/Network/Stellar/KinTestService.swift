//
//  KinTestService.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public protocol KinTestServiceType {
    func fundAccount(_ accountId: KinAccount.Id) -> Promise<Void>
}

public class KinTestService: KinTestServiceType {
    public enum Errors: Error {
        case unknown
        case transientFailure(error: Error)
    }
    private let friendBotApi: FriendBotApi
    private let networkOperationHandler: NetworkOperationHandler
    private let dispatchQueue: DispatchQueue

    init(friendBotApi: FriendBotApi,
         networkOperationHandler: NetworkOperationHandler,
         dispatchQueue: DispatchQueue) {
        self.friendBotApi = friendBotApi
        self.networkOperationHandler = networkOperationHandler
        self.dispatchQueue = dispatchQueue
    }

    public func fundAccount(_ accountId: KinAccount.Id) -> Promise<Void> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.friendBotApi.fundAccount(request: CreateAccountRequest(accountId: accountId)) { (response) in
                switch response.result {
                case .ok:
                    respond.onSuccess(())
                default:
                    var error = Errors.unknown
                    if let transientError = response.error {
                        error = Errors.transientFailure(error: transientError)
                    }
                    respond.onError?(error)
                }
            }
        }
    }
}

public class KinTestServiceV4: KinTestServiceType {
    public enum Errors: Error {
        case unknown
        case transientFailure(error: Error)
    }
    private let airdropApi: KinAirdropApi
    private let networkOperationHandler: NetworkOperationHandler
    private let dispatchQueue: DispatchQueue

    init(airdropApi: KinAirdropApi,
         networkOperationHandler: NetworkOperationHandler,
         dispatchQueue: DispatchQueue) {
        self.airdropApi = airdropApi
        self.networkOperationHandler = networkOperationHandler
        self.dispatchQueue = dispatchQueue
    }

    public func fundAccount(_ accountId: KinAccount.Id) -> Promise<Void> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.airdropApi.airdrop(request: AirdropRequest(accountId: accountId, kin: 1)) { (response) in
                switch response.result {
                case .ok:
                    respond.onSuccess(())
                    fallthrough
                default:
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
}
