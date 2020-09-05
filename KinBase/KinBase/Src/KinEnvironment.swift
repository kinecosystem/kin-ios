//
//  KinEnvironment.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public struct KinEnvironment {
    public enum Errors: Error {
        case missingPrivateKey
    }

    public let network: KinNetwork
    public let service: KinServiceType
    public let storage: KinStorageType
    public let networkHandler: NetworkOperationHandler
    public let dispatchQueue: DispatchQueue

    public let testService: KinTestServiceType?

    /// Use this initializer to specify your custom environment.
    /// Otherwise, use `KinEnvironment.Horizon.mainNet()` or  `KinEnvironment.Horizon.testNet()` for default setups.
    /// - Parameters:
    ///   - network: the network of Kin Blockchain to connect to, `.mainNet` or `.testNet`.
    ///   - service: an implementation of `KinServiceType`.
    ///   - storage: an implementation of `KinStorageType`.
    ///   - networkHandler: an `NetworkOperationHandler` instance.
    ///   - dispatchQueue: a default `DispatchQueue` the SDK should use.
    public init(network: KinNetwork,
                service: KinServiceType,
                storage: KinStorageType,
                networkHandler: NetworkOperationHandler,
                dispatchQueue: DispatchQueue,
                testService: KinTestServiceType? = nil) {
        self.network = network
        self.service = service
        self.storage = storage
        self.networkHandler = networkHandler
        self.dispatchQueue = dispatchQueue
        self.testService = testService
    }

    @available(*, deprecated, message: "Please use KinEnvironment.Agora instead. Horizon may dissapear in a future blockchain migration.")
    public class Horizon {
        /// A convinence function to get a default setup of the main net environment.
        /// - Parameters:
        ///   - accountCreationApi: developer is expected to pass in an implementation of `KinAccountCreationApi`
        ///   - whitelistingApi: developer is expected to pass in an implementation of `KinTransactionWhitelistingApi`
        /// - Returns: a default setup of `KinEnvironment` that connects to the main net.
        public static func mainNet(accountCreationApi: KinAccountCreationApi = DefaultHorizonKinAccountCreationApi(),
                                   whitelistingApi: KinTransactionWhitelistingApi = DefaultHorizonKinTransactionWhitelistingApi()) -> KinEnvironment {
            return defaultEnvironmentSetup(network: .mainNet,
                                           accountCreationApi: accountCreationApi,
                                           whitelistingApi: whitelistingApi)
        }

        /// A convinence function to get a default setup of the test environment.
        /// - Returns: a default setup of `KinEnvironment` that connects to test net.
        public static func testNet() -> KinEnvironment {
            return defaultEnvironmentSetup(network: .testNet,
                                           accountCreationApi: FriendBotApi(),
                                           whitelistingApi: DefaultHorizonKinTransactionWhitelistingApi())
        }

        private static func defaultEnvironmentSetup(network: KinNetwork,
                                                    accountCreationApi: KinAccountCreationApi,
                                                    whitelistingApi: KinTransactionWhitelistingApi) -> KinEnvironment {
            DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
            let horizonApi = HorizonKinApi(stellarSdkProxy: StellarSdkProxy(network: network))
            let networkHandler = NetworkOperationHandler()
            let service = KinService(network: network,
                                     networkOperationHandler: networkHandler,
                                     dispatchQueue: .promises,
                                     accountApi: horizonApi,
                                     accountCreationApi: accountCreationApi,
                                     transactionApi: horizonApi,
                                     transactionWhitelistingApi: whitelistingApi,
                                     streamingApi: horizonApi)
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storage = KinFileStorage(directory: documentDirectory,
                                         network: network)
            let testServiceInstance = KinTestService(friendBotApi: FriendBotApi(),
                                                     networkOperationHandler: networkHandler,
                                                     dispatchQueue: .promises)
            let testService: KinTestServiceType? = network == KinNetwork.testNet ? testServiceInstance : nil
            return KinEnvironment(network: network,
                                  service: service,
                                  storage: storage,
                                  networkHandler: networkHandler,
                                  dispatchQueue: .promises,
                                  testService: testService)
        }
    }

    public class Agora {
        public static func mainNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider()) -> KinEnvironment {
            return defaultEnvironmentSetup(network: .mainNet,
                                           appInfoProvider: appInfoProvider)
        }

        public static func testNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider()) -> KinEnvironment {
            return defaultEnvironmentSetup(network: .testNet,
                                           appInfoProvider: appInfoProvider)
        }

        private static func defaultEnvironmentSetup(network: KinNetwork,
                                                    appInfoProvider: AppInfoProvider) -> KinEnvironment {
            DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
            let networkHandler = NetworkOperationHandler()

            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storage = KinFileStorage(directory: documentDirectory,
                                         network: network)
            
            let grpcProxy = AgoraGrpcProxy(network: network,
                                           appInfoProvider: appInfoProvider,
                                           storage: storage)

            let agoraAccountsApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
            let agoraTransactionsApi = AgoraKinTransactionsApi(agoraGrpc: grpcProxy)

            let service = KinService(network: network,
                                     networkOperationHandler: networkHandler,
                                     dispatchQueue: .promises,
                                     accountApi: agoraAccountsApi,
                                     accountCreationApi: agoraAccountsApi,
                                     transactionApi: agoraTransactionsApi,
                                     transactionWhitelistingApi: agoraTransactionsApi,
                                     streamingApi: agoraAccountsApi)

            let testServiceInstance = KinTestService(friendBotApi: FriendBotApi(),
                                                     networkOperationHandler: networkHandler,
                                                     dispatchQueue: .promises)
            let testService: KinTestServiceType? = network == KinNetwork.testNet ? testServiceInstance : nil

            return KinEnvironment(network: network,
                                  service: service,
                                  storage: storage,
                                  networkHandler: networkHandler,
                                  dispatchQueue: .promises,
                                  testService: testService)
        }
    }
}

extension KinEnvironment {
    /// A convinence function to get all account ids stored in the current environment.
    /// - Returns: a `Promise` of `KinAccount.Id`s
    public func allAccountIds() -> Promise<[KinAccount.Id]> {
        return storage.getAllAccountIds()
    }

    func importPrivateKey(_ key: KinAccount.Key) throws -> KinAccount {
        guard key.privateKey != nil else {
            throw Errors.missingPrivateKey
        }

        return try storage.addAccount(KinAccount(key: key))
    }
}
