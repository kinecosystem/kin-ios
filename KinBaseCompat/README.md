# KinBaseCompat

The KinBaseCompat module is a replacement for, and fully API compatible with [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios)

This version is based on the new [KinBase](../KinBase/README.md) module under the covers, which gives higher performance and reliability that you depend on.

# Installation
If you're currently making use of [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios) please upgrade your Podfile accordingly:
In the old [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios) sdk you would have had this:
```
pod 'KinSDK', '~> 1.0.2'
// or
pod 'KinSDK', '~> 1.0.2', :subspecs => ['BackupRestore']
```
Now, replace that with the following and do a clean build:
```
pod 'KinBaseCompat', '~> 0.4.1'
```

If you're not using [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios), please checkout [KinBase](../KinBase/README.md).

# Sending Whitelist Transaction
There's a slight change to how a `TransactionEnvelope` can be constructed after receiving the signed data from your whitelisting server. According to the [docs](https://docs.kin.org/ios/hi-kin#send-kin-with-a-whitelist-transaction) on the old sdk, you would have had this:
```
// In the response handler of the whitelist signing request
let envelope = try XDRDecoder.decode(TransactionEnvelope.self, data: data)
```
Now, you can replace that with the following:
```
import KinBase
...
let envelope = TransactionEnvelope(envelopeXdrBytes: [Byte](data))
// This envelope object can be sent like this
kinAccount.sendTransaction(envelope, completion: ...)
```

# Documentation
[kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios) is now **Deprecated** but see the [old documentation](https://docs.kin.org/ios/sdk) for more details on how to use it.

### Note on Upcoming Solana Migration
With the migration to Solana just around the corner, apps that want to continue to function during and post the move to the Solana blockchain are required to upgrade their `kin-ios` sdk to 0.4.0 or higher.
*Any application that does not upgrade will start to receive a `KinService.Errors.upgradeRequired` exception on any request made from `KinAccount`.*

#### Testing migration within your app
To enable migration of Kin3 -> Kin4 accounts on testnet, `KinClient` has a new optional parameter 
`testMigration` that will force this sdk into a state where migration will occur on demand if true

#### On Migration Day (Dec 8, 2020)
Apps should expect to see increased transaction times temporarily on the date of migration.
An on-demand migration will be attempted to trigger a migration, rebuild, and retry transactions that are submitted from an unmigrated account on this day and optimistically will complete successfully but are not guaranteed.
After all accounts have been migrated to Solana, transaction times should noticeably improve to around ~1s. Additional performance improvements are still possible and will roll out in future sdk releases.