# Kin SDK iOS

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![codecov](https://codecov.io/gh/kinecosystem/kin-ios/branch/master/graph/badge.svg?token=WB9BS3J2VY)](https://codecov.io/gh/kinecosystem/kin-ios)
[![CircleCI](https://img.shields.io/circleci/build/gh/kinecosystem/kin-ios/master?token=554b0d33a552795e7bcd927bbba119434918cacc)](https://circleci.com/gh/kinecosystem/kin-ios)
[![jazzy](https://img.shields.io/badge/docs-jazzy-blue)](https://kinecosystem.github.io/kin-ios/)
[![CocoaPods](https://img.shields.io/cocoapods/v/KinBase.svg?color=6f41e8)](https://cocoapods.org/pods/KinBase)

Use the Kin SDK for iOS to enable the use of Kin inside of your app. Include only the functionality you need to provide the right experience to your users. Use just the base library to access the lightest-weight wrapper over the Kin cryptocurrency.

## Looking for a quick way to start?

The quickest way to get started is by following the [tutorial](https://kintegrate.dev/tutorials/getting-started-ios-sdk/) or by downloading the [starter kit](https://kintegrate.dev/starters/kin-ios-starter/).

## Repository Contents

| Library     | Path                      | Description                                                                                                                                                                                                                           |
| :---------- | :------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `KinBase`   | [`/KinBase`](KinBase)     | The foundation library used by all other libraries in the system to support basic Kin operations: <ul><li>Wallet creation and management</li><li>Send and receive Kin</li></ul>                                                       |
| `KinDesign` | [`/KinDesign`](KinDesign) | The shared KinDesign library components for creating consistent Kin user experiences. When creating a custom Kin experience, this library can be used to include standard UI components for displaying Kin prices, transactions, etc. |
| `KinUX`     | [`/KinUX`](KinUX)         | The KinUX library provides an out of the box model UI for spending Kin within an iOS application. Specificy what you're buying, your account, tap confirm. Success.                                                                   |

## Installation

In your Podfile

```
// If you just want to access the blockchain & no UI
pod 'KinBase', '~> 2.1.1'

// Add spend to use the modal spend flow to allow users to buy things with Kin
pod 'KinUX', '~> 2.1.1'

// Add design for direct access to UI views you can use in your own app
pod 'KinDesign', '~> 2.1.1'
```

## Sample App

The [`/KinSampleApp`](KinSampleApp) directory includes a sample application. On the home screen of the sample app, you will see options to view Kin Wallet Demo and Kin Design Demo.

## Documentation

Jazzy Documentation for all classes in all modules located [here](https://kinecosystem.github.io/kin-ios/)

## Apps using legacy versions

For specific instructions related to migrating from older versions, see the [migration help document](migration_help.md).
