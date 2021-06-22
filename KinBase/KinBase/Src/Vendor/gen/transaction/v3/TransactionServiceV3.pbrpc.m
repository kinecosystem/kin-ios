#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "TransactionServiceV3.pbrpc.h"
#import "TransactionServiceV3.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "Validate.pbobjc.h"
#import "ModelV3.pbobjc.h"

@implementation APBTransactionV3Transaction

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"kin.agora.transaction.v3"
                 serviceName:@"Transaction"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"kin.agora.transaction.v3"
                 serviceName:@"Transaction"];
}

#pragma clang diagnostic pop

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName
                 callOptions:(GRPCCallOptions *)callOptions {
  return [self initWithHost:host callOptions:callOptions];
}

#pragma mark - Class Methods

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [[self alloc] initWithHost:host callOptions:callOptions];
}

#pragma mark - Method Implementations

#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getHistoryWithRequest:(APBTransactionV3GetHistoryRequest *)request handler:(void(^)(APBTransactionV3GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetHistoryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetHistoryWithRequest:(APBTransactionV3GetHistoryRequest *)request handler:(void(^)(APBTransactionV3GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetHistory"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV3GetHistoryResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getHistoryWithMessage:(APBTransactionV3GetHistoryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetHistory"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV3GetHistoryResponse class]];
}

#pragma mark SubmitTransaction(SubmitTransactionRequest) returns (SubmitTransactionResponse)

/**
 * SubmitTransaction submits a transaction.
 * 
 * If the memo does not conform to the Kin binary memo format,
 * the transaction is not eligible for whitelisting.
 * 
 * If the memo _does_ conform to the Kin binary memo format,
 * the transaction may be whitelisted depending on app
 * configuration.
 * 
 * See: https://github.com/kinecosystem/agora-api-internal/blob/master/spec/memo.md
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)submitTransactionWithRequest:(APBTransactionV3SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV3SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSubmitTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * SubmitTransaction submits a transaction.
 * 
 * If the memo does not conform to the Kin binary memo format,
 * the transaction is not eligible for whitelisting.
 * 
 * If the memo _does_ conform to the Kin binary memo format,
 * the transaction may be whitelisted depending on app
 * configuration.
 * 
 * See: https://github.com/kinecosystem/agora-api-internal/blob/master/spec/memo.md
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToSubmitTransactionWithRequest:(APBTransactionV3SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV3SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SubmitTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV3SubmitTransactionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * SubmitTransaction submits a transaction.
 * 
 * If the memo does not conform to the Kin binary memo format,
 * the transaction is not eligible for whitelisting.
 * 
 * If the memo _does_ conform to the Kin binary memo format,
 * the transaction may be whitelisted depending on app
 * configuration.
 * 
 * See: https://github.com/kinecosystem/agora-api-internal/blob/master/spec/memo.md
 */
- (GRPCUnaryProtoCall *)submitTransactionWithMessage:(APBTransactionV3SubmitTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"SubmitTransaction"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV3SubmitTransactionResponse class]];
}

#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getTransactionWithRequest:(APBTransactionV3GetTransactionRequest *)request handler:(void(^)(APBTransactionV3GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetTransactionWithRequest:(APBTransactionV3GetTransactionRequest *)request handler:(void(^)(APBTransactionV3GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV3GetTransactionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getTransactionWithMessage:(APBTransactionV3GetTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetTransaction"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV3GetTransactionResponse class]];
}

@end
#endif
