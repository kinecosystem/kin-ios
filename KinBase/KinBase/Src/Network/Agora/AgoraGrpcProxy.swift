//
//  AgoraGrpcProxy.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
import KinGrpcApi

protocol AgoraGrpcProxyType {
    var network: KinNetwork { get }
}

protocol AgoraAccountServiceGrpcProxy: AgoraGrpcProxyType {
    // V3 Apis
    func createAccount(_ request: APBAccountV3CreateAccountRequest) -> Promise<APBAccountV3CreateAccountResponse>
    func getAccountInfo(_ request: APBAccountV3GetAccountInfoRequest) -> Promise<APBAccountV3GetAccountInfoResponse>
    func getEvents(_ request: APBAccountV3GetEventsRequest) -> Observable<APBAccountV3Events>
    
    //  V4 Apis
    func createAccount(_ request: APBAccountV4CreateAccountRequest) -> Promise<APBAccountV4CreateAccountResponse>
    func getAccountInfo(_ request: APBAccountV4GetAccountInfoRequest) -> Promise<APBAccountV4GetAccountInfoResponse>
    func getEvents(_ request: APBAccountV4GetEventsRequest) -> Observable<APBAccountV4Events>
    func resolveTokenAccounts(_ request: APBAccountV4ResolveTokenAccountsRequest) -> Promise<APBAccountV4ResolveTokenAccountsResponse>
}

protocol AgoraTransactionServiceGrpcProxy: AgoraGrpcProxyType {
    // V3 Apis
    func getHistory(_ request: APBTransactionV3GetHistoryRequest) -> Promise<APBTransactionV3GetHistoryResponse>
    func submitTransaction(_ request: APBTransactionV3SubmitTransactionRequest) -> Promise<APBTransactionV3SubmitTransactionResponse>
    func getTransaction(_ request: APBTransactionV3GetTransactionRequest) -> Promise<APBTransactionV3GetTransactionResponse>
    
    // V4 Apis
    func getHistory(_ request: APBTransactionV4GetHistoryRequest) -> Promise<APBTransactionV4GetHistoryResponse>
    func submitTransaction(_ request: APBTransactionV4SubmitTransactionRequest) -> Promise<APBTransactionV4SubmitTransactionResponse>
    func getTransaction(_ request: APBTransactionV4GetTransactionRequest) -> Promise<APBTransactionV4GetTransactionResponse>
    func getServiceConfig(_ request: APBTransactionV4GetServiceConfigRequest) -> Promise<APBTransactionV4GetServiceConfigResponse>
    func getMinimumBalanceForRentExemptionRequest(_ request: APBTransactionV4GetMinimumBalanceForRentExemptionRequest) -> Promise<APBTransactionV4GetMinimumBalanceForRentExemptionResponse>
    func getRecentBlockHashRequest(_ request: APBTransactionV4GetRecentBlockhashRequest) -> Promise<APBTransactionV4GetRecentBlockhashResponse>
    func getMinimumVersion(_ request: APBTransactionV4GetMinimumKinVersionRequest) -> Promise<APBTransactionV4GetMinimumKinVersionResponse>
}

protocol AgoraAirdropServiceGrpcProxy : AgoraGrpcProxyType {
    // V4 Apis
    func airdrop(_ request: APBAirdropV4RequestAirdropRequest) -> Promise<APBAirdropV4RequestAirdropResponse>
}

class AgoraGrpcProxy: AgoraGrpcProxyType {
    enum Errors: Int, Error {
        case internalInconsistency
    }

    typealias GRPCUnaryCall<RequestType, ResponseType: AnyObject> =
        (RequestType, GRPCUnaryResponseHandler<ResponseType>, GRPCCallOptions?) -> GRPCUnaryProtoCall
    typealias GRPCStreamCall<RequestType, ResponseType: AnyObject> =
        (RequestType, GRPCStreamResponseHandler<ResponseType>, GRPCCallOptions?) -> GRPCUnaryProtoCall

    private let grpcAccountService: APBAccountV3Account2
    private let grpcTransactionService: APBTransactionV3Transaction2
    private let grpcAccountServiceV4: APBAccountV4Account2
    private let grpcTransactionServiceV4: APBTransactionV4Transaction2
    private let grpcAirdropServiceV4: APBAirdropV4Airdrop2

    let network: KinNetwork
    private let logger: KinLoggerFactory
    private lazy var log: KinLogger = {
        logger.getLogger(name: String(describing: self))
    }()

    init(network: KinNetwork,
         appInfoProvider: AppInfoProvider,
         storage: KinStorageType,
         logger: KinLoggerFactory,
         interceptorFactories: [GRPCInterceptorFactory]) {
        self.network = network
        self.logger = logger
    
        let grpcServiceProvider = GrpcServiceProvider(host: network.agoraUrl,
                                                      interceptorFactories: interceptorFactories)
        self.grpcAccountService = grpcServiceProvider.accountService
        self.grpcTransactionService = grpcServiceProvider.transactionService
        
        self.grpcAccountServiceV4 = grpcServiceProvider.accountServiceV4
        self.grpcTransactionServiceV4 = grpcServiceProvider.transactionServiceV4
        
        self.grpcAirdropServiceV4 = grpcServiceProvider.airdropServiceV4
    }

    private func callUnaryRPC<RequestType: GPBMessage, ResponseType: GPBMessage>
        (request: RequestType,
         protoMethod: @escaping GRPCUnaryCall<RequestType, ResponseType>) -> Promise<ResponseType> {
        return Promise<ResponseType> { [weak self] fulfill, reject in
            let handler = { (grpcResponse: ResponseType, error: Error?) in
                if let error = error {
                    reject(error)
                    return
                }
                
                self?.log.debug(msg:"AgoraGrpcProxy::response::\(grpcResponse)")

                fulfill(grpcResponse)
            }

            typealias ResponseHandler = GRPCUnaryResponseHandler<ResponseType>
            guard let responseHandler = ResponseHandler(responseHandler: handler, responseDispatchQueue: DispatchQueue.promises) else {
                reject(Errors.internalInconsistency)
                return
            }
            
            self?.log.debug(msg:"AgoraGrpcProxy::request::\(request)")

            let call: GRPCUnaryProtoCall = protoMethod(request, responseHandler, nil)
            call.start()
        }
    }

    private func callStreamingRPC<RequestType: GPBMessage, ResponseType: GPBMessage>
        (request: RequestType,
        protoMethod: @escaping GRPCStreamCall<RequestType, ResponseType>) -> Observable<ResponseType> {

        let subject = ValueSubject<ResponseType>()

        let handler = { [weak self] (grpcResponse: ResponseType?, error: Error?) in
            guard let grpcResponse = grpcResponse, error == nil else {
                return
            }
            
            self?.log.debug(msg:"AgoraGrpcProxy::streamUpdate::\(grpcResponse)")

            subject.onNext(grpcResponse)
        }

        let streamResponseHandler = GRPCStreamResponseHandler<ResponseType>(responseHandler: handler)

        self.log.debug(msg:"AgoraGrpcProxy::streamRequest::\(request)")
        
        let call: GRPCUnaryProtoCall = protoMethod(request, streamResponseHandler, nil)
        call.start()

        _ = subject.doOnDisposed { [weak call] in
            call?.cancel()
        }

        return subject
    }
}

// MARK: - AccountService
extension AgoraGrpcProxy: AgoraAccountServiceGrpcProxy {
    // V3 Apis
    func createAccount(_ request: APBAccountV3CreateAccountRequest) -> Promise<APBAccountV3CreateAccountResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcAccountService.createAccount(withMessage:responseHandler:callOptions:))
    }

    func getAccountInfo(_ request: APBAccountV3GetAccountInfoRequest) -> Promise<APBAccountV3GetAccountInfoResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcAccountService.getInfoWithMessage(_:responseHandler:callOptions:))
    }

    func getEvents(_ request: APBAccountV3GetEventsRequest) -> Observable<APBAccountV3Events> {
        return callStreamingRPC(request: request,
                                protoMethod: grpcAccountService.getEventsWithMessage(_:responseHandler:callOptions:))
    }
    
    // V4 Apis
    func createAccount(_ request: APBAccountV4CreateAccountRequest) -> Promise<APBAccountV4CreateAccountResponse> {
        return callUnaryRPC(request: request,
        protoMethod: grpcAccountServiceV4.createAccount(withMessage:responseHandler:callOptions:))
    }
    
    func getAccountInfo(_ request: APBAccountV4GetAccountInfoRequest) -> Promise<APBAccountV4GetAccountInfoResponse> {
       return callUnaryRPC(request: request,
                           protoMethod: grpcAccountServiceV4.getInfoWithMessage(_:responseHandler:callOptions:))
    }
    
    func getEvents(_ request: APBAccountV4GetEventsRequest) -> Observable<APBAccountV4Events> {
       return callStreamingRPC(request: request,
                               protoMethod: grpcAccountServiceV4.getEventsWithMessage(_:responseHandler:callOptions:))
    }
    
    func resolveTokenAccounts(_ request: APBAccountV4ResolveTokenAccountsRequest) -> Promise<APBAccountV4ResolveTokenAccountsResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcAccountServiceV4.resolveTokenAccounts(withMessage:responseHandler:callOptions:))
    }
}

// MARK: - TransactionService
extension AgoraGrpcProxy: AgoraTransactionServiceGrpcProxy {

    
    // V3 Apis
    func getHistory(_ request: APBTransactionV3GetHistoryRequest) -> Promise<APBTransactionV3GetHistoryResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionService.getHistoryWithMessage(_:responseHandler:callOptions:))
    }

    func submitTransaction(_ request: APBTransactionV3SubmitTransactionRequest) -> Promise<APBTransactionV3SubmitTransactionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionService.submitTransaction(withMessage:responseHandler:callOptions:))
    }

    func getTransaction(_ request: APBTransactionV3GetTransactionRequest) -> Promise<APBTransactionV3GetTransactionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionService.getWithMessage(_:responseHandler:callOptions:))
    }
    
    //  V4 Apis
    func getHistory(_ request: APBTransactionV4GetHistoryRequest) -> Promise<APBTransactionV4GetHistoryResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getHistoryWithMessage(_:responseHandler:callOptions:))
    }
    
    func submitTransaction(_ request: APBTransactionV4SubmitTransactionRequest) -> Promise<APBTransactionV4SubmitTransactionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.submitTransaction(withMessage:responseHandler:callOptions:))
    }
    
    func getTransaction(_ request: APBTransactionV4GetTransactionRequest) -> Promise<APBTransactionV4GetTransactionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getWithMessage(_:responseHandler:callOptions:))
    }
    
    func getServiceConfig(_ request: APBTransactionV4GetServiceConfigRequest) -> Promise<APBTransactionV4GetServiceConfigResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getServiceConfig(withMessage:responseHandler:callOptions:))
    }
    
    func getMinimumBalanceForRentExemptionRequest(_ request: APBTransactionV4GetMinimumBalanceForRentExemptionRequest) -> Promise<APBTransactionV4GetMinimumBalanceForRentExemptionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getMinimumBalanceForRentExemption(withMessage:responseHandler:callOptions:))
    }
    
    func getRecentBlockHashRequest(_ request: APBTransactionV4GetRecentBlockhashRequest) -> Promise<APBTransactionV4GetRecentBlockhashResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getRecentBlockhash(withMessage:responseHandler:callOptions:))
    }
    
    func getMinimumVersion(_ request: APBTransactionV4GetMinimumKinVersionRequest) -> Promise<APBTransactionV4GetMinimumKinVersionResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcTransactionServiceV4.getMinimumKinVersion(withMessage:responseHandler:callOptions:))
    }
}

// MARK: Airdrop Service
extension AgoraGrpcProxy: AgoraAirdropServiceGrpcProxy {
    func airdrop(_ request: APBAirdropV4RequestAirdropRequest) -> Promise<APBAirdropV4RequestAirdropResponse> {
        return callUnaryRPC(request: request,
                            protoMethod: grpcAirdropServiceV4.request(withMessage:responseHandler:callOptions:))
    }
}

// MARK: - GRPCStreamResponseHandler
class GRPCStreamResponseHandler<ResponseType>: NSObject, GRPCProtoResponseHandler {
    var dispatchQueue: DispatchQueue = .promises

    let responseHandler: (ResponseType?, Error?) -> Void

    init(responseHandler: @escaping (ResponseType?, Error?) -> Void) {
        self.responseHandler = responseHandler
        super.init()
    }

    func didReceiveProtoMessage(_ message: GPBMessage?) {
        guard let responseMessage = message as? ResponseType else {
            return
        }

        responseHandler(responseMessage, nil)
    }

    func didWriteMessage() {
        // No-op
    }

    func didClose(withTrailingMetadata trailingMetadata: [AnyHashable : Any]?,
                  error: Error?) {
        responseHandler(nil, error)
    }
}

public enum GrpcErrors : Int {
       case ok
       case cancelled
       case unknown
       case invalidArgument
       case deadlineExceeded
       case notFound
       case alreadyExists
       case permissionDenied
       case resourceExhausted
       case failedPrecondition
       case aborted
       case outOfRange
       case unimplemented
       case internalError
       case unavailable
       case dataLoss
       case unauthenticated
    
    public func asError() -> Error {
        return NSError(domain: "io.grpc", code: rawValue, userInfo: nil)
    }
}

let GRPC_RETRYABLE_STATUS = [GrpcErrors](arrayLiteral:
    .unknown,
    .cancelled,
    .deadlineExceeded,
    .aborted,
    .internalError,
    .unavailable
)

public extension Error {
    
    func isGrpcError() -> Bool {
        return (self as NSError).domain == "io.grpc"
    }
    
    func canRetry() -> Bool {
        let error = self as NSError
        return (isGrpcError() && GRPC_RETRYABLE_STATUS.contains(GrpcErrors(rawValue: error.code)!)) || ((error as? NetworkOperationErrors) == NetworkOperationErrors.timeout)
    }
    
    func isForcedUpgrade() -> Bool {
        let error = self as NSError
        return isGrpcError() && GrpcErrors.failedPrecondition == GrpcErrors(rawValue: error.code)!
    }
}
