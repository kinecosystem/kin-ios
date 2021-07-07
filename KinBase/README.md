# KinBase

[![CocoaPods](https://img.shields.io/cocoapods/v/KinBase.svg?color=6f41e8)](https://cocoapods.org/pods/KinBase)

The KinBase module is the foundation upon which the rest of the SDK stands.

## Installation
Add the following to your Podfile.
```
pod 'KinBase', '~> 1.0.2'
```

## Overview
KinBase contains two main components that are to be instantiated and used by the developer:
- a `KinEnvironment` instance to describe the network (test or production) and provide some external dependencies
- a `KinAccountContext` instance to access functionality of a Kin account on the Kin Blockchain and also to provide local storage for your private key and data cache for account and payment history data
Below you'll find a general overview on how to make use of KinBase, but also consider diving into the specific documentation [found here](https://kinecosystem.github.io/kin-ios/docs) for more details.


## Quick Start
Everything starts with a `KinEnvironment` instance that describes which blockchain, services, and storage will be used. For a default setup, simply

### Agora Kin Environment
The Agora Kin Environment is now the preferred method of communicating to the Kin Blockchain. Agora is both a gateway to submit payments and a history collector that can be used to resolve your full payment history.
When submitting payments, a developer should properly configure an [Agora webhook](https://docs.kin.org/how-it-works#webhooks), which acts as a delegate to approve and optionally co-sign a transaction to mediate transaction fees.
Agora can also store additional metadata about your transaction concerning what your payments were for. This bundle of information is called an `Invoice`: offchain data which is referenced by the payment's associated `Memo`, both which you can read more about below in the [Sending Payments](#sending-payments) section.

You'll also need to tell the SDK a bit about your app in an AppInfoProvider implementation to work with some features (like paying and resolving Invoices and the [spend](../spend) module UI)
There are two bundles of information an App provides through this interface:
- An AppInfo object to describe the App. This contains your App's unique App Index which you can obtain by registering [here](https://docs.kin.org/app-registration)
- Passthrough Auth User Credentials are passed onto the webhook when submitting a transaction
For more information regarding webhooks and webhook integration please read more about [how it works](https://docs.kin.org/how-it-works#webhooks).

```swift
let environment = KinEnvironment.Agora.mainNet(
  appInfoProvider: BasicAppInfoProvider(
    appInfo: AppInfo(
      appIdx: AppIndex(value: YOUR_APP_INDEX),
      kinAccount: YOUR_PUBLIC_KEY,
      name: "YOUR_APP_NAME",
      appIconData: YOUR_APP_ICON_DATA
    ),
    appUserId: "YOUR_USER_ID",
    appUserPasskey: "YOUR_USER_PASSKEY"
  )
)
```

### KinAccountContext
For a given `KinAccount` that you want to operate on, you will need a `KinAccountContext` instance.
This will be used to both create and access all `KinAccount` and `KinPayment`s.
 ```swift
let context: KinAccountContext =
    KinAccountContext.Builder(env: environment)
        .createNewAccount()
        .build()
```

## Creating An Account
If you want to create a new `KinAccount` use:
```swift
.createNewAccount()
```
## Access An Existing Account
If you want to access an existing `KinAccount` with options to send `KinPayment`s, input the `KinAccount.Id` with:
```swift
.useExistingAccount(PublicKey(base58: "example_and_fake_key"))
```
*Note: this variant requires that the sdk knows about this `KinAccount`s `Key.PrivateKey` which can be imported the first time by:*
```swift
.importExistingPrivateKey(KeyPair(seed: Seed(base58: "private_seed")))
```
## Sending Payments
Sending `KinPayment`s is easy. Just add the amount and the destination `PublicKey`.

*Note: successive calls to this function before the previous is completed will be properly queued according to blockchain implementation needs.*
```swift
let paymentItem = KinPaymentItem(amount: Kin(5), destAccount: PublicKey(base58: "example_and_fake_key"))
context.sendKinPayment(paymentItem, memo: KinMemo(text: "my_memo"))
    .then { payment in
        // Payment Completed
    }
```
Sending a batch of payments to the blockchain to be completed together, in a single transaction, is just as easy.

*Note: This operation is atomic. All payments will either succeed or fail together.*
```swift
let payments = [KinPaymentItem(amount: Kin(5), destAccount: PublicKey(base58: "example_and_fake_key")),
                KinPaymentItem(amount: Kin(30), destAccount: PublicKey(base58: "example_and_fake_key"))]
context.sendKinPayments(payments, KinMemo(text: "my_memo"))
  .then { completedPayments in
    // Payments Completed
}
```

### Are there Fees?
It depends. By default, payments on the Kin Blockchain are charged a minimal fee of 100 Quark (1 Quark = 0.001 Kin) each. The minimum required fee is dictated by the Blockchain. Fees on the Kin blockchain are an anti-spam feature intended to prevent malicious actors from spamming the network. Registered Kin apps are given a whitelisted account, which they can use to exempt their or their users' transactions using the [Sign Transaction webhook](https://docs.kin.org/how-it-works#sign-transaction).

When using KinAccountContext configured with the Agora KinEnvironment, by default a fee will not be added to the payment unless you specifically want your users to pay fees instead of you providing whitelisting. This can be achieved by overridintg and setting the `isWhitelistingAvailable` parameter to false in the `KinTransactionWhitelistingApi` instance when configuring your `KinEnvironment` instance.

### How can I add more data to the payment?
#### Memos
Memos are only 32 bytes of data that are stored on the blockchain with your payment data. Because of this, it's recommended to only include data you can use to reference a larger set of data off chain.

#### *Kin Binary Memo Format (Recommended)*
The Kin Binary Memo Format is defined by [this spec](https://github.com/kinecosystem/agora-api/blob/master/spec/memo.md) and includes the follow fields:
- Version: the memo encoding version (primarily used by the SDKs for interpreting memos).
- Transaction Type: the 'type' of the transaction the memo is embedded in.
- App Index: a 16-bit value that refers to the app the transaction is related to. Replaces app IDs.
- Foreign Key: the identifier in an auxiliary transaction service that contains metadata about what a transaction is for.

Apps that are migrating from the old AppId format can check out details [here](https://docs.kin.org/how-it-works#memo-format-and-app-index)

Use the `KinBinaryMemo.init(...)` to construct a `KinBinaryMemo`.
The `KinBinaryMemo.TransferType` is important to set appropriately for the type of payment your are making (Earn/Spend/P2P) (See JazzyDoc definitions for more details).
The new foreign key field primarily serves as a way for apps to include a reference to some other data stored off-chain, to help address memo space limitations. This field has a max limit of 230 bits. One option available to developers for storing off-chain data is [invoices](#invoices), which can help developers provide their users with richer transaction data and history. However, developers are free to use the foreign key to reference data hosted by their own services.
```swift
try KinBinaryMemo(typeId: KinBinaryMemo.TransferType.p2p.rawValue,
                  appIdx: yourAppIndex.value,
                  foreignKeyBytes: [Byte](yourForeignKeyData))
```

#### *Text Memos (Old style memos)*
You can provide a text-based memo with the `KinMemo` class. This format should only be used be existing incumbant apps that have been issued AppIds and have yet to upgrade to the new Kin Binary Memo Format.

#### Invoices
[Invoices](https://docs.kin.org/how-it-works#invoices) are a great way to leverage Agora to store data about your payments off chain for you to retrieve later (e.g. in your payment history). They can be submitted to Agora via `payInvoice` method with a properly formatted KinBinaryMemo which is used to reference the applicable Invoice data at a later time.

An invoice for a payment contains a list of line items, which contain the following information:
- **title**: the title of a line item.
- **amount**: the amount of a line item.
- **description** (optional): the description of the line item.
- **sku** (optional): an app-specific identifier. This can be anything developers wish to include (e.g. a product ID).

The `Invoice` and `LineItem` class can be used to construct an Invoice for which to operate on. As an app that sells a set of digital goods or services you may wish to transform the information you have in your own models into an Invoice object and reference it later via it's identifier stored in the SKU.
```swift
let lineItem = try LineItem(title: "Start a Chat",
                            description: "Your description",
                            amount: Kin(25),
                            sku: SKU([Byte](yourSkuData)))
let invoice = try Invoice(lineItems: [lineItem])
```

To Execute a payment for an `Invoice` you can make use of the `payInvoice` convenience function on `KinAccountContext`. This essentially calls `sendPayment` on your behalf with the correctly formatted `KinBinaryMemo` and TransferType of `KinBinaryMemo.TransferType.Spend`. Invoices can and should also be used for other TransferTypes such as P2P and Earns.

*The destinationKinAccountId must match the expected & registered destinationKinAppIdx provided [during registration](https://docs.kin.org/app-registration)*
```swift
payInvoice(processingAppIdx: yourAppIdx,
           destinationAccount: destAccount,
           invoice: yourInvoice,
           type: .spend).then { kinPayment ->
    // Payment Completed
}
```

If an `Invoice` was included with the submission than the optional invoice field on a `KinPayment` will be populated with the Invoice. This is especially helpful when observing your [payment history](#retrieving-payment-history)
```swift
kinPayment.invoice
```

*Note:* If you are paying for an `Invoice` you *must* use the Kin Binary Memo Format for the memo.*

## Retrieving Account Data
The `PublicKey` for a given `KinAccountContext` instance is always available
```swift
context.accountPublicKey
```
If you require more than just the id, the full `KinAccount` is available by querying with:
```swift
context.getAccount()
    .then { kinAccount in
        // Do something with the account data
    }
```
Observing balance changes over time is another common account operation:

*Note: don't forget to clean up when the observer is no longer required! This can be accomplished via a `DisposeBag`.*
```swift
val lifecycle = DisposeBag()
context.observeBalance()
    .subscribe { kinBalance in
        // Do something on balance update
    }.disposedBy(lifecycle)
```

## Retrieving Payment History
Wether you're looking for the full payment history, or just to be notified of new payments you can observe any changes to payments for a given account with:
```swift
context.observePayments()
    .add { payments in
        // Will emit the full payment history by default
        // @see ObserverMode for more details
    }
    .disposedBy(lifecycle)
```
Sometimes it's useful to retrieve payments that were processed together in a single `KinTransaction`
```swift
context.getPaymentsForTransactionHash(KinTransactionHash(<txnHash>))
    .then { payments in
        // Payments related to txn hash
    }
```

## Other
When done with a particular account, you can irrevokably delete the data, **including the private key**, by performing the following:
```swift
context.clearStorage()
    .then {
        // The data with this KinAccountContext is now gone forever
    }
```

