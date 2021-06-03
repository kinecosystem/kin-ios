#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "AccountService.pbrpc.h"
#import "AccountService.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "Validate.pbobjc.h"
#import "ModelV4.pbobjc.h"

@implementation APBAccountV4Account

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"kin.agora.account.v4"
                 serviceName:@"Account"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"kin.agora.account.v4"
                 serviceName:@"Account"];
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

#pragma mark CreateAccount(CreateAccountRequest) returns (CreateAccountResponse)

/**
 * CreateAccount creates a kin token account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)createAccountWithRequest:(APBAccountV4CreateAccountRequest *)request handler:(void(^)(APBAccountV4CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToCreateAccountWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * CreateAccount creates a kin token account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToCreateAccountWithRequest:(APBAccountV4CreateAccountRequest *)request handler:(void(^)(APBAccountV4CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"CreateAccount"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV4CreateAccountResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * CreateAccount creates a kin token account.
 */
- (GRPCUnaryProtoCall *)createAccountWithMessage:(APBAccountV4CreateAccountRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"CreateAccount"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV4CreateAccountResponse class]];
}

#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getAccountInfoWithRequest:(APBAccountV4GetAccountInfoRequest *)request handler:(void(^)(APBAccountV4GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetAccountInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetAccountInfoWithRequest:(APBAccountV4GetAccountInfoRequest *)request handler:(void(^)(APBAccountV4GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetAccountInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV4GetAccountInfoResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetAccountInfo returns the information of a specified account.
 */
- (GRPCUnaryProtoCall *)getAccountInfoWithMessage:(APBAccountV4GetAccountInfoRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetAccountInfo"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV4GetAccountInfoResponse class]];
}

#pragma mark ResolveTokenAccounts(ResolveTokenAccountsRequest) returns (ResolveTokenAccountsResponse)

/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)resolveTokenAccountsWithRequest:(APBAccountV4ResolveTokenAccountsRequest *)request handler:(void(^)(APBAccountV4ResolveTokenAccountsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToResolveTokenAccountsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToResolveTokenAccountsWithRequest:(APBAccountV4ResolveTokenAccountsRequest *)request handler:(void(^)(APBAccountV4ResolveTokenAccountsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ResolveTokenAccounts"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV4ResolveTokenAccountsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * ResolveTokenAccounts resolves a set of Token Accounts owned by the specified account ID.
 */
- (GRPCUnaryProtoCall *)resolveTokenAccountsWithMessage:(APBAccountV4ResolveTokenAccountsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"ResolveTokenAccounts"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV4ResolveTokenAccountsResponse class]];
}

#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getEventsWithRequest:(APBAccountV4GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV4Events *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToGetEventsWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetEventsWithRequest:(APBAccountV4GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV4Events *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"GetEvents"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV4Events class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 */
- (GRPCUnaryProtoCall *)getEventsWithMessage:(APBAccountV4GetEventsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetEvents"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV4Events class]];
}

@end
#endif
