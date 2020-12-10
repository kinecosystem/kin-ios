//
//  KinEnvironment.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
import KinGrpcApi

public struct KinEnvironment {
    public enum Errors: Error {
        case missingPrivateKey
    }

    public var logger: KinLoggerFactory
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
                testService: KinTestServiceType? = nil,
                logger: KinLoggerFactory) {
        self.network = network
        self.service = service
        self.storage = storage
        self.networkHandler = networkHandler
        self.dispatchQueue = dispatchQueue
        self.testService = testService
        self.logger = logger
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
                                           whitelistingApi: whitelistingApi,
                                           enableLogging: false)
        }

        /// A convinence function to get a default setup of the test environment.
        /// - Returns: a default setup of `KinEnvironment` that connects to test net.
        public static func testNet() -> KinEnvironment {
            return defaultEnvironmentSetup(network: .testNet,
                                           accountCreationApi: FriendBotApi(),
                                           whitelistingApi: DefaultHorizonKinTransactionWhitelistingApi(),
                                           enableLogging: true)
        }

        private static func defaultEnvironmentSetup(network: KinNetwork,
                                                    accountCreationApi: KinAccountCreationApi,
                                                    whitelistingApi: KinTransactionWhitelistingApi,
                                                    enableLogging: Bool) -> KinEnvironment {
            assertNotLegacy(network)
            DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
            let logger = KinLoggerFactoryImpl(isLoggingEnabled: enableLogging)
            let horizonApi = HorizonKinApi(stellarSdkProxy: StellarSdkProxy(network: network))
            let networkHandler = NetworkOperationHandler()
            let service = KinService(network: network,
                                     networkOperationHandler: networkHandler,
                                     dispatchQueue: .promises,
                                     accountApi: horizonApi,
                                     accountCreationApi: accountCreationApi,
                                     transactionApi: horizonApi,
                                     transactionWhitelistingApi: whitelistingApi,
                                     streamingApi: horizonApi,
                                     logger: logger)
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storage = KinFileStorage(directory: documentDirectory,
                                         network: network)
            let testServiceInstance = KinTestService(friendBotApi: FriendBotApi(),
                                                     networkOperationHandler: networkHandler)
            let testService: KinTestServiceType? = network == KinNetwork.testNet ? testServiceInstance : nil
            return KinEnvironment(network: network,
                                  service: service,
                                  storage: storage,
                                  networkHandler: networkHandler,
                                  dispatchQueue: .promises,
                                  testService: testService,
                                  logger: logger)
        }
        
        private static func assertNotLegacy(_ network: KinNetwork) {
            switch network {
            case .testNetKin2, .mainNetKin2:
                fatalError("Unsupported: please upgrade to Agora")
            default:
                break
            }
        }
    }

    public class Agora {
        public static func mainNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider(), enableLogging: Bool = false, minApiVersion: Int = 3, useKin2: Bool = false) -> KinEnvironment {
            return defaultEnvironmentSetup(network: useKin2 ? .mainNetKin2 : .mainNet,
                                           appInfoProvider: appInfoProvider,
                                           enableLogging: enableLogging,
                                           minApiVersion: minApiVersion,
                                           testMigration: false)
        }

        public static func testNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider(), enableLogging: Bool = true, minApiVersion: Int = 3, useKin2: Bool = false, testMigration: Bool = false) -> KinEnvironment {
            return defaultEnvironmentSetup(network: useKin2 ? .testNetKin2 : .testNet,
                                           appInfoProvider: appInfoProvider,
                                           enableLogging: enableLogging,
                                           minApiVersion: minApiVersion,
                                           testMigration: testMigration)
        }

        private static func defaultEnvironmentSetup(network: KinNetwork,
                                                    appInfoProvider: AppInfoProvider,
                                                    enableLogging: Bool,
                                                    minApiVersion: Int,
                                                    testMigration: Bool) -> KinEnvironment {
            if !network.isKin2 {
                assertApiVersion(minApiVersion)
            }
            
            DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
            let logger = KinLoggerFactoryImpl(isLoggingEnabled: enableLogging)
            let networkHandler = NetworkOperationHandler()

            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storage = KinFileStorage(directory: documentDirectory,
                                         network: network)
        
            let authContext = AppUserAuthContext(appInfoProvider: appInfoProvider)
            let userAgentContext = UserAgentContext(storage: storage)
            var interceptors = [GRPCInterceptorFactory](arrayLiteral: authContext, userAgentContext)
            if network.isKin2 {
                interceptors.append(KinVersionContext(blockchainVersion: 2)) // Kin2 Blockchain
            }
            if testMigration {
                interceptors.append(UpgradeApiV4Context())
            }
            let grpcProxy = AgoraGrpcProxy(network: network,
                                           appInfoProvider: appInfoProvider,
                                           storage: storage,
                                           logger: logger,
                                           interceptorFactories: interceptors)

            let agoraAccountsApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
            let agoraTransactionsApi = AgoraKinTransactionsApi(agoraGrpc: grpcProxy)

            let serviceV3 = KinService(network: network,
                                       networkOperationHandler: networkHandler,
                                       dispatchQueue: .promises,
                                       accountApi: agoraAccountsApi,
                                       accountCreationApi: agoraAccountsApi,
                                       transactionApi: agoraTransactionsApi,
                                       transactionWhitelistingApi: agoraTransactionsApi,
                                       streamingApi: agoraAccountsApi,
                                       logger: logger)
            
            let serviceV4 = KinServiceV4(network: network,
                                         networkOperationHandler: networkHandler,
                                         dispatchQueue: .promises,
                                         accountApi: agoraAccountsApi,
                                         accountCreationApi: agoraAccountsApi,
                                         transactionApi: agoraTransactionsApi,
                                         streamingApi: agoraAccountsApi,
                                         logger: logger)
            
            let metaServiceApi = MetaServiceApi(configuredMinApi: minApiVersion, opHandler: networkHandler, api: agoraTransactionsApi, storage: storage)
            metaServiceApi.postInit().then{_ in }
            let service: KinServiceType =  KinServiceWrapper(kinServiceV3: serviceV3, kinServiceV4: serviceV4, metaServiceApi: metaServiceApi) //minApiVersion == 4 ? serviceV4 : serviceV3

            let testServiceV3 = KinTestService(friendBotApi: FriendBotApi(),
                                               networkOperationHandler: networkHandler)
            let testServiceV4 = KinTestServiceV4(airdropApi: AgoraKinAirdropApi(agoraGrpc: grpcProxy),
                                                 kinService: serviceV4,
                                                 networkOperationHandler: networkHandler)
            let testServiceInstance: KinTestServiceType = ((metaServiceApi.configuredMinApi == 4 || testMigration) ? testServiceV4 : testServiceV3)
            
            let testService: KinTestServiceType? = (network == KinNetwork.testNet ? testServiceInstance : nil)

            return KinEnvironment(network: network,
                                  service: service,
                                  storage: storage,
                                  networkHandler: networkHandler,
                                  dispatchQueue: .promises,
                                  testService: testService,
                                  logger: logger)
        }
        
        private static func assertApiVersion(_ version: Int) {
            guard version == 3 || version == 4 else {
                fatalError("Version \(version) is unsupported. Must be 3 or 4.")
            }
        }
    }
}

extension KinEnvironment {
    /// A convinence function to get all account ids stored in the current environment.
    /// - Returns: a `Promise` of `KinAccount.Id`s
    public func allAccountIds() -> Promise<[KinAccount.Id]> {
        return storage.getAllAccountIds()
    }

    func importPrivateKey(_ key: KinAccount.Key) throws {
        guard key.privateKey != nil else {
            throw Errors.missingPrivateKey
        }

        if storage.hasPrivateKey(key) {
            return
        }
        
        let _: KinAccount? = try storage.addAccount(KinAccount(key: key))
    }
    
    mutating func setEnableLogging(enableLogging: Bool) {
        logger.isLoggingEnabled = enableLogging
    }
}
