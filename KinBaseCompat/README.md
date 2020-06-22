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
pod 'KinBaseCompat', '~> 0.1.0'
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

