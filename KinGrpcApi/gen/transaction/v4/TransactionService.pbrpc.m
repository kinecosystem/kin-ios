#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "TransactionService.pbrpc.h"
#import "TransactionService.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#if defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS) && GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
#import <protobuf/Timestamp.pbobjc.h>
#else
#import "Timestamp.pbobjc.h"
#endif
#import "Validate.pbobjc.h"
#import "ModelV3.pbobjc.h"
#import "ModelV4.pbobjc.h"

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
 * The subsidizer key returned may vary based on the 'app-index' header.
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
 * The subsidizer key returned may vary based on the 'app-index' header.
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
 * 
 * The subsidizer key returned may vary based on the 'app-index' header.
 */
- (GRPCUnaryProtoCall *)getServiceConfigWithMessage:(APBTransactionV4GetServiceConfigRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetServiceConfig"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetServiceConfigResponse class]];
}

#pragma mark GetMinimumKinVersion(GetMinimumKinVersionRequest) returns (GetMinimumKinVersionResponse)

/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getMinimumKinVersionWithRequest:(APBTransactionV4GetMinimumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetMinimumKinVersionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetMinimumKinVersionWithRequest:(APBTransactionV4GetMinimumKinVersionRequest *)request handler:(void(^)(APBTransactionV4GetMinimumKinVersionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetMinimumKinVersion"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetMinimumKinVersionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetMinimumKinVersion returns the minimum Kin version that is supported.
 * 
 * This version will _never_ decrease in non-test scenarios, as it indicates
 * a global migration has occured.
 */
- (GRPCUnaryProtoCall *)getMinimumKinVersionWithMessage:(APBTransactionV4GetMinimumKinVersionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetMinimumKinVersion"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetMinimumKinVersionResponse class]];
}

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
- (void)getRecentBlockhashWithRequest:(APBTransactionV4GetRecentBlockhashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockhashResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetRecentBlockhashWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToGetRecentBlockhashWithRequest:(APBTransactionV4GetRecentBlockhashRequest *)request handler:(void(^)(APBTransactionV4GetRecentBlockhashResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetRecentBlockhash"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4GetRecentBlockhashResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * GetRecentBlockhash returns a recent block hash from the underlying network,
 * which should be used when crafting transactions. If a transaction fails with
 * DuplicateSignature or InvalidNonce, it is recommended that a new block hash
 * is retrieved.
 * 
 * Block hashes are expected to be valid for ~2 minutes.
 */
- (GRPCUnaryProtoCall *)getRecentBlockhashWithMessage:(APBTransactionV4GetRecentBlockhashRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetRecentBlockhash"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4GetRecentBlockhashResponse class]];
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
- (void)signTransactionWithRequest:(APBTransactionV4SignTransactionRequest *)request handler:(void(^)(APBTransactionV4SignTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSignTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToSignTransactionWithRequest:(APBTransactionV4SignTransactionRequest *)request handler:(void(^)(APBTransactionV4SignTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SignTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[APBTransactionV4SignTransactionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (GRPCUnaryProtoCall *)signTransactionWithMessage:(APBTransactionV4SignTransactionRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"SignTransaction"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[APBTransactionV4SignTransactionResponse class]];
}

#pragma mark SubmitTransaction(SubmitTransactionRequest) returns (SubmitTransactionResponse)

/**
 * SubmitTransaction submits a transaction.
 * 
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
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
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
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
 * If the transaction is already signed, the SignTransaction webhook will not
 * be called.
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
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getTransactionWithRequest:(APBTransactionV4GetTransactionRequest *)request handler:(void(^)(APBTransactionV4GetTransactionResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
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
 * GetTransaction returns a transaction and additional off-chain invoice data, if available.
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
