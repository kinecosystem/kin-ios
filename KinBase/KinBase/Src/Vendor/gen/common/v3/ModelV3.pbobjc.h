// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: common/v3/model.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers.h>
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

@class APBCommonV3Invoice;
@class APBCommonV3Invoice_LineItem;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum APBCommonV3InvoiceError_Reason

typedef GPB_ENUM(APBCommonV3InvoiceError_Reason) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  APBCommonV3InvoiceError_Reason_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  APBCommonV3InvoiceError_Reason_Unknown = 0,

  /**
   * The provided invoice has already been paid for.
   *
   * This is only applicable when the memo transaction type
   * is SPEND.
   **/
  APBCommonV3InvoiceError_Reason_AlreadyPaid = 1,

  /**
   * The destination in the operation corresponding to this invoice
   * is incorrect.
   **/
  APBCommonV3InvoiceError_Reason_WrongDestination = 2,

  /** One or more SKUs in the invoice was not found. */
  APBCommonV3InvoiceError_Reason_SkuNotFound = 3,
};

GPBEnumDescriptor *APBCommonV3InvoiceError_Reason_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL APBCommonV3InvoiceError_Reason_IsValidValue(int32_t value);

#pragma mark - APBCommonV3ModelRoot

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
@interface APBCommonV3ModelRoot : GPBRootObject
@end

#pragma mark - APBCommonV3StellarAccountId

typedef GPB_ENUM(APBCommonV3StellarAccountId_FieldNumber) {
  APBCommonV3StellarAccountId_FieldNumber_Value = 1,
};

@interface APBCommonV3StellarAccountId : GPBMessage

/**
 * The public key of accounts always starts with a G, so we
 * ensure that the value starts with a G to prevent the secret
 * key from being used.
 **/
@property(nonatomic, readwrite, copy, null_resettable) NSString *value;

@end

#pragma mark - APBCommonV3TransactionHash

typedef GPB_ENUM(APBCommonV3TransactionHash_FieldNumber) {
  APBCommonV3TransactionHash_FieldNumber_Value = 1,
};

@interface APBCommonV3TransactionHash : GPBMessage

/** The sha256 hash of a transaction. */
@property(nonatomic, readwrite, copy, null_resettable) NSData *value;

@end

#pragma mark - APBCommonV3InvoiceHash

typedef GPB_ENUM(APBCommonV3InvoiceHash_FieldNumber) {
  APBCommonV3InvoiceHash_FieldNumber_Value = 1,
};

@interface APBCommonV3InvoiceHash : GPBMessage

/** The SHA-224 hash of the invoice. */
@property(nonatomic, readwrite, copy, null_resettable) NSData *value;

@end

#pragma mark - APBCommonV3Invoice

typedef GPB_ENUM(APBCommonV3Invoice_FieldNumber) {
  APBCommonV3Invoice_FieldNumber_ItemsArray = 1,
};

@interface APBCommonV3Invoice : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<APBCommonV3Invoice_LineItem*> *itemsArray;
/** The number of items in @c itemsArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger itemsArray_Count;

@end

#pragma mark - APBCommonV3Invoice_LineItem

typedef GPB_ENUM(APBCommonV3Invoice_LineItem_FieldNumber) {
  APBCommonV3Invoice_LineItem_FieldNumber_Title = 1,
  APBCommonV3Invoice_LineItem_FieldNumber_Description_p = 2,
  APBCommonV3Invoice_LineItem_FieldNumber_Amount = 3,
  APBCommonV3Invoice_LineItem_FieldNumber_Sku = 4,
};

@interface APBCommonV3Invoice_LineItem : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *title;

@property(nonatomic, readwrite, copy, null_resettable) NSString *description_p;

/** The amount in quarks. */
@property(nonatomic, readwrite) int64_t amount;

/** The app SKU related to this line item, if applicable. */
@property(nonatomic, readwrite, copy, null_resettable) NSData *sku;

@end

#pragma mark - APBCommonV3InvoiceList

typedef GPB_ENUM(APBCommonV3InvoiceList_FieldNumber) {
  APBCommonV3InvoiceList_FieldNumber_InvoicesArray = 1,
};

@interface APBCommonV3InvoiceList : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<APBCommonV3Invoice*> *invoicesArray;
/** The number of items in @c invoicesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger invoicesArray_Count;

@end

#pragma mark - APBCommonV3InvoiceError

typedef GPB_ENUM(APBCommonV3InvoiceError_FieldNumber) {
  APBCommonV3InvoiceError_FieldNumber_OpIndex = 1,
  APBCommonV3InvoiceError_FieldNumber_Invoice = 2,
  APBCommonV3InvoiceError_FieldNumber_Reason = 3,
};

@interface APBCommonV3InvoiceError : GPBMessage

/** The operation index the invoice corresponds to. */
@property(nonatomic, readwrite) uint32_t opIndex;

/** The invoice that was submitted. */
@property(nonatomic, readwrite, strong, null_resettable) APBCommonV3Invoice *invoice;
/** Test to see if @c invoice has been set. */
@property(nonatomic, readwrite) BOOL hasInvoice;

@property(nonatomic, readwrite) APBCommonV3InvoiceError_Reason reason;

@end

/**
 * Fetches the raw value of a @c APBCommonV3InvoiceError's @c reason property, even
 * if the value was not defined by the enum at the time the code was generated.
 **/
int32_t APBCommonV3InvoiceError_Reason_RawValue(APBCommonV3InvoiceError *message);
/**
 * Sets the raw value of an @c APBCommonV3InvoiceError's @c reason property, allowing
 * it to be set to a value that was not defined by the enum at the time the code
 * was generated.
 **/
void SetAPBCommonV3InvoiceError_Reason_RawValue(APBCommonV3InvoiceError *message, int32_t value);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
