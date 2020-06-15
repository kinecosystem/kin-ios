# KinBase

The KinBase module is the foundation upon which the rest of the sdk stands on, however can be used on it's own to headlessly access the Kin Blockchain.

## Installation
Add the following to your Podfile.
```
pod 'KinBase', '~> 0.1.0'
```

## Quick Start
Everything starts with a `KinEnvironment` instance that describes which blockchain, services, and storage will be used. For a default setup, simply 
```swift
// Main net
let accountCreationApi = YourAccountCreationApiImpl()
let whitelistingApi = YourWhitelistingApiImpl()
let environment: KinEnvironment = KinEnvironment.mainNet(accountCreationApi: accountCreationApi,
                                                         whitelistingApi: whitelistingApi)

// Test net
let environment: KinEnvironment = KinEnvironment.testNet()
```

For a given `KinAccount` that you want to operate on, you will need a `KinAccountContext` instance.
This will be used to both create and access all `KinAccount` and `KinPayment`s.
 ```swift
let context: KinAccountContext =
    KinAccountContext.Builder(env: environment)
        .createNewAccount()
        .build()
```

### *As you may notice on the `KinAccountContext.Builder`, there are a few options on how to configure a `KinAccountContext`...*

## Creating An Account
If you want to create a new `KinAccount` use:
```swift
.createNewAccount()
```
## Access An Existing Account
If you want to access an existing `KinAccount` with options to send `KinPayment`s, input the `KinAccount.Id` with:
```swift
.useExistingAccount(KinAccount.Id("GATG_example_and_fake_key"))
```
*Note: this variant requires that the sdk knows about this `KinAccount`s `Key.PrivateKey` which can be imported the first time by:*
```swift
.importExistingPrivateKey(KinAccount.Key("key_containing_private_key"))
```
## Sending Payments
Sending `KinPayment`s are easy. Just add the amount and the destination `KinAccount.Id`.

*Note: successive calls to this function before the previous is completed will be properly queued according to blockchain implementation needs.*
```swift
let paymentItem = KinPaymentItem(amount: Kin(5), destAccountId: KinAccount.Id("GATG_example_and_fake_key"))
context.sendKinPayment(paymentItem, memo: KinMemo(text: "my_memo"))
    .then { payment in
        // Payment Completed
    }
```
Sending a batch of payments to the blockchain to be completed together, in a single transaction, is just as easy.

*Note: This operation is atomic. All payments will either succeed or fail together.*
```swift
let payments = [KinPaymentItem(amount: Kin(5), destAccountId: KinAccount.Id("GATG_example_and_fake_key")),
                KinPaymentItem(amount: Kin(30), destAccountId: KinAccount.Id("GATG_example_and_fake_key"))]
context.sendKinPayments(payments, KinMemo(text: "my_memo"))
  .then { completedPayments in
    // Payments Completed
}
```

## Retrieving Account Data
The `KinAccount.Id` for a given `KinAccountContext` instance is always available
```swift
context.accountId
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

## Retrieving Payment Data
Weather you're looking for the full payment history, or just to be notified of new payments you can observe any changes to payments for a given account with:
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
