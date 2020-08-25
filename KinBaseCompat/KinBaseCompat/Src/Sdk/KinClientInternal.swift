//
//  KinClientInternal.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase
import Promises

class KinClientInternal {
    let url: URL
    let network: Network
    let appId: AppId
    let accounts: KinAccounts

    private let kinEnvironment: KinEnvironment

    init(with nodeProviderUrl: URL, network: Network, appId: AppId) {
        self.url = nodeProviderUrl
        self.network = network
        self.appId = appId
        self.kinEnvironment = network == .mainNet ? KinEnvironment.Agora.mainNet() : KinEnvironment.Agora.testNet()
        self.accounts = KinAccounts(kinEnvironment: kinEnvironment,
                                    appId: appId)
    }

    /// New account only exists in KinBase.
    func addAccount() throws -> KinAccount {
        do {
            return try accounts.createAccount()
        }
        catch {
            throw KinError.accountCreationFailed(error)
        }
    }

    /// Deletes account from both KinSDK and KinBase storage
    func deleteAccount(at index: Int) throws {
        do {
            try accounts.deleteAccount(at: index)
        }
        catch {
            throw KinError.accountDeletionFailed(error)
        }
    }

    func importAccount(_ jsonString: String,
                       passphrase: String) throws -> KinAccount {
        guard let data = jsonString.data(using: .utf8) else {
            throw KinError.internalInconsistency
        }

        let accountData = try JSONDecoder().decode(AccountData.self, from: data)

        try KeyStore.importAccount(accountData,
                                   passphrase: passphrase,
                                   newPassphrase: "")

        guard let account = accounts.last else {
            throw KinError.internalInconsistency
        }

        return account
    }

    /// Deletes keystore from both KinSDK and KinBase storage
    func deleteKeystore() {
        for _ in 0..<KeyStore.count() {
            KeyStore.remove(at: 0)
        }

        accounts.flushCache()
    }

    func minFee() -> Promise<Quark> {
        if let fee = kinEnvironment.storage.getMinFee() {
            return .init(Quark(fee))
        }

        let kinPromise = Promise<Quark>()
        let kinBasePromise = kinEnvironment.service.getMinFee()

        kinBasePromise
            .then { [weak self] quark -> Promises.Promise<KinBase.Quark> in
                self?.kinEnvironment.storage.setMinFee(quark)
                kinPromise.signal(Quark(quark))
                return kinBasePromise
            }
            .catch { kinPromise.signal($0) }

        return kinPromise
    }
}
