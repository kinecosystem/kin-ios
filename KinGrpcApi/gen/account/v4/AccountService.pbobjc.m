// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: account/v4/account_service.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "AccountService.pbobjc.h"
#import "Validate.pbobjc.h"
#import "ModelV4.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

#pragma mark - APBAccountV4AccountServiceRoot

@implementation APBAccountV4AccountServiceRoot

+ (GPBExtensionRegistry*)extensionRegistry {
  // This is called by +initialize so there is no need to worry
  // about thread safety and initialization of registry.
  static GPBExtensionRegistry* registry = nil;
  if (!registry) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    registry = [[GPBExtensionRegistry alloc] init];
    // Merge in the imports (direct or indirect) that defined extensions.
    [registry addExtensions:[ValidateRoot extensionRegistry]];
  }
  return registry;
}

@end

#pragma mark - APBAccountV4AccountServiceRoot_FileDescriptor

static GPBFileDescriptor *APBAccountV4AccountServiceRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"kin.agora.account.v4"
                                                 objcPrefix:@"APBAccountV4"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - APBAccountV4AccountInfo

@implementation APBAccountV4AccountInfo

@dynamic hasAccountId, accountId;
@dynamic balance;
@dynamic hasOwner, owner;
@dynamic hasCloseAuthority, closeAuthority;

typedef struct APBAccountV4AccountInfo__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4SolanaAccountId *accountId;
  APBCommonV4SolanaAccountId *owner;
  APBCommonV4SolanaAccountId *closeAuthority;
  int64_t balance;
} APBAccountV4AccountInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountId",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4AccountInfo_FieldNumber_AccountId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4AccountInfo__storage_, accountId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "balance",
        .dataTypeSpecific.className = NULL,
        .number = APBAccountV4AccountInfo_FieldNumber_Balance,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4AccountInfo__storage_, balance),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "owner",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4AccountInfo_FieldNumber_Owner,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(APBAccountV4AccountInfo__storage_, owner),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "closeAuthority",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4AccountInfo_FieldNumber_CloseAuthority,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(APBAccountV4AccountInfo__storage_, closeAuthority),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4AccountInfo class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4AccountInfo__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - APBAccountV4CreateAccountRequest

@implementation APBAccountV4CreateAccountRequest

@dynamic hasTransaction, transaction;
@dynamic commitment;

typedef struct APBAccountV4CreateAccountRequest__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4Commitment commitment;
  APBCommonV4Transaction *transaction;
} APBAccountV4CreateAccountRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "transaction",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4Transaction),
        .number = APBAccountV4CreateAccountRequest_FieldNumber_Transaction,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4CreateAccountRequest__storage_, transaction),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "commitment",
        .dataTypeSpecific.enumDescFunc = APBCommonV4Commitment_EnumDescriptor,
        .number = APBAccountV4CreateAccountRequest_FieldNumber_Commitment,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4CreateAccountRequest__storage_, commitment),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4CreateAccountRequest class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4CreateAccountRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t APBAccountV4CreateAccountRequest_Commitment_RawValue(APBAccountV4CreateAccountRequest *message) {
  GPBDescriptor *descriptor = [APBAccountV4CreateAccountRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4CreateAccountRequest_FieldNumber_Commitment];
  return GPBGetMessageInt32Field(message, field);
}

void SetAPBAccountV4CreateAccountRequest_Commitment_RawValue(APBAccountV4CreateAccountRequest *message, int32_t value) {
  GPBDescriptor *descriptor = [APBAccountV4CreateAccountRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4CreateAccountRequest_FieldNumber_Commitment];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - APBAccountV4CreateAccountResponse

@implementation APBAccountV4CreateAccountResponse

@dynamic result;
@dynamic hasAccountInfo, accountInfo;

typedef struct APBAccountV4CreateAccountResponse__storage_ {
  uint32_t _has_storage_[1];
  APBAccountV4CreateAccountResponse_Result result;
  APBAccountV4AccountInfo *accountInfo;
} APBAccountV4CreateAccountResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.enumDescFunc = APBAccountV4CreateAccountResponse_Result_EnumDescriptor,
        .number = APBAccountV4CreateAccountResponse_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4CreateAccountResponse__storage_, result),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "accountInfo",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4AccountInfo),
        .number = APBAccountV4CreateAccountResponse_FieldNumber_AccountInfo,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4CreateAccountResponse__storage_, accountInfo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4CreateAccountResponse class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4CreateAccountResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t APBAccountV4CreateAccountResponse_Result_RawValue(APBAccountV4CreateAccountResponse *message) {
  GPBDescriptor *descriptor = [APBAccountV4CreateAccountResponse descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4CreateAccountResponse_FieldNumber_Result];
  return GPBGetMessageInt32Field(message, field);
}

void SetAPBAccountV4CreateAccountResponse_Result_RawValue(APBAccountV4CreateAccountResponse *message, int32_t value) {
  GPBDescriptor *descriptor = [APBAccountV4CreateAccountResponse descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4CreateAccountResponse_FieldNumber_Result];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - Enum APBAccountV4CreateAccountResponse_Result

GPBEnumDescriptor *APBAccountV4CreateAccountResponse_Result_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Ok\000Exists\000PayerRequired\000BadNonce\000";
    static const int32_t values[] = {
        APBAccountV4CreateAccountResponse_Result_Ok,
        APBAccountV4CreateAccountResponse_Result_Exists,
        APBAccountV4CreateAccountResponse_Result_PayerRequired,
        APBAccountV4CreateAccountResponse_Result_BadNonce,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(APBAccountV4CreateAccountResponse_Result)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:APBAccountV4CreateAccountResponse_Result_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL APBAccountV4CreateAccountResponse_Result_IsValidValue(int32_t value__) {
  switch (value__) {
    case APBAccountV4CreateAccountResponse_Result_Ok:
    case APBAccountV4CreateAccountResponse_Result_Exists:
    case APBAccountV4CreateAccountResponse_Result_PayerRequired:
    case APBAccountV4CreateAccountResponse_Result_BadNonce:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - APBAccountV4GetAccountInfoRequest

@implementation APBAccountV4GetAccountInfoRequest

@dynamic hasAccountId, accountId;
@dynamic commitment;

typedef struct APBAccountV4GetAccountInfoRequest__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4Commitment commitment;
  APBCommonV4SolanaAccountId *accountId;
} APBAccountV4GetAccountInfoRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountId",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4GetAccountInfoRequest_FieldNumber_AccountId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4GetAccountInfoRequest__storage_, accountId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "commitment",
        .dataTypeSpecific.enumDescFunc = APBCommonV4Commitment_EnumDescriptor,
        .number = APBAccountV4GetAccountInfoRequest_FieldNumber_Commitment,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4GetAccountInfoRequest__storage_, commitment),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4GetAccountInfoRequest class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4GetAccountInfoRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t APBAccountV4GetAccountInfoRequest_Commitment_RawValue(APBAccountV4GetAccountInfoRequest *message) {
  GPBDescriptor *descriptor = [APBAccountV4GetAccountInfoRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4GetAccountInfoRequest_FieldNumber_Commitment];
  return GPBGetMessageInt32Field(message, field);
}

void SetAPBAccountV4GetAccountInfoRequest_Commitment_RawValue(APBAccountV4GetAccountInfoRequest *message, int32_t value) {
  GPBDescriptor *descriptor = [APBAccountV4GetAccountInfoRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4GetAccountInfoRequest_FieldNumber_Commitment];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - APBAccountV4GetAccountInfoResponse

@implementation APBAccountV4GetAccountInfoResponse

@dynamic result;
@dynamic hasAccountInfo, accountInfo;

typedef struct APBAccountV4GetAccountInfoResponse__storage_ {
  uint32_t _has_storage_[1];
  APBAccountV4GetAccountInfoResponse_Result result;
  APBAccountV4AccountInfo *accountInfo;
} APBAccountV4GetAccountInfoResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.enumDescFunc = APBAccountV4GetAccountInfoResponse_Result_EnumDescriptor,
        .number = APBAccountV4GetAccountInfoResponse_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4GetAccountInfoResponse__storage_, result),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "accountInfo",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4AccountInfo),
        .number = APBAccountV4GetAccountInfoResponse_FieldNumber_AccountInfo,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4GetAccountInfoResponse__storage_, accountInfo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4GetAccountInfoResponse class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4GetAccountInfoResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t APBAccountV4GetAccountInfoResponse_Result_RawValue(APBAccountV4GetAccountInfoResponse *message) {
  GPBDescriptor *descriptor = [APBAccountV4GetAccountInfoResponse descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4GetAccountInfoResponse_FieldNumber_Result];
  return GPBGetMessageInt32Field(message, field);
}

void SetAPBAccountV4GetAccountInfoResponse_Result_RawValue(APBAccountV4GetAccountInfoResponse *message, int32_t value) {
  GPBDescriptor *descriptor = [APBAccountV4GetAccountInfoResponse descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4GetAccountInfoResponse_FieldNumber_Result];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - Enum APBAccountV4GetAccountInfoResponse_Result

GPBEnumDescriptor *APBAccountV4GetAccountInfoResponse_Result_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Ok\000NotFound\000";
    static const int32_t values[] = {
        APBAccountV4GetAccountInfoResponse_Result_Ok,
        APBAccountV4GetAccountInfoResponse_Result_NotFound,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(APBAccountV4GetAccountInfoResponse_Result)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:APBAccountV4GetAccountInfoResponse_Result_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL APBAccountV4GetAccountInfoResponse_Result_IsValidValue(int32_t value__) {
  switch (value__) {
    case APBAccountV4GetAccountInfoResponse_Result_Ok:
    case APBAccountV4GetAccountInfoResponse_Result_NotFound:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - APBAccountV4ResolveTokenAccountsRequest

@implementation APBAccountV4ResolveTokenAccountsRequest

@dynamic hasAccountId, accountId;
@dynamic includeAccountInfo;

typedef struct APBAccountV4ResolveTokenAccountsRequest__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4SolanaAccountId *accountId;
} APBAccountV4ResolveTokenAccountsRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountId",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4ResolveTokenAccountsRequest_FieldNumber_AccountId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4ResolveTokenAccountsRequest__storage_, accountId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "includeAccountInfo",
        .dataTypeSpecific.className = NULL,
        .number = APBAccountV4ResolveTokenAccountsRequest_FieldNumber_IncludeAccountInfo,
        .hasIndex = 1,
        .offset = 2,  // Stored in _has_storage_ to save space.
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBool,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4ResolveTokenAccountsRequest class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4ResolveTokenAccountsRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - APBAccountV4ResolveTokenAccountsResponse

@implementation APBAccountV4ResolveTokenAccountsResponse

@dynamic tokenAccountsArray, tokenAccountsArray_Count;
@dynamic tokenAccountInfosArray, tokenAccountInfosArray_Count;

typedef struct APBAccountV4ResolveTokenAccountsResponse__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *tokenAccountsArray;
  NSMutableArray *tokenAccountInfosArray;
} APBAccountV4ResolveTokenAccountsResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "tokenAccountsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4ResolveTokenAccountsResponse_FieldNumber_TokenAccountsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(APBAccountV4ResolveTokenAccountsResponse__storage_, tokenAccountsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "tokenAccountInfosArray",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4AccountInfo),
        .number = APBAccountV4ResolveTokenAccountsResponse_FieldNumber_TokenAccountInfosArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(APBAccountV4ResolveTokenAccountsResponse__storage_, tokenAccountInfosArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4ResolveTokenAccountsResponse class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4ResolveTokenAccountsResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - APBAccountV4GetEventsRequest

@implementation APBAccountV4GetEventsRequest

@dynamic hasAccountId, accountId;

typedef struct APBAccountV4GetEventsRequest__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4SolanaAccountId *accountId;
} APBAccountV4GetEventsRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountId",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4SolanaAccountId),
        .number = APBAccountV4GetEventsRequest_FieldNumber_AccountId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4GetEventsRequest__storage_, accountId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4GetEventsRequest class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4GetEventsRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - APBAccountV4Events

@implementation APBAccountV4Events

@dynamic result;
@dynamic eventsArray, eventsArray_Count;

typedef struct APBAccountV4Events__storage_ {
  uint32_t _has_storage_[1];
  APBAccountV4Events_Result result;
  NSMutableArray *eventsArray;
} APBAccountV4Events__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "result",
        .dataTypeSpecific.enumDescFunc = APBAccountV4Events_Result_EnumDescriptor,
        .number = APBAccountV4Events_FieldNumber_Result,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4Events__storage_, result),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "eventsArray",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4Event),
        .number = APBAccountV4Events_FieldNumber_EventsArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(APBAccountV4Events__storage_, eventsArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4Events class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4Events__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t APBAccountV4Events_Result_RawValue(APBAccountV4Events *message) {
  GPBDescriptor *descriptor = [APBAccountV4Events descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4Events_FieldNumber_Result];
  return GPBGetMessageInt32Field(message, field);
}

void SetAPBAccountV4Events_Result_RawValue(APBAccountV4Events *message, int32_t value) {
  GPBDescriptor *descriptor = [APBAccountV4Events descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:APBAccountV4Events_FieldNumber_Result];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - Enum APBAccountV4Events_Result

GPBEnumDescriptor *APBAccountV4Events_Result_EnumDescriptor(void) {
  static _Atomic(GPBEnumDescriptor*) descriptor = nil;
  if (!descriptor) {
    static const char *valueNames =
        "Ok\000NotFound\000";
    static const int32_t values[] = {
        APBAccountV4Events_Result_Ok,
        APBAccountV4Events_Result_NotFound,
    };
    GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(APBAccountV4Events_Result)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:APBAccountV4Events_Result_IsValidValue];
    GPBEnumDescriptor *expected = nil;
    if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
      [worker release];
    }
  }
  return descriptor;
}

BOOL APBAccountV4Events_Result_IsValidValue(int32_t value__) {
  switch (value__) {
    case APBAccountV4Events_Result_Ok:
    case APBAccountV4Events_Result_NotFound:
      return YES;
    default:
      return NO;
  }
}

#pragma mark - APBAccountV4Event

@implementation APBAccountV4Event

@dynamic typeOneOfCase;
@dynamic accountUpdateEvent;
@dynamic transactionEvent;

typedef struct APBAccountV4Event__storage_ {
  uint32_t _has_storage_[2];
  APBAccountV4AccountUpdateEvent *accountUpdateEvent;
  APBAccountV4TransactionEvent *transactionEvent;
} APBAccountV4Event__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountUpdateEvent",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4AccountUpdateEvent),
        .number = APBAccountV4Event_FieldNumber_AccountUpdateEvent,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(APBAccountV4Event__storage_, accountUpdateEvent),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "transactionEvent",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4TransactionEvent),
        .number = APBAccountV4Event_FieldNumber_TransactionEvent,
        .hasIndex = -1,
        .offset = (uint32_t)offsetof(APBAccountV4Event__storage_, transactionEvent),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4Event class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4Event__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    static const char *oneofs[] = {
      "type",
    };
    [localDescriptor setupOneofs:oneofs
                           count:(uint32_t)(sizeof(oneofs) / sizeof(char*))
                   firstHasIndex:-1];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

void APBAccountV4Event_ClearTypeOneOfCase(APBAccountV4Event *message) {
  GPBDescriptor *descriptor = [message descriptor];
  GPBOneofDescriptor *oneof = [descriptor.oneofs objectAtIndex:0];
  GPBMaybeClearOneof(message, oneof, -1, 0);
}
#pragma mark - APBAccountV4AccountUpdateEvent

@implementation APBAccountV4AccountUpdateEvent

@dynamic hasAccountInfo, accountInfo;

typedef struct APBAccountV4AccountUpdateEvent__storage_ {
  uint32_t _has_storage_[1];
  APBAccountV4AccountInfo *accountInfo;
} APBAccountV4AccountUpdateEvent__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "accountInfo",
        .dataTypeSpecific.className = GPBStringifySymbol(APBAccountV4AccountInfo),
        .number = APBAccountV4AccountUpdateEvent_FieldNumber_AccountInfo,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4AccountUpdateEvent__storage_, accountInfo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4AccountUpdateEvent class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4AccountUpdateEvent__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - APBAccountV4TransactionEvent

@implementation APBAccountV4TransactionEvent

@dynamic hasTransaction, transaction;
@dynamic hasTransactionError, transactionError;

typedef struct APBAccountV4TransactionEvent__storage_ {
  uint32_t _has_storage_[1];
  APBCommonV4Transaction *transaction;
  APBCommonV4TransactionError *transactionError;
} APBAccountV4TransactionEvent__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "transaction",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4Transaction),
        .number = APBAccountV4TransactionEvent_FieldNumber_Transaction,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(APBAccountV4TransactionEvent__storage_, transaction),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "transactionError",
        .dataTypeSpecific.className = GPBStringifySymbol(APBCommonV4TransactionError),
        .number = APBAccountV4TransactionEvent_FieldNumber_TransactionError,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(APBAccountV4TransactionEvent__storage_, transactionError),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[APBAccountV4TransactionEvent class]
                                     rootClass:[APBAccountV4AccountServiceRoot class]
                                          file:APBAccountV4AccountServiceRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(APBAccountV4TransactionEvent__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
