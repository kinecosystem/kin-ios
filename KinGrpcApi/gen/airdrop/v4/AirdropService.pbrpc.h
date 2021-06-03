#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "AirdropService.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class APBAirdropV4RequestAirdropRequest;
@class APBAirdropV4RequestAirdropResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  #import "Validate.pbobjc.h"
  #import "ModelV4.pbobjc.h"
#endif

@class GRPCUnaryProtoCall;
@class GRPCStreamingProtoCall;
@class GRPCCallOptions;
@protocol GRPCProtoResponseHandler;
@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol APBAirdropV4Airdrop2 <NSObject>

#pragma mark RequestAirdrop(RequestAirdropRequest) returns (RequestAirdropResponse)

/**
 * RequestAirdrop requests an air drop of kin to the target account.
 */
- (GRPCUnaryProtoCall *)requestAirdropWithMessage:(APBAirdropV4RequestAirdropRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

/**
 * The methods in this protocol belong to a set of old APIs that have been deprecated. They do not
 * recognize call options provided in the initializer. Using the v2 protocol is recommended.
 */
@protocol APBAirdropV4Airdrop <NSObject>

#pragma mark RequestAirdrop(RequestAirdropRequest) returns (RequestAirdropResponse)

/**
 * RequestAirdrop requests an air drop of kin to the target account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)requestAirdropWithRequest:(APBAirdropV4RequestAirdropRequest *)request handler:(void(^)(APBAirdropV4RequestAirdropResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * RequestAirdrop requests an air drop of kin to the target account.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToRequestAirdropWithRequest:(APBAirdropV4RequestAirdropRequest *)request handler:(void(^)(APBAirdropV4RequestAirdropResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface APBAirdropV4Airdrop : GRPCProtoService<APBAirdropV4Airdrop2, APBAirdropV4Airdrop>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
// The following methods belong to a set of old APIs that have been deprecated.
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

