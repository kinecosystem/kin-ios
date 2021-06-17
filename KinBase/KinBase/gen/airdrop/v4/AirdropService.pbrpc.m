#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "airdrop/v4/AirdropService.pbrpc.h"
#import "airdrop/v4/AirdropService.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "validate/Validate.pbobjc.h"
#import "common/v4/Model.pbobjc.h"

@implementation APBAirdropV4Airdrop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"kin.agora.airdrop.v4"
                 serviceName:@"Airdrop"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"kin.agora.airdrop.v4"
                 serviceName:@"Airdrop"];
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

#pragma mark RequestAirdrop(RequestAirdropRequest) returns (RequestAirdropResponse)

/**
 * RequestAirdrop requests an air drop of kin to the target account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)requestAirdropWithRequest:(APBAirdropV4RequestAirdropRequest *)request handler:(void(^)(APBAirdropV4RequestAirdropResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToRequestAirdropWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * RequestAirdrop requests an air drop of kin to the target account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToRequestAirdropWithRequest:(APBAirdropV4RequestAirdropRequest *)request handler:(void(^)(APBAirdropV4RequestAirdropResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"RequestAirdrop"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBAirdropV4RequestAirdropResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * RequestAirdrop requests an air drop of kin to the target account.
 */
- (GRPCUnaryProtoCall *)requestAirdropWithMessage:(APBAirdropV4RequestAirdropRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"RequestAirdrop"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBAirdropV4RequestAirdropResponse class]];
}

@end
#endif
