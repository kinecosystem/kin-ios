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
    func fundAccount(_ account: PublicKey, amount: Decimal) -> Promise<Void>
}

public class KinTestServiceV4: KinTestServiceType {
    
    private let airdropApi: KinAirdropApi
    private let networkOperationHandler: NetworkOperationHandler
    private let kinService: KinServiceV4

    init(airdropApi: KinAirdropApi, kinService: KinServiceV4, networkOperationHandler: NetworkOperationHandler) {
        self.airdropApi = airdropApi
        self.networkOperationHandler = networkOperationHandler
        self.kinService = kinService
    }

    public func fundAccount(_ account: PublicKey, amount: Decimal) -> Promise<Void> {
        return networkOperationHandler.queueWork { [weak self] respond in
            guard let self = self else {
                respond.onError?(Errors.unknown)
                return
            }

            self.airdropApi.airdrop(request: AirdropRequest(account: account, kin: amount)) { (response) in
                switch response.result {
                case .ok:
                    respond.onSuccess(())
                default:
                    self.kinService.resolveTokenAccounts(account: account)
                        .then { accounts in
                            self.airdropApi.airdrop(request: AirdropRequest(account: accounts.first?.publicKey ?? account, kin: amount)) { response in
                                switch response.result {
                                case .ok:
                                    respond.onSuccess(())
                                default:
                                    respond.onError?(Errors.unknown)
                                }
                            }
                    }
                    respond.onError?(Errors.unknown)
                }
            }
        }
    }
}

extension KinTestServiceV4 {
    public enum Errors: Error {
        case unknown
        case transientFailure(error: Error)
    }
}
