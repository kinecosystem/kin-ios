#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "AccountServiceV3.pbrpc.h"
#import "AccountServiceV3.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "Validate.pbobjc.h"
#import "ModelV3.pbobjc.h"

@implementation APBAccountV3Account

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"kin.agora.account.v3"
                 serviceName:@"Account"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"kin.agora.account.v3"
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
 * CreateAccount creates an account using a the service's configured seed
 * account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)createAccountWithRequest:(APBAccountV3CreateAccountRequest *)request handler:(void(^)(APBAccountV3CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToCreateAccountWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * CreateAccount creates an account using a the service's configured seed
 * account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToCreateAccountWithRequest:(APBAccountV3CreateAccountRequest *)request handler:(void(^)(APBAccountV3CreateAccountResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"CreateAccount"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV3CreateAccountResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * CreateAccount creates an account using a the service's configured seed
 * account.
 */
- (GRPCUnaryProtoCall *)createAccountWithMessage:(APBAccountV3CreateAccountRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"CreateAccount"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV3CreateAccountResponse class]];
}

#pragma mark GetAccountInfo(GetAccountInfoRequest) returns (GetAccountInfoResponse)

/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getAccountInfoWithRequest:(APBAccountV3GetAccountInfoRequest *)request handler:(void(^)(APBAccountV3GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetAccountInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetAccountInfo returns the information of a specified account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetAccountInfoWithRequest:(APBAccountV3GetAccountInfoRequest *)request handler:(void(^)(APBAccountV3GetAccountInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetAccountInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV3GetAccountInfoResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetAccountInfo returns the information of a specified account.
 */
- (GRPCUnaryProtoCall *)getAccountInfoWithMessage:(APBAccountV3GetAccountInfoRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetAccountInfo"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV3GetAccountInfoResponse class]];
}

#pragma mark GetEvents(GetEventsRequest) returns (stream Events)

/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getEventsWithRequest:(APBAccountV3GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV3Events *_Nullable response, NSError *_Nullable error))eventHandler{
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
- (GRPCProtoCall *)RPCToGetEventsWithRequest:(APBAccountV3GetEventsRequest *)request eventHandler:(void(^)(BOOL done, APBAccountV3Events *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"GetEvents"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAccountV3Events class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
/**
 * GetEvents returns a stream of events related to the specified account.
 * 
 * Note: Only events occurring after stream initiation will be returned.
 */
- (GRPCUnaryProtoCall *)getEventsWithMessage:(APBAccountV3GetEventsRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetEvents"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAccountV3Events class]];
}

@end
#endif
