#  Kin SDK iOS
[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![codecov](https://codecov.io/gh/kinecosystem/kin-ios/branch/master/graph/badge.svg?token=WB9BS3J2VY)](https://codecov.io/gh/kinecosystem/kin-ios)
[![CircleCI](https://img.shields.io/circleci/build/gh/kinecosystem/kin-ios/master?token=554b0d33a552795e7bcd927bbba119434918cacc)](https://circleci.com/gh/kinecosystem/kin-ios)
[![jazzy](https://img.shields.io/badge/docs-jazzy-blue)](https://kinecosystem.github.io/kin-ios/)
[![CocoaPods](https://img.shields.io/cocoapods/v/KinBase.svg?color=6f41e8)](https://cocoapods.org/pods/KinBase)

Use the Kin SDK for iOS to enable the use of Kin inside of your app. Include only the functionality you need to provide the right experience to your users. Use just the base library to access the lightest-weight wrapper over the Kin crytocurrency.


| Library&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |Path&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                                                                                                                                                                                                                                               |
|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `KinBase`                                                                                                                                                                             | [`/KinBase`](KinBase)                                                                                                        | The foundation library used by all other libraries in the system to support basic Kin operations: <ul><li>Wallet creation and management</li><li>Send and receive Kin</li></ul>                                                                                                           |
| `KinBaseCompat`                                                                                                                                                                       | [`/KinBaseCompat`](KinBaseCompat)                                                                                            | The KinBaseCompat library implements the public surface layer to be a drop in replacement of the, now deprecated, [kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios) library. Just update your version in Podfile and have better performance and stability. |
| `KinDesign`                                                                                                                                                                           | [`/KinDesign`](KinDesign)                                                                                                    | The shared KinDesign library components for creating consistent Kin user experiences. When creating a custom Kin experience, this library can be used to include standard UI components for displaying Kin prices, transactions, etc. |
| `KinUX`                                                                                                                                                                               | [`/KinUX`](KinUX)                                                                                                            | The KinUX library provides an out of the box model UI for spending Kin within an iOS application. Specificy what you're buying, your account, tap confirm. Success.|

## Note on Upcoming Solana Migration (Dec 8, 2020)
See [KinBase](KinBase) or [KinBaseCompat](KinBaseCompat) for specific migration details related to each module.

## Installation
In your Podfile
```
// *** KinBaseCompat is for LEGACY SUPPORT ONLY ***
// If you're a longtime Kin developer and want to use the compat
// interface that looks like the now deprecated SDKs
pod 'KinBaseCompat', '~> 0.4.5'

// If you're a new developer or want more functionality you want a
// mix of the libraries below:

// If you just want to access the blockchain & no UI
pod 'KinBase', '~> 0.4.5'

// Add spend to use the modal spend flow to allow users to buy things with Kin
pod 'KinUX', '~> 0.4.5'

// Add design for direct access to UI views you can use in your own app
pod 'KinDesign', '~> 0.4.5'
```

## Sample App

The [`/KinSampleApp`](KinSampleApp) directory includes a sample application. On the home screen of the sample app, you will see options to view Kin Wallet Demo and Kin Design Demo.

## Documentation
Jazzy Documentation for all classes in all modules located [here](https://kinecosystem.github.io/kin-ios/)

