//
//  KinClient.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc. on 2020-05-15.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

/**
 `KinClient` is a factory class for managing instances of `KinAccount`.
 */
public final class KinClient {
    private let kinClientInternal: KinClientInternal

    /**
         Convenience initializer to instantiate a `KinClient` with a `ServiceProvider`.

         - Parameter provider: The `ServiceProvider` instance that provides the `URL` and `Network`.
         - Parameter appId: The `AppId` of the host application.
         */
    public convenience init(provider: ServiceProvider, appId: AppId, testMigration: Bool = false) {
        self.init(with: provider.url, network: provider.network, appId: appId, testMigration: testMigration)
    }

    /**
         Instantiates a `KinClient` with a `URL` and a `Network`.

         - Parameter nodeProviderUrl: The `URL` of the node this client will communicate to.
         - Parameter network: The `Network` to be used.
         - Parameter appId: The `AppId` of the host application.
         */
    public init(with nodeProviderUrl: URL,
                network: Network,
                appId: AppId,
                testMigration: Bool = false) {
        self.kinClientInternal = KinClientInternal(with: nodeProviderUrl,
                                                   network: network,
                                                   appId: appId,
                                                   testMigration: testMigration)
    }

    /**
     The `URL` of the node this client communicates to.
     */
    public var url: URL {
        return kinClientInternal.url
    }

    /**
     The list of `KinAccount` objects this client is managing.
     */
    public var accounts: KinAccounts {
        return kinClientInternal.accounts
    }

    /**
     The `Network` of the network which this client communicates to.
     */
    public var network: Network {
        return kinClientInternal.network
    }

    /**
         Adds an account associated to this client, and returns it.

         - Throws: `KinError.accountCreationFailed` if creating the account fails.

         - Returns: The newly added `KinAccount` which only exists locally.
         */
    public func addAccount() throws -> KinAccount {
        return try kinClientInternal.addAccount()
    }

    /**
         Deletes the account at the given index. This method is a no-op if there is no account at
         that index.

         If this is an action triggered by the user, make sure you let the him know that any funds owned
         by the account will be lost if it hasn't been backed up. See
         `exportKeyStore(passphrase:exportPassphrase:)`.

         - parameter index: The index of the account to delete.

         - throws: When deleting the account fails.
         */
    public func deleteAccount(at index: Int) throws {
        try kinClientInternal.deleteAccount(at: index)
    }

    /**
         Import an account from a JSON-formatted string.

         - Parameter passphrase: The passphrase to decrypt the secret key.

         - Throws: `KinError.internalInconsistency` if the given `jsonString` could not be parsed or if the import does not work.

         - Returns: The imported account
         */
    public func importAccount(_ jsonString: String, passphrase: String) throws -> KinAccount {
        return try kinClientInternal.importAccount(jsonString,
                                                   passphrase: passphrase)
    }

    /**
     Deletes the keystore.
     */
    public func deleteKeystore() {
        kinClientInternal.deleteKeystore()
    }

    /**
         Get the minimum fee for sending a transaction.

         - Returns: The minimum fee needed to send a transaction.
         */
    public func minFee() -> Promise<Quark> {
        return kinClientInternal.minFee()
    }
}
