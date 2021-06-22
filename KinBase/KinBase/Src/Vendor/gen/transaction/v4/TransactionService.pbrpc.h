#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "TransactionService.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class APBTransactionV4GetHistoryRequest;
@class APBTransactionV4GetHistoryResponse;
@class APBTransactionV4GetMinimumBalanceForRentExemptionRequest;
@class APBTransactionV4GetMinimumBalanceForRentExemptionResponse;
@class APBTransactionV4GetMinimumKinVersionRequest;
@class APBTransactionV4GetMinimumKinVersionResponse;
@class APBTransactionV4GetRecentBlockhashRequest;
@class APBTransactionV4GetRecentBlockhashResponse;
@class APBTransactionV4GetServiceConfigRequest;
@class APBTransactionV4GetServiceConfigResponse;
@class APBTransactionV4GetTransactionRequest;
@class APBTransactionV4GetTransactionResponse;
@class APBTransactionV4SignTransactionRequest;
@class APBTransactionV4SignTransactionResponse;
@class APBTransactionV4SubmitTransactionRequest;
@class APBTransactionV4SubmitTransactionResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#if defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS) && GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
  #import <protobuf/Timestamp.pbobjc.h>
#else
  #import "Timestamp.pbobjc.h"
#endif
  #import "Validate.pbobjc.h"
  #import "ModelV3.pbobjc.h"
  #import "ModelV4.pbobjc.h"
#endif

@class GRPCUnaryProtoCall;
@class GRPCStreamingProtoCall;
@class GRPCCallOptions;
@protocol GRPCProtoResponseHandler;
@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol APBTransactionV4Transaction2 <NSObject>

#pragma mark GetServiceConfig(GetServiceConfigRequest) returns (GetServiceConfigResponse)

/**
 * GetServiceConfig returns the service and token parameters for the token.
 * 
 * The subsidizer key returned may vary based on the 'app-index' header.
 */
- (GRPCUnaryProtoCall *)getServiceConfigWithMessage:(APBTransactionV4GetServiceConfigRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetMinimumKinVersion(GetMinimumKinVersionRequest) returns (GetMinimumKinVersionResponse)

/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 */
- (GRPCUnaryProtoCall *)getMinimumKinVersionWithMessage:(APBTransactionV4GetMinimumKinVersionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetRecentBlockhash(GetRecentBlockhashRequest) returns (GetRecentBlockhashResponse)

/**
 * GetRecentBlockhash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails with
 * DuplicateSignature or InvalidNonce, it is recommended that a new block hash
 * is retrieved.
 * 
 * Block hashes are expected to be valid for ~2 minutes.
 */
- (GRPCUnaryProtoCall *)getRecentBlockhashWithMessage:(APBTransactionV4GetRecentBlockhashRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetMinimumBalanceForRentExemption(GetMinimumBalanceForRentExemptionRequest) returns (GetMinimumBalanceForRentExemptionResponse)

/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 */
- (GRPCUnaryProtoCall *)getMinimumBalanceForRentExemptionWithMessage:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getHistoryWithMessage:(APBTransactionV4GetHistoryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark SignTransaction(SignTransactionRequest) returns (SignTransactionResponse)

/**
 * SignTransaction signs the provided transaction, returning the signature to be used.
 * 
 * The transaction may include the following types of instructions:
 * - SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * - SplToken::SetAuthority(CloseAuthority)
 * - SplToken::Transfer()
 * - SplToken::CloseAccount()
 * - Memo::Memo()
 * 
 * The transaction can be divided into one or more 'regions', which are delineated by
 * the memo instruction. Each instruction within a region is considered to be 'related to'
 * the memo at the beginning of the region. The first (or only) region may not have a memo.
 * For example, if there are instructions before the first memo instruction, or if there
 * is no memo at all.
 * 
 * If an invoice is applied, there must be a memo whose foreign key contains the SHA-226
 * of the serialized memo. Additionally, the number of SplToken::Transfer instructions in
 * the region _must_ match the number of invoices. Furthermore, the invoice cannot be
 * referenced by more than one region.
 * 
 * Examples:
 * 
 * Basic Transfer (No Invoice)
 * 1. SplToken::Transfer()
 * 
 * Basic Transfer (Invoice)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer()
 * 
 * Transfer with Cleanup (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(GC) [Optional, 'memoless' region is ok]
 * 2. SplToken::Transfer(B -> A)
 * 3. SplToken::CloseAccount(B)
 * 4. Memo::Memo(Spend)
 * 5. SplToken::Transfer(A -> C)
 * 
 * Transfer with Cleanup At End (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer(A -> C)
 * 3. Memo::Memo(GC) [Required, delineate cleanup region from above]
 * 4. SplToken::Transfer(B -> A)
 * 5. SplToken::CloseAccount(B)
 * 
 * Sender Creates Destination (No Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 2. SplToken::Transfer()
 * 
 * Sender Creates Destination (Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 3. Memo::Memo(Earn)
 * 4. SplToken::Transfer()
 */
- (GRPCUnaryProtoCall *)signTransactionWithMessage:(APBTransactionV4SignTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark SubmitTransaction(SubmitTransactionRequest) returns (SubmitTransactionResponse)

/**
 * SubmitTransaction submits a transaction.
 * 
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
 */
- (GRPCUnaryProtoCall *)submitTransactionWithMessage:(APBTransactionV4SubmitTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
 */
- (GRPCUnaryProtoCall *)getTransactionWithMessage:(APBTransactionV4GetTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

/**
 * The methods in this protocol belong to a set of old APIs that have been deprecated. They do not
 * recognize call options provided in the initializer. Using the v2 protocol is recommended.
 */
@protocol APBTransactionV4Transaction <NSObject>

#pragma mark GetServiceConfig(GetServiceConfigRequest) returns (GetServiceConfigResponse)

/**
 * GetServiceConfig returns the service and token parameters for the token.
 * 
 * The subsidizer key returned may vary based on the 'app-index' header.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getServiceConfigWithRequest:(APBTransactionV4GetServiceConfigRequest *)request handler:(void(^)(APBTransactionV4GetServiceConfigResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetServiceConfig returns the service and token parameters for the token.
 * 
 * The subsidizer key returned may vary based on the 'app-index' header.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetServiceConfigWithRequest:(APBTransactionV4GetServiceConfigRequest *)request handler:(void(^)(APBTransactionV4GetServiceConfigResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetMinimumKinVersion(GetMinimumKinVersionRequest) returns (GetMinimumKinVersionResponse)

/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getMinimumKinVersionWithRequest:(APBTransactionV4GetMinimumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetMinimumKinVersionWithRequest:(APBTransactionV4GetMinimumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetRecentBlockhash(GetRecentBlockhashRequest) returns (GetRecentBlockhashResponse)

/**
 * GetRecentBlockhash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails with
 * DuplicateSignature or InvalidNonce, it is recommended that a new block hash
 * is retrieved.
 * 
 * Block hashes are expected to be valid for ~2 minutes.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getRecentBlockhashWithRequest:(APBTransactionV4GetRecentBlockhashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockhashResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetRecentBlockhash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails with
 * DuplicateSignature or InvalidNonce, it is recommended that a new block hash
 * is retrieved.
 * 
 * Block hashes are expected to be valid for ~2 minutes.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetRecentBlockhashWithRequest:(APBTransactionV4GetRecentBlockhashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockhashResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetMinimumBalanceForRentExemption(GetMinimumBalanceForRentExemptionRequest) returns (GetMinimumBalanceForRentExemptionResponse)

/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getMinimumBalanceForRentExemptionWithRequest:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumBalanceForRentExemptionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetMinimumBalanceForRentExemption returns the minimum amount of lamports that
 * must be in an account for it not to be garbage collected.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetMinimumBalanceForRentExemptionWithRequest:(APBTransactionV4GetMinimumBalanceForRentExemptionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumBalanceForRentExemptionResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetHistory(GetHistoryRequest) returns (GetHistoryResponse)

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getHistoryWithRequest:(APBTransactionV4GetHistoryRequest *)request handler:(void(^)(APBTransactionV4GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetHistory returns the transaction history for an account,
 * with additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetHistoryWithRequest:(APBTransactionV4GetHistoryRequest *)request handler:(void(^)(APBTransactionV4GetHistoryResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SignTransaction(SignTransactionRequest) returns (SignTransactionResponse)

/**
 * SignTransaction signs the provided transaction, returning the signature to be used.
 * 
 * The transaction may include the following types of instructions:
 * - SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * - SplToken::SetAuthority(CloseAuthority)
 * - SplToken::Transfer()
 * - SplToken::CloseAccount()
 * - Memo::Memo()
 * 
 * The transaction can be divided into one or more 'regions', which are delineated by
 * the memo instruction. Each instruction within a region is considered to be 'related to'
 * the memo at the beginning of the region. The first (or only) region may not have a memo.
 * For example, if there are instructions before the first memo instruction, or if there
 * is no memo at all.
 * 
 * If an invoice is applied, there must be a memo whose foreign key contains the SHA-226
 * of the serialized memo. Additionally, the number of SplToken::Transfer instructions in
 * the region _must_ match the number of invoices. Furthermore, the invoice cannot be
 * referenced by more than one region.
 * 
 * Examples:
 * 
 * Basic Transfer (No Invoice)
 * 1. SplToken::Transfer()
 * 
 * Basic Transfer (Invoice)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer()
 * 
 * Transfer with Cleanup (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(GC) [Optional, 'memoless' region is ok]
 * 2. SplToken::Transfer(B -> A)
 * 3. SplToken::CloseAccount(B)
 * 4. Memo::Memo(Spend)
 * 5. SplToken::Transfer(A -> C)
 * 
 * Transfer with Cleanup At End (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer(A -> C)
 * 3. Memo::Memo(GC) [Required, delineate cleanup region from above]
 * 4. SplToken::Transfer(B -> A)
 * 5. SplToken::CloseAccount(B)
 * 
 * Sender Creates Destination (No Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 2. SplToken::Transfer()
 * 
 * Sender Creates Destination (Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 3. Memo::Memo(Earn)
 * 4. SplToken::Transfer()
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)signTransactionWithRequest:(APBTransactionV4SignTransactionRequest *)request handler:(void(^)(APBTransactionV4SignTransactionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * SignTransaction signs the provided transaction, returning the signature to be used.
 * 
 * The transaction may include the following types of instructions:
 * - SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * - SplToken::SetAuthority(CloseAuthority)
 * - SplToken::Transfer()
 * - SplToken::CloseAccount()
 * - Memo::Memo()
 * 
 * The transaction can be divided into one or more 'regions', which are delineated by
 * the memo instruction. Each instruction within a region is considered to be 'related to'
 * the memo at the beginning of the region. The first (or only) region may not have a memo.
 * For example, if there are instructions before the first memo instruction, or if there
 * is no memo at all.
 * 
 * If an invoice is applied, there must be a memo whose foreign key contains the SHA-226
 * of the serialized memo. Additionally, the number of SplToken::Transfer instructions in
 * the region _must_ match the number of invoices. Furthermore, the invoice cannot be
 * referenced by more than one region.
 * 
 * Examples:
 * 
 * Basic Transfer (No Invoice)
 * 1. SplToken::Transfer()
 * 
 * Basic Transfer (Invoice)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer()
 * 
 * Transfer with Cleanup (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(GC) [Optional, 'memoless' region is ok]
 * 2. SplToken::Transfer(B -> A)
 * 3. SplToken::CloseAccount(B)
 * 4. Memo::Memo(Spend)
 * 5. SplToken::Transfer(A -> C)
 * 
 * Transfer with Cleanup At End (Sender has token accounts A, B, sending to C)
 * 1. Memo::Memo(Spend)
 * 2. SplToken::Transfer(A -> C)
 * 3. Memo::Memo(GC) [Required, delineate cleanup region from above]
 * 4. SplToken::Transfer(B -> A)
 * 5. SplToken::CloseAccount(B)
 * 
 * Sender Creates Destination (No Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 2. SplToken::Transfer()
 * 
 * Sender Creates Destination (Invoice)
 * 1. SplAssociateTokenAccount::CreateAssociatedTokenAccount()
 * 2. SplToken::SetAuthority(CloseAuthority)
 * 3. Memo::Memo(Earn)
 * 4. SplToken::Transfer()
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToSignTransactionWithRequest:(APBTransactionV4SignTransactionRequest *)request handler:(void(^)(APBTransactionV4SignTransactionResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubmitTransaction(SubmitTransactionRequest) returns (SubmitTransactionResponse)

/**
 * SubmitTransaction submits a transaction.
 * 
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)submitTransactionWithRequest:(APBTransactionV4SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV4SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * SubmitTransaction submits a transaction.
 * 
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToSubmitTransactionWithRequest:(APBTransactionV4SubmitTransactionRequest *)request handler:(void(^)(APBTransactionV4SubmitTransactionResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetTransaction(GetTransactionRequest) returns (GetTransactionResponse)

/**
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getTransactionWithRequest:(APBTransactionV4GetTransactionRequest *)request handler:(void(^)(APBTransactionV4GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetTransactionWithRequest:(APBTransactionV4GetTransactionRequest *)request handler:(void(^)(APBTransactionV4GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface APBTransactionV4Transaction : GRPCProtoService<APBTransactionV4Transaction2, APBTransactionV4Transaction>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
// The following methods belong to a set of old APIs that have been deprecated.
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

