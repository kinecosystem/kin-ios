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
    func createAccount(_ request: APBAccountV3CreateAccountRequest) -> Promise<APBAccountV3CreateAccountResponse>
    func getAccountInfo(_ request: APBAccountV3GetAccountInfoRequest) -> Promise<APBAccountV3GetAccountInfoResponse>
    func getEvents(_ request: APBAccountV3GetEventsRequest) -> Observable<APBAccountV3Events>
}

protocol AgoraTransactionServiceGrpcProxy: AgoraGrpcProxyType {
    func getHistory(_ request: APBTransactionV3GetHistoryRequest) -> Promise<APBTransactionV3GetHistoryResponse>
    func submitTransaction(_ request: APBTransactionV3SubmitTransactionRequest) -> Promise<APBTransactionV3SubmitTransactionResponse>
    func getTransaction(_ request: APBTransactionV3GetTransactionRequest) -> Promise<APBTransactionV3GetTransactionResponse>
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

    let network: KinNetwork
    private let logger: KinLoggerFactory
    private lazy var log: KinLogger = {
        logger.getLogger(name: String(describing: self))
    }()

    init(network: KinNetwork,
         appInfoProvider: AppInfoProvider,
         storage: KinStorageType,
         logger: KinLoggerFactory) {
        self.network = network
        self.logger = logger
        let authContext = AppUserAuthContext(appInfoProvider: appInfoProvider)
        let userAgentContext = UserAgentContext(storage: storage)
        let grpcServiceProvider = GrpcServiceProvider(host: network.agoraUrl,
                                                      authContext: authContext,
                                                      userAgentContext: userAgentContext)
        self.grpcAccountService = grpcServiceProvider.accountService
        self.grpcTransactionService = grpcServiceProvider.transactionService
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
}

// MARK: - TransactionService
extension AgoraGrpcProxy: AgoraTransactionServiceGrpcProxy {
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
