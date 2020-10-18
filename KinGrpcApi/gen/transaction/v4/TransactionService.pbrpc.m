#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "transaction/v4/TransactionService.pbrpc.h"
#import "transaction/v4/TransactionService.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "validate/Validate.pbobjc.h"
#import "common/v3/Model.pbobjc.h"
#import "common/v4/Model.pbobjc.h"

@implementation APBTransactionV4Transaction

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"kin.agora.transaction.v4"
                 serviceName:@"Transaction"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"kin.agora.transaction.v4"
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

#pragma mark GetServiceConfig(GetServiceConfigRequest) returns (GetServiceConfigResponse)

/**
 * GetServiceConfig returns the service and token parameters for the token.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getServiceConfigWithRequest:(APBTransactionV4GetServiceConfigRequest *)request handler:(void(^)(APBTransactionV4GetServiceConfigResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetServiceConfigWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetServiceConfig returns the service and token parameters for the token.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetServiceConfigWithRequest:(APBTransactionV4GetServiceConfigRequest *)request handler:(void(^)(APBTransactionV4GetServiceConfigResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetServiceConfig"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetServiceConfigResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetServiceConfig returns the service and token parameters for the token.
 */
- (GRPCUnaryProtoCall *)getServiceConfigWithMessage:(APBTransactionV4GetServiceConfigRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetServiceConfig"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetServiceConfigResponse class]];
}

#pragma mark GetMiniumumKinVersion(GetMiniumumKinVersionRequest) returns (GetMiniumumKinVersionResponse)

/**
 * GetMiniumumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getMiniumumKinVersionWithRequest:(APBTransactionV4GetMiniumumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMiniumumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetMiniumumKinVersionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetMiniumumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetMiniumumKinVersionWithRequest:(APBTransactionV4GetMiniumumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMiniumumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetMiniumumKinVersion"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetMiniumumKinVersionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetMiniumumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 */
- (GRPCUnaryProtoCall *)getMiniumumKinVersionWithMessage:(APBTransactionV4GetMiniumumKinVersionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetMiniumumKinVersion"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetMiniumumKinVersionResponse class]];
}

#pragma mark GetRecentBlockHash(GetRecentBlockHashRequest) returns (GetRecentBlockHashResponse)

/**
 * GetRecentBlockHash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails, it
 * is recommended that a new block hash is retrieved.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getRecentBlockHashWithRequest:(APBTransactionV4GetRecentBlockHashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockHashResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetRecentBlockHashWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetRecentBlockHash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails, it
 * is recommended that a new block hash is retrieved.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetRecentBlockHashWithRequest:(APBTransactionV4GetRecentBlockHashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockHashResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetRecentBlockHash"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetRecentBlockHashResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetRecentBlockHash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails, it
 * is recommended that a new block hash is retrieved.
 */
- (GRPCUnaryProtoCall *)getRecentBlockHashWithMessage:(APBTransactionV4GetRecentBlockHashRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetRecentBlockHash"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetRecentBlockHashResponse class]];
}

#pragma mark GetMinimumBalanceForRentExemption(GetMinimumBalanceForRentExemptionRequest) returns (GetMinimumBalanceForRentExemptionResponse)

/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getMinimumBalanceForRentExemptionWithRequest:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumBalanceForRentExemptionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetMinimumBalanceForRentExemptionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetMinimumBalanceForRentExemptionWithRequest:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumBalanceForRentExemptionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetMinimumBalanceForRentExemption"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetMinimumBalanceForRentExemptionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 */
- (GRPCUnaryProtoCall *)getMinimumBalanceForRentExemptionWithMessage:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetMinimumBalanceForRentExemption"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetMinimumBalanceForRentExemptionResponse class]];
}

#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getHistoryWithRequest:(APBTransactionV4GetHistoryRequest *)request handler:(void(^)(APBTransactionV4GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetHistoryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetHistoryWithRequest:(APBTransactionV4GetHistoryRequest *)request handler:(void(^)(APBTransactionV4GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetHistory"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetHistoryResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getHistoryWithMessage:(APBTransactionV4GetHistoryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetHistory"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetHistoryResponse class]];
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
- (void)submitTransactionWithRequest:(APBTransactionV4SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV4SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToSubmitTransactionWithRequest:(APBTransactionV4SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV4SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SubmitTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4SubmitTransactionResponse class]
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
- (GRPCUnaryProtoCall *)submitTransactionWithMessage:(APBTransactionV4SubmitTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"SubmitTransaction"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4SubmitTransactionResponse class]];
}

#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getTransactionWithRequest:(APBTransactionV4GetTransactionRequest *)request handler:(void(^)(APBTransactionV4GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetTransactionWithRequest:(APBTransactionV4GetTransactionRequest *)request handler:(void(^)(APBTransactionV4GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetTransactionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getTransactionWithMessage:(APBTransactionV4GetTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetTransaction"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetTransactionResponse class]];
}

@end
#endif
