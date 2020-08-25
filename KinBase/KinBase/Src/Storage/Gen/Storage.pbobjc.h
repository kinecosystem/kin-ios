// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: storage.proto

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

@class KinStorageInvoiceListBlob;
@class KinStorageKinBalance;
@class KinStorageKinTransaction;
@class KinStoragePrivateKey;
@class KinStoragePublicKey;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum KinStorageKinAccount_Status

typedef GPB_ENUM(KinStorageKinAccount_Status) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  KinStorageKinAccount_Status_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  KinStorageKinAccount_Status_Unregistered = 0,
  KinStorageKinAccount_Status_Registered = 1,
};

GPBEnumDescriptor *KinStorageKinAccount_Status_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL KinStorageKinAccount_Status_IsValidValue(int32_t value);

#pragma mark - Enum KinStorageKinTransaction_Status

typedef GPB_ENUM(KinStorageKinTransaction_Status) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  KinStorageKinTransaction_Status_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  KinStorageKinTransaction_Status_Unknown = 0,
  KinStorageKinTransaction_Status_Inflight = 1,
  KinStorageKinTransaction_Status_Acknowledged = 2,
  KinStorageKinTransaction_Status_Historical = 3,
};

GPBEnumDescriptor *KinStorageKinTransaction_Status_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL KinStorageKinTransaction_Status_IsValidValue(int32_t value);

#pragma mark - KinStorageStorageRoot

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
@interface KinStorageStorageRoot : GPBRootObject
@end

#pragma mark - KinStoragePrivateKey

typedef GPB_ENUM(KinStoragePrivateKey_FieldNumber) {
  KinStoragePrivateKey_FieldNumber_Value = 1,
};

@interface KinStoragePrivateKey : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *value;

@end

#pragma mark - KinStoragePublicKey

typedef GPB_ENUM(KinStoragePublicKey_FieldNumber) {
  KinStoragePublicKey_FieldNumber_Value = 1,
};

@interface KinStoragePublicKey : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *value;

@end

#pragma mark - KinStorageKinBalance

typedef GPB_ENUM(KinStorageKinBalance_FieldNumber) {
  KinStorageKinBalance_FieldNumber_QuarkAmount = 1,
  KinStorageKinBalance_FieldNumber_PendingQuarkAmount = 2,
};

@interface KinStorageKinBalance : GPBMessage

@property(nonatomic, readwrite) int64_t quarkAmount;

@property(nonatomic, readwrite) int64_t pendingQuarkAmount;

@end

#pragma mark - KinStorageKinAccount

typedef GPB_ENUM(KinStorageKinAccount_FieldNumber) {
  KinStorageKinAccount_FieldNumber_PublicKey = 1,
  KinStorageKinAccount_FieldNumber_PrivateKey = 2,
  KinStorageKinAccount_FieldNumber_Balance = 3,
  KinStorageKinAccount_FieldNumber_Status = 4,
  KinStorageKinAccount_FieldNumber_SequenceNumber = 5,
};

@interface KinStorageKinAccount : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) KinStoragePublicKey *publicKey;
/** Test to see if @c publicKey has been set. */
@property(nonatomic, readwrite) BOOL hasPublicKey;

@property(nonatomic, readwrite, strong, null_resettable) KinStoragePrivateKey *privateKey;
/** Test to see if @c privateKey has been set. */
@property(nonatomic, readwrite) BOOL hasPrivateKey;

@property(nonatomic, readwrite, strong, null_resettable) KinStorageKinBalance *balance;
/** Test to see if @c balance has been set. */
@property(nonatomic, readwrite) BOOL hasBalance;

@property(nonatomic, readwrite) KinStorageKinAccount_Status status;

@property(nonatomic, readwrite) int64_t sequenceNumber;

@end

/**
 * Fetches the raw value of a @c KinStorageKinAccount's @c status property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t KinStorageKinAccount_Status_RawValue(KinStorageKinAccount *message);
/**
 * Sets the raw value of an @c KinStorageKinAccount's @c status property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetKinStorageKinAccount_Status_RawValue(KinStorageKinAccount *message, int32_t value);

#pragma mark - KinStorageKinTransaction

typedef GPB_ENUM(KinStorageKinTransaction_FieldNumber) {
  KinStorageKinTransaction_FieldNumber_EnvelopeXdr = 1,
  KinStorageKinTransaction_FieldNumber_Status = 2,
  KinStorageKinTransaction_FieldNumber_Timestamp = 3,
  KinStorageKinTransaction_FieldNumber_ResultXdr = 4,
  KinStorageKinTransaction_FieldNumber_PagingToken = 5,
};

@interface KinStorageKinTransaction : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *envelopeXdr;

@property(nonatomic, readwrite) KinStorageKinTransaction_Status status;

@property(nonatomic, readwrite) int64_t timestamp;

/** result_xdr should exist in `ACKNOWLEDGED` and `HISTORICAL` states */
@property(nonatomic, readwrite, copy, null_resettable) NSData *resultXdr;

/** paging_token should exist only in `HISTORICAL` state */
@property(nonatomic, readwrite, copy, null_resettable) NSString *pagingToken;

@end

/**
 * Fetches the raw value of a @c KinStorageKinTransaction's @c status property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t KinStorageKinTransaction_Status_RawValue(KinStorageKinTransaction *message);
/**
 * Sets the raw value of an @c KinStorageKinTransaction's @c status property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetKinStorageKinTransaction_Status_RawValue(KinStorageKinTransaction *message, int32_t value);

#pragma mark - KinStorageKinTransactions

typedef GPB_ENUM(KinStorageKinTransactions_FieldNumber) {
  KinStorageKinTransactions_FieldNumber_ItemsArray = 1,
  KinStorageKinTransactions_FieldNumber_HeadPagingToken = 2,
  KinStorageKinTransactions_FieldNumber_TailPagingToken = 3,
};

@interface KinStorageKinTransactions : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<KinStorageKinTransaction*> *itemsArray;
/** The number of items in @c itemsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger itemsArray_Count;

/** The newest paging token to query newer transactions with */
@property(nonatomic, readwrite, copy, null_resettable) NSString *headPagingToken;

/** The oldest paging token to query older transactions with */
@property(nonatomic, readwrite, copy, null_resettable) NSString *tailPagingToken;

@end

#pragma mark - KinStorageInvoiceListBlob

typedef GPB_ENUM(KinStorageInvoiceListBlob_FieldNumber) {
  KinStorageInvoiceListBlob_FieldNumber_NetworkInvoiceList = 1,
};

@interface KinStorageInvoiceListBlob : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *networkInvoiceList;

@end

#pragma mark - KinStorageInvoices

typedef GPB_ENUM(KinStorageInvoices_FieldNumber) {
  KinStorageInvoices_FieldNumber_InvoiceLists = 1,
};

@interface KinStorageInvoices : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableDictionary<NSString*, KinStorageInvoiceListBlob*> *invoiceLists;
/** The number of items in @c invoiceLists without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger invoiceLists_Count;

@end

#pragma mark - KinStorageKinConfig

typedef GPB_ENUM(KinStorageKinConfig_FieldNumber) {
  KinStorageKinConfig_FieldNumber_MinFee = 1,
};

@interface KinStorageKinConfig : GPBMessage

@property(nonatomic, readwrite) int64_t minFee;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
