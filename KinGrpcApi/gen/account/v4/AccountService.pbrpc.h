#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "account/v4/AccountService.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class APBAccountV4CreateAccountRequest;
@class APBAccountV4CreateAccountResponse;
@class APBAccountV4Events;
@class APBAccountV4GetAccountInfoRequest;
@class APBAccountV4GetAccountInfoResponse;
@class APBAccountV4GetEventsRequest;
@class APBAccountV4ResolveTokenAccountsRequest;
@class APBAccountV4ResolveTokenAccountsResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  #import "validate/Validate.pbobjc.h"
  #import "common/v4/Model.pbobjc.h"
#endif

@class GRPCUnaryProtoCall;
@class GRPCStreamingProtoCall;
@class GRPCCallOptions;
@protocol GRPCProtoResponseHandler;
@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol APBAccountV4Account2 <NSObject>

#pragma mark CreateAccount(CreateAccountRequest) returns (CreateAccountResponse)

/**
 * CreateAccount creates a kin token account.
 */
- (GRPCUnaryProtoCall *)createAccountWithMessage:(APBAccountV4CreateAccountRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 */
- (GRPCUnaryProtoCall *)getAccountInfoWithMessage:(APBAccountV4GetAccountInfoRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark ResolveTokenAccounts(ResolveTokenAccountsRequest) returns (ResolveTokenAccountsResponse)

/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 */
- (GRPCUnaryProtoCall *)resolveTokenAccountsWithMessage:(APBAccountV4ResolveTokenAccountsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 */
- (GRPCUnaryProtoCall *)getEventsWithMessage:(APBAccountV4GetEventsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

/**
 * The methods in this protocol belong to a set of old APIs that have been deprecated. They do not
 * recognize call options provided in the initializer. Using the v2 protocol is recommended.
 */
@protocol APBAccountV4Account <NSObject>

#pragma mark CreateAccount(CreateAccountRequest) returns (CreateAccountResponse)

/**
 * CreateAccount creates a kin token account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)createAccountWithRequest:(APBAccountV4CreateAccountRequest *)request handler:(void(^)(APBAccountV4CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * CreateAccount creates a kin token account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToCreateAccountWithRequest:(APBAccountV4CreateAccountRequest *)request handler:(void(^)(APBAccountV4CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getAccountInfoWithRequest:(APBAccountV4GetAccountInfoRequest *)request handler:(void(^)(APBAccountV4GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetAccountInfoWithRequest:(APBAccountV4GetAccountInfoRequest *)request handler:(void(^)(APBAccountV4GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ResolveTokenAccounts(ResolveTokenAccountsRequest) returns (ResolveTokenAccountsResponse)

/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)resolveTokenAccountsWithRequest:(APBAccountV4ResolveTokenAccountsRequest *)request handler:(void(^)(APBAccountV4ResolveTokenAccountsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToResolveTokenAccountsWithRequest:(APBAccountV4ResolveTokenAccountsRequest *)request handler:(void(^)(APBAccountV4ResolveTokenAccountsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getEventsWithRequest:(APBAccountV4GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV4Events *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetEventsWithRequest:(APBAccountV4GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV4Events *_Nullable response, NSError *_Nullable error))eventHandler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface APBAccountV4Account : GRPCProtoService<APBAccountV4Account2, APBAccountV4Account>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
// The following methods belong to a set of old APIs that have been deprecated.
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

