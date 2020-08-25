// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: account/v3/account_service.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class APBAccountV3AccountInfo;
@class APBAccountV3AccountUpdateEvent;
@class APBAccountV3Event;
@class APBAccountV3TransactionEvent;
@class APBCommonV3StellarAccountId;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum APBAccountV3CreateAccountResponse_Result

typedef GPB_ENUM(APBAccountV3CreateAccountResponse_Result) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  APBAccountV3CreateAccountResponse_Result_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  APBAccountV3CreateAccountResponse_Result_Ok = 0,
  APBAccountV3CreateAccountResponse_Result_Exists = 1,
};

GPBEnumDescriptor *APBAccountV3CreateAccountResponse_Result_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL APBAccountV3CreateAccountResponse_Result_IsValidValue(int32_t value);

#pragma mark - Enum APBAccountV3GetAccountInfoResponse_Result

typedef GPB_ENUM(APBAccountV3GetAccountInfoResponse_Result) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  APBAccountV3GetAccountInfoResponse_Result_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  APBAccountV3GetAccountInfoResponse_Result_Ok = 0,

  /** The specified account could not be found. */
  APBAccountV3GetAccountInfoResponse_Result_NotFound = 1,
};

GPBEnumDescriptor *APBAccountV3GetAccountInfoResponse_Result_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL APBAccountV3GetAccountInfoResponse_Result_IsValidValue(int32_t value);

#pragma mark - Enum APBAccountV3Events_Result

typedef GPB_ENUM(APBAccountV3Events_Result) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  APBAccountV3Events_Result_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  APBAccountV3Events_Result_Ok = 0,

  /** The specified account could not be found. */
  APBAccountV3Events_Result_NotFound = 1,
};

GPBEnumDescriptor *APBAccountV3Events_Result_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL APBAccountV3Events_Result_IsValidValue(int32_t value);

#pragma mark - APBAccountV3AccountServiceRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface APBAccountV3AccountServiceRoot : GPBRootObject
@end

#pragma mark - APBAccountV3AccountInfo

typedef GPB_ENUM(APBAccountV3AccountInfo_FieldNumber) {
  APBAccountV3AccountInfo_FieldNumber_AccountId = 1,
  APBAccountV3AccountInfo_FieldNumber_SequenceNumber = 2,
  APBAccountV3AccountInfo_FieldNumber_Balance = 3,
};

@interface APBAccountV3AccountInfo : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) APBCommonV3StellarAccountId *accountId;
/** Test to see if @c accountId has been set. */
@property(nonatomic, readwrite) BOOL hasAccountId;

/** The last known sequence number of the account. */
@property(nonatomic, readwrite) int64_t sequenceNumber;

/** The last known balance, in quarks, of the account. */
@property(nonatomic, readwrite) int64_t balance;

@end

#pragma mark - APBAccountV3CreateAccountRequest

typedef GPB_ENUM(APBAccountV3CreateAccountRequest_FieldNumber) {
  APBAccountV3CreateAccountRequest_FieldNumber_AccountId = 1,
};

@interface APBAccountV3CreateAccountRequest : GPBMessage

/** Account to be created */
@property(nonatomic, readwrite, strong, null_resettable) APBCommonV3StellarAccountId *accountId;
/** Test to see if @c accountId has been set. */
@property(nonatomic, readwrite) BOOL hasAccountId;

@end

#pragma mark - APBAccountV3CreateAccountResponse

typedef GPB_ENUM(APBAccountV3CreateAccountResponse_FieldNumber) {
  APBAccountV3CreateAccountResponse_FieldNumber_Result = 1,
  APBAccountV3CreateAccountResponse_FieldNumber_AccountInfo = 2,
};

@interface APBAccountV3CreateAccountResponse : GPBMessage

@property(nonatomic, readwrite) APBAccountV3CreateAccountResponse_Result result;

/** Will be present if the account was created or already existed. */
@property(nonatomic, readwrite, strong, null_resettable) APBAccountV3AccountInfo *accountInfo;
/** Test to see if @c accountInfo has been set. */
@property(nonatomic, readwrite) BOOL hasAccountInfo;

@end

/**
 * Fetches the raw value of a @c APBAccountV3CreateAccountResponse's @c result property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t APBAccountV3CreateAccountResponse_Result_RawValue(APBAccountV3CreateAccountResponse *message);
/**
 * Sets the raw value of an @c APBAccountV3CreateAccountResponse's @c result property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetAPBAccountV3CreateAccountResponse_Result_RawValue(APBAccountV3CreateAccountResponse *message, int32_t value);

#pragma mark - APBAccountV3GetAccountInfoRequest

typedef GPB_ENUM(APBAccountV3GetAccountInfoRequest_FieldNumber) {
  APBAccountV3GetAccountInfoRequest_FieldNumber_AccountId = 1,
};

@interface APBAccountV3GetAccountInfoRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) APBCommonV3StellarAccountId *accountId;
/** Test to see if @c accountId has been set. */
@property(nonatomic, readwrite) BOOL hasAccountId;

@end

#pragma mark - APBAccountV3GetAccountInfoResponse

typedef GPB_ENUM(APBAccountV3GetAccountInfoResponse_FieldNumber) {
  APBAccountV3GetAccountInfoResponse_FieldNumber_Result = 1,
  APBAccountV3GetAccountInfoResponse_FieldNumber_AccountInfo = 2,
};

@interface APBAccountV3GetAccountInfoResponse : GPBMessage

@property(nonatomic, readwrite) APBAccountV3GetAccountInfoResponse_Result result;

/** Present iff result == Result::OK */
@property(nonatomic, readwrite, strong, null_resettable) APBAccountV3AccountInfo *accountInfo;
/** Test to see if @c accountInfo has been set. */
@property(nonatomic, readwrite) BOOL hasAccountInfo;

@end

/**
 * Fetches the raw value of a @c APBAccountV3GetAccountInfoResponse's @c result property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t APBAccountV3GetAccountInfoResponse_Result_RawValue(APBAccountV3GetAccountInfoResponse *message);
/**
 * Sets the raw value of an @c APBAccountV3GetAccountInfoResponse's @c result property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetAPBAccountV3GetAccountInfoResponse_Result_RawValue(APBAccountV3GetAccountInfoResponse *message, int32_t value);

#pragma mark - APBAccountV3GetEventsRequest

typedef GPB_ENUM(APBAccountV3GetEventsRequest_FieldNumber) {
  APBAccountV3GetEventsRequest_FieldNumber_AccountId = 1,
};

@interface APBAccountV3GetEventsRequest : GPBMessage

/** The id of the account to stream events for */
@property(nonatomic, readwrite, strong, null_resettable) APBCommonV3StellarAccountId *accountId;
/** Test to see if @c accountId has been set. */
@property(nonatomic, readwrite) BOOL hasAccountId;

@end

#pragma mark - APBAccountV3Events

typedef GPB_ENUM(APBAccountV3Events_FieldNumber) {
  APBAccountV3Events_FieldNumber_Result = 1,
  APBAccountV3Events_FieldNumber_EventsArray = 2,
};

@interface APBAccountV3Events : GPBMessage

@property(nonatomic, readwrite) APBAccountV3Events_Result result;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<APBAccountV3Event*> *eventsArray;
/** The number of items in @c eventsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger eventsArray_Count;

@end

/**
 * Fetches the raw value of a @c APBAccountV3Events's @c result property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t APBAccountV3Events_Result_RawValue(APBAccountV3Events *message);
/**
 * Sets the raw value of an @c APBAccountV3Events's @c result property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetAPBAccountV3Events_Result_RawValue(APBAccountV3Events *message, int32_t value);

#pragma mark - APBAccountV3Event

typedef GPB_ENUM(APBAccountV3Event_FieldNumber) {
  APBAccountV3Event_FieldNumber_AccountUpdateEvent = 1,
  APBAccountV3Event_FieldNumber_TransactionEvent = 2,
};

typedef GPB_ENUM(APBAccountV3Event_Type_OneOfCase) {
  APBAccountV3Event_Type_OneOfCase_GPBUnsetOneOfCase = 0,
  APBAccountV3Event_Type_OneOfCase_AccountUpdateEvent = 1,
  APBAccountV3Event_Type_OneOfCase_TransactionEvent = 2,
};

@interface APBAccountV3Event : GPBMessage

@property(nonatomic, readonly) APBAccountV3Event_Type_OneOfCase typeOneOfCase;

@property(nonatomic, readwrite, strong, null_resettable) APBAccountV3AccountUpdateEvent *accountUpdateEvent;

@property(nonatomic, readwrite, strong, null_resettable) APBAccountV3TransactionEvent *transactionEvent;

@end

/**
 * Clears whatever value was set for the oneof 'type'.
 **/
void APBAccountV3Event_ClearTypeOneOfCase(APBAccountV3Event *message);

#pragma mark - APBAccountV3AccountUpdateEvent

typedef GPB_ENUM(APBAccountV3AccountUpdateEvent_FieldNumber) {
  APBAccountV3AccountUpdateEvent_FieldNumber_AccountInfo = 1,
};

/**
 * An event that gets sent when an account's information has changed.
 **/
@interface APBAccountV3AccountUpdateEvent : GPBMessage

/** The account information most recently obtained by the service. */
@property(nonatomic, readwrite, strong, null_resettable) APBAccountV3AccountInfo *accountInfo;
/** Test to see if @c accountInfo has been set. */
@property(nonatomic, readwrite) BOOL hasAccountInfo;

@end

#pragma mark - APBAccountV3TransactionEvent

typedef GPB_ENUM(APBAccountV3TransactionEvent_FieldNumber) {
  APBAccountV3TransactionEvent_FieldNumber_EnvelopeXdr = 1,
  APBAccountV3TransactionEvent_FieldNumber_ResultXdr = 2,
};

/**
 * An event that gets sent when a transaction related to an account has been
 * successfully submitted to the blockchain.
 **/
@interface APBAccountV3TransactionEvent : GPBMessage

/** The transaction envelope XDR. */
@property(nonatomic, readwrite, copy, null_resettable) NSData *envelopeXdr;

/** The transaction result XDR. */
@property(nonatomic, readwrite, copy, null_resettable) NSData *resultXdr;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
