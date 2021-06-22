#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "TransactionServiceV3.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class APBTransactionV3GetHistoryRequest;
@class APBTransactionV3GetHistoryResponse;
@class APBTransactionV3GetTransactionRequest;
@class APBTransactionV3GetTransactionResponse;
@class APBTransactionV3SubmitTransactionRequest;
@class APBTransactionV3SubmitTransactionResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  #import "Validate.pbobjc.h"
  #import "ModelV3.pbobjc.h"
#endif

@class GRPCUnaryProtoCall;
@class GRPCStreamingProtoCall;
@class GRPCCallOptions;
@protocol GRPCProtoResponseHandler;
@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol APBTransactionV3Transaction2 <NSObject>

#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getHistoryWithMessage:(APBTransactionV3GetHistoryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

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
 */
- (GRPCUnaryProtoCall *)submitTransactionWithMessage:(APBTransactionV3SubmitTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getTransactionWithMessage:(APBTransactionV3GetTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

/**
 * The methods in this protocol belong to a set of old APIs that have been deprecated. They do not
 * recognize call options provided in the initializer. Using the v2 protocol is recommended.
 */
@protocol APBTransactionV3Transaction <NSObject>

#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getHistoryWithRequest:(APBTransactionV3GetHistoryRequest *)request handler:(void(^)(APBTransactionV3GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetHistoryWithRequest:(APBTransactionV3GetHistoryRequest *)request handler:(void(^)(APBTransactionV3GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)submitTransactionWithRequest:(APBTransactionV3SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV3SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler;

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
- (GRPCProtoCall *)RPCToSubmitTransactionWithRequest:(APBTransactionV3SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV3SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getTransactionWithRequest:(APBTransactionV3GetTransactionRequest *)request handler:(void(^)(APBTransactionV3GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetTransaction returns a transaction and additional off-chain
 * invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetTransactionWithRequest:(APBTransactionV3GetTransactionRequest *)request handler:(void(^)(APBTransactionV3GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface APBTransactionV3Transaction : GRPCProtoService<APBTransactionV3Transaction2, APBTransactionV3Transaction>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
// The following methods belong to a set of old APIs that have been deprecated.
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

