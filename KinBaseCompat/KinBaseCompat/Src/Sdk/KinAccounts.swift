//
//  KinAccounts.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase
import stellarsdk

/**
 `KinAccounts` wraps the `KinAccount` list.
 */
public final class KinAccounts {
    private var cache = [Int: KinAccount]()
    private let cacheLock = NSLock()

    private let kinEnvironment: KinEnvironment
    private let appId: AppId

    /**
     Number of `KinAccount` objects.
     */
    public var count: Int {

        return KeyStore.count()
    }

    init(kinEnvironment: KinEnvironment, appId: AppId) {
        self.kinEnvironment = kinEnvironment
        self.appId = appId

        loadAccounts()
    }

    /**
     Retrieve a `KinAccount` at a given index.

     - Parameter index: The index of the list of accounts to return.

     - Returns: The `KinAccount` at index if it exists, nil otherwise.
     */
    public subscript(_ index: Int) -> KinAccount? {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        return account(at: index)
    }

    func createAccount() throws -> KinAccount {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        let account = try createKinAccount()

        cache[count - 1] = account

        return account
    }

    func deleteAccount(at index: Int) throws {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        guard let account = account(at: index) else {
            throw KinError.internalInconsistency
        }

        guard KeyStore.remove(at: index) else {
            throw KinError.unknown
        }

        _ = account.kinAccountContext.clearStorage()

        account.deleted = true

        shiftCache(for: index)
    }

    func flushCache() {
        for account in cache.values {
            account.deleted = true
            _ = account.kinAccountContext.clearStorage()
        }

        cache.removeAll()
    }

    private func shiftCache(for index: Int) {
        let indexesToShuffle = Array(cache.keys).filter({ $0 > index }).sorted()

        cache[index] = nil

        var tempCache = [Int: KinAccount]()
        for i in indexesToShuffle {
            tempCache[i - 1] = cache[i]

            cache[i] = nil
        }

        for (index, account) in tempCache {
            cache[index] = account
        }
    }

    private func account(at index: Int) -> KinAccount? {
        return cache[index] ?? {
            self.loadAccountToCache(at: index)
            return cache[index]
        }()
    }

    private func createKinAccount() throws -> KinAccount {
        let stellarAccount = try KeyStore.newAccount(passphrase: "")
        return try kinAccountFromStellarAccount(stellarAccount)
    }

    private func loadAccounts() {
        for index in 0..<count {
            loadAccountToCache(at: index)
        }
    }

    private func loadAccountToCache(at index: Int) {
        guard index < count,
            let stellarAccount = KeyStore.account(at: index),
            let kinAccount = try? kinAccountFromStellarAccount(stellarAccount) else {
                return
        }

        cache[index] = kinAccount
    }

    private func kinAccountFromStellarAccount(_ stellarAccount: StellarAccount) throws -> KinAccount {
        let accountData = try stellarAccount.accountData()
        let seedBytes = try KeyUtils.seed(from: "", encryptedSeed: accountData.seed, salt: accountData.salt)
        let seed = try stellarsdk.Seed(bytes: seedBytes)
        let key = KinBase.KinAccount.Key(seed: seed)
        let kinAccountContext = try KinAccountContext.Builder(env: kinEnvironment)
            .importExistingPrivateKey(key)
            .build()

        let kinAccount = KinAccount(key: key,
                                    accountData: accountData,
                                    kinAccountContext: kinAccountContext,
                                    kinService: kinEnvironment.service,
                                    network: kinEnvironment.network,
                                    appId: appId)

        return kinAccount
    }
}

extension KinAccounts: Sequence {
    /**
     Provides an `AnyIterator` for the list of `KinAccount`'s.

     - Returns: An iterator for the list of `KinAccount`'s.
     */
    public func makeIterator() -> AnyIterator<KinAccount?> {
        return AnyIterator(stride(from: 0, to: self.count, by: 1).lazy.map { self[$0] }.makeIterator())
    }
}

extension KinAccounts: RandomAccessCollection {
    /**
     The start index of the list of `KinAccount`.
     */
    public var startIndex: Int {
        return 0
    }

    /**
     The upper end index of the list of `KinAccount`.
     */
    public var endIndex: Int {
        return KeyStore.count()
    }
}

extension KinAccounts {
    /**
     The first `KinAccount` object if it exists.
     */
    public var first: KinAccount? {
        return count > 0 ? self[0] : nil
    }

    /**
     The last `KinAccount` object if it exists.
     */
    public var last: KinAccount? {
        return count > 0 ? self[self.count - 1] : nil
    }
}
