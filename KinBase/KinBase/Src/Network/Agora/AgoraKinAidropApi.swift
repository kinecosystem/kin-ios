//
//  AgoraKinAidropApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public class AgoraKinAirdropApi {
    public enum Errors: Int, Error {
        case unknown
    }

    private let agoraGrpc: AgoraAirdropServiceGrpcProxy

    init(agoraGrpc: AgoraAirdropServiceGrpcProxy) {
        self.agoraGrpc = agoraGrpc
    }
}

extension AgoraKinAirdropApi: KinAirdropApi {
    public func airdrop(request: AirdropRequest, completion: @escaping (AirdropResponse) -> Void) {
        agoraGrpc.airdrop(request.protoRequest)
            .then { (grpcResponse: APBAirdropV4RequestAirdropResponse) in
                switch grpcResponse.result {
                case .ok:
                    completion(AirdropResponse(result: .ok))
                default:
                    completion(AirdropResponse(result: .failed))
                }
            }
            .catch { error in
                completion(AirdropResponse(result: .transientFailure))
            }
    }
    
    public func airdrop(account: PublicKey, kin: Kin = 1) -> Promise<AirdropResponse> {
        return Promise { (respond, reject) in
            self.airdrop(request: AirdropRequest(account: account, kin: kin), completion: { it in
                respond(it)
            })
        }
    }
}
