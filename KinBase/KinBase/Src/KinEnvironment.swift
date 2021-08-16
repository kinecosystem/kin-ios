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

    public var logger: KinLoggerFactory
    public let network: KinNetwork
    public let service: KinServiceType
    public let storage: KinStorageType
    public let networkHandler: NetworkOperationHandler
    public let dispatchQueue: DispatchQueue

    public let testService: KinTestServiceType?

    /// Use this initializer to specify your custom environment.
    /// Otherwise, use `KinEnvironment.Agora.mainNet()` or  `KinEnvironment.Agora.testNet()` for default setups.
    /// - Parameters:
    ///   - network: the network of Kin Blockchain to connect to, `.mainNet` or `.testNet`.
    ///   - service: an implementation of `KinServiceType`.
    ///   - storage: an implementation of `KinStorageType`.
    ///   - networkHandler: a `NetworkOperationHandler` instance.
    ///   - dispatchQueue: a default `DispatchQueue` the SDK should use.
    public init(network: KinNetwork, service: KinServiceType, storage: KinStorageType, networkHandler: NetworkOperationHandler, dispatchQueue: DispatchQueue, testService: KinTestServiceType? = nil, logger: KinLoggerFactory) {
        self.network = network
        self.service = service
        self.storage = storage
        self.networkHandler = networkHandler
        self.dispatchQueue = dispatchQueue
        self.testService = testService
        self.logger = logger
    }

    public class Agora {
        public static func mainNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider(), enableLogging: Bool = false, minApiVersion: Int = 4, storagePath: URL? = nil) -> KinEnvironment {
            return defaultEnvironmentSetup(
                network: .mainNet,
                appInfoProvider: appInfoProvider,
                enableLogging: enableLogging,
                minApiVersion: minApiVersion,
                storagePath: storagePath
            )
        }
        
        public static func testNet(appInfoProvider: AppInfoProvider = DummyAppInfoProvider(), enableLogging: Bool = true, minApiVersion: Int = 4, storagePath: URL? = nil) -> KinEnvironment {
            return defaultEnvironmentSetup(
                network: .testNet,
                appInfoProvider: appInfoProvider,
                enableLogging: enableLogging,
                minApiVersion: minApiVersion,
                storagePath: storagePath
            )
        }
        
        private static func defaultEnvironmentSetup(network: KinNetwork, appInfoProvider: AppInfoProvider, enableLogging: Bool, minApiVersion: Int, storagePath: URL?) -> KinEnvironment {
            DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
            let logger = KinLoggerFactoryImpl(isLoggingEnabled: enableLogging)
            let networkHandler = NetworkOperationHandler(
                shouldRetryError: { (error: Error) in
                    error is KinServiceV4.Errors && error as! KinServiceV4.Errors == KinServiceV4.Errors.transientFailure()
                }
            )
            // If custom storagePath is set, use that. Otherwise provide a default.
            let documentDirectory = storagePath ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("kin_storage", isDirectory: true)
            let storage = KinFileStorage(directory: documentDirectory, network: network)
            
            let grpcProxy = AgoraGrpcProxy(
                network: network,
                appInfoProvider: appInfoProvider,
                storage: storage,
                logger: logger,
                interceptorFactories: [
                    AppUserAuthContext(appInfoProvider: appInfoProvider),
                    UserAgentContext(storage: storage),
                ]
            )

            let agoraAccountsApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
            let agoraTransactionsApi = AgoraKinTransactionsApi(agoraGrpc: grpcProxy)
            
            let serviceV4 = KinServiceV4(
                network: network,
                networkOperationHandler: networkHandler,
                dispatchQueue: .promises,
                accountApi: agoraAccountsApi,
                accountCreationApi: agoraAccountsApi,
                transactionApi: agoraTransactionsApi,
                streamingApi: agoraAccountsApi,
                logger: logger
            )
            
            let metaServiceApi = MetaServiceApi(configuredMinApi: minApiVersion, opHandler: networkHandler, api: agoraTransactionsApi, storage: storage)
            metaServiceApi.postInit().then{ _ in }

            let testServiceV4 = KinTestServiceV4(
                airdropApi: AgoraKinAirdropApi(agoraGrpc: grpcProxy),
                kinService: serviceV4,
                networkOperationHandler: networkHandler
            )

            return KinEnvironment(
                network: network,
                service: serviceV4,
                storage: storage,
                networkHandler: networkHandler,
                dispatchQueue: .promises,
                testService: network == KinNetwork.testNet ? testServiceV4 : nil,
                logger: logger
            )
        }
    }
}

extension KinEnvironment {
    /// A convenience function to get all account ids stored in the current environment.
    /// - Returns: a `Promise` of `KinAccount.Id`s
    public func allAccountIds() -> Promise<[PublicKey]> {
        return storage.getAllAccountIds()
    }

    func importPrivateKey(_ key: KeyPair) throws {
        if storage.hasPrivateKey(key.publicKey) {
            return
        }
        
        let _: KinAccount? = try storage.addAccount(KinAccount(publicKey: key.publicKey, privateKey: key.privateKey))
    }
    
    mutating func setEnableLogging(enableLogging: Bool) {
        logger.isLoggingEnabled = enableLogging
    }
}


// MARK: - import account from BackupRestoreModule -
extension KinEnvironment {
    /**
         Import the account data from a JSON string.
         - Parameter jsonString: The JSON representation of the KinAccount
         - Parameter passphrase: The passphrase with which to decrypt the seed
         - Returns: A KinAccount
         */
    func importAccount(_ jsonString: String,
                       passphrase: String) throws -> KinAccount {
        guard let data = jsonString.data(using: .utf8) else {
            throw KeyUtilsError.decodingFailed("invalid data")
        }
        let accountData = try JSONDecoder().decode(KeyUtils.AccountData.self, from: data)

        let decryptedSeed = try KeyUtils.seed(from: passphrase, encryptedSeed: accountData.seed, salt: accountData.salt)
        if let seed = Seed(decryptedSeed) {
            // Legacy backup, use seed
            let keyPair = KeyPair(seed: seed)
            try self.importPrivateKey(keyPair)
            return KinAccount(publicKey: keyPair.publicKey, privateKey: keyPair.privateKey)
        } else {
            // v1+ backup, use private key
            guard let publicKey = PublicKey(base58: accountData.pkey), let privateKey = PrivateKey(decryptedSeed) else {
                throw KeyUtilsError.decodingFailed("invalid key")
            }
            let keyPair = KeyPair(publicKey: publicKey, privateKey: privateKey)
            try self.importPrivateKey(keyPair)
            return KinAccount(publicKey: keyPair.publicKey, privateKey: keyPair.privateKey)
        }
    }
}
