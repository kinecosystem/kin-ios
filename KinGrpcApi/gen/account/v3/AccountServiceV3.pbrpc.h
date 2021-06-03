#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "AccountServiceV3.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class APBAccountV3CreateAccountRequest;
@class APBAccountV3CreateAccountResponse;
@class APBAccountV3Events;
@class APBAccountV3GetAccountInfoRequest;
@class APBAccountV3GetAccountInfoResponse;
@class APBAccountV3GetEventsRequest;

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

@protocol APBAccountV3Account2 <NSObject>

#pragma mark CreateAccount(CreateAccountRequest) returns (CreateAccountResponse)

/**
 * CreateAccount creates an account using a the service's configured seed
 * account.
 */
- (GRPCUnaryProtoCall *)createAccountWithMessage:(APBAccountV3CreateAccountRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 */
- (GRPCUnaryProtoCall *)getAccountInfoWithMessage:(APBAccountV3GetAccountInfoRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 */
- (GRPCUnaryProtoCall *)getEventsWithMessage:(APBAccountV3GetEventsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

/**
 * The methods in this protocol belong to a set of old APIs that have been deprecated. They do not
 * recognize call options provided in the initializer. Using the v2 protocol is recommended.
 */
@protocol APBAccountV3Account <NSObject>

#pragma mark CreateAccount(CreateAccountRequest) returns (CreateAccountResponse)

/**
 * CreateAccount creates an account using a the service's configured seed
 * account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)createAccountWithRequest:(APBAccountV3CreateAccountRequest *)request handler:(void(^)(APBAccountV3CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * CreateAccount creates an account using a the service's configured seed
 * account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToCreateAccountWithRequest:(APBAccountV3CreateAccountRequest *)request handler:(void(^)(APBAccountV3CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getAccountInfoWithRequest:(APBAccountV3GetAccountInfoRequest *)request handler:(void(^)(APBAccountV3GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetAccountInfoWithRequest:(APBAccountV3GetAccountInfoRequest *)request handler:(void(^)(APBAccountV3GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getEventsWithRequest:(APBAccountV3GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV3Events *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetEventsWithRequest:(APBAccountV3GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV3Events *_Nullable response, NSError *_Nullable error))eventHandler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface APBAccountV3Account : GRPCProtoService<APBAccountV3Account2, APBAccountV3Account>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
// The following methods belong to a set of old APIs that have been deprecated.
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

