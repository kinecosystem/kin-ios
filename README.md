#  Kin SDK iOS
[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![codecov](https://codecov.io/gh/kinecosystem/kin-ios/branch/master/graph/badge.svg?token=WB9BS3J2VY)](https://codecov.io/gh/kinecosystem/kin-ios)
[![CircleCI](https://img.shields.io/circleci/build/gh/kinecosystem/kin-ios/master?token=554b0d33a552795e7bcd927bbba119434918cacc)](https://circleci.com/gh/kinecosystem/kin-ios)
[![jazzy](https://img.shields.io/badge/docs-jazzy-blue)](https://kinecosystem.github.io/kin-ios/docs/index.html)

Use the Kin SDK for iOS to enable the use of Kin inside of your app. Include only the functionality you need to provide the right experience to your users. Use just the base library to access the lightest-weight wrapper over the Kin crytocurrency.


| Library&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |Path&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                                                                                                                                                                                                                                               |
|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `KinBase`                                                                                                                                                                                | [`/KinBase`](KinBase)                                                                                                             | The foundation library used by all other libraries in the system to support basic Kin operations: <ul><li>Wallet creation and management</li><li>Send and receive Kin</li></ul>                                                                                                           |
| `KinBaseCompat`                                                                                                                                                                         | [`/KinBaseCompat`](KinBaseCompat)                                                                                                | The KinBaseCompat library implements the public surface layer to be a drop in replacement of the, now deprecated, [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios) library. Just update your version in Podfile and have better performance and stability. |

## Installation
For developers who are already on KinSDK [1.0.2](https://github.com/kinecosystem/kin-sdk-ios/releases/tag/1.0.2), simply change KinSDK to KinBaseCompat in the Podfile:
```
pod 'KinBaseCompat', '~> 0.1.0'
```

For developers wanting to check out the new APIs under KinBase:
```
pod 'KinBase', '~> 0.1.0'
```

## Documentation
Jazzy Documentation for all classes in all modules located [here](https://kinecosystem.github.io/kin-ios/docs/index.html)
