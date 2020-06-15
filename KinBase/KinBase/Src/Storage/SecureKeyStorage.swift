//
//  SecureKeyStorage.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-02-14.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

internal enum KeyStoreError: Error {
    case error(from: OSStatus)
}

internal protocol SecureKeyStorage {
    /// Adds a pair of account and key data to secure storage, updates the old key if the account exists.
    /// - Parameters:
    ///   - account: A string that uniquely identifies the account, e.g. account id.
    ///   - key: A piece of data. Caller is responsible for determining what data needs to be stored securely and the encoding/decoding of this key.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func add(account: String, key: Data) throws

    /// Retrieves key data from secure storage base on account.
    /// - Parameter account: The string identifier that was used when adding key.
    /// - Returns: The stored key data with the account if exists.
    func retrieve(account: String) -> Data?

    /// Returns all account identifiers in the storage.
    /// - Returns: A string array of all account identifiers stored.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func allAccounts() throws -> [String]

    /// Deletes an account from storage. This action is **irreversible**. Make sure the account has been backed up beforehand.
    /// - Parameter account: The string identifier that was used when adding key.
    /// - Warning: This action is **irreversible**. Calling this action would remove your key(e.g. private key). Make sure the account has been backed up
    ///             beforehand.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func delete(account: String) throws

    /// Clears the entire storage. This action is **irreversible** . Make sure the accounts have been backed up beforehand.
    /// - Warning: This action is **irreversible**. Calling this action would remove all keys(e.g. private key). Make sure the accounts have been backed
    ///             up beforehand.
    /// - Throws: `KeyStoreError` with `OSStatus`
    func clear() throws
}

/// Uses KeyChain in Security framework to implement on-device secure storage of keys. These keys are accessable only by the hosting app when the device
/// is unlocked.
internal class KeyChainStorage: SecureKeyStorage {

    func add(account: String, key: Data) throws {
        if retrieve(account: account) != nil {
            try? update(account: account, key: key)
            return
        }

        let addquery: [String: Any] = [
            String(kSecClass):          kSecClassGenericPassword,
            String(kSecAttrAccount):    account,
            String(kSecValueData):      key
        ]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeyStoreError.error(from: status)
        }
    }

    func retrieve(account: String) -> Data? {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword,
            String(kSecAttrAccount):  account,
            String(kSecReturnData):   true,
            String(kSecMatchLimit):   kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return data
    }

    func allAccounts() throws -> [String] {
        let query: [String: Any] = [
            String(kSecClass):              kSecClassGenericPassword,
            String(kSecReturnAttributes):   true,
            String(kSecMatchLimit):         kSecMatchLimitAll
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyStoreError.error(from: status)
        }

        guard let items = result as? [[String: AnyObject]] else {
            return []
        }

        let accounts = items.compactMap { (item) -> String? in
            return item[String(kSecAttrAccount)] as? String
        }

        return accounts
    }

    func delete(account: String) throws {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword,
            String(kSecAttrAccount):  account
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeyStoreError.error(from: status)
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            String(kSecClass):        kSecClassGenericPassword
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeyStoreError.error(from: status)
        }
    }

    private func update(account: String, key: Data) throws {
        let query: [String: Any] = [
            String(kSecClass):          kSecClassGenericPassword,
            String(kSecAttrAccount):    account
        ]

        let attrToUpdate: [String: Any] = [
            String(kSecValueData):      key
        ]

        let status = SecItemUpdate(query as CFDictionary,
                                   attrToUpdate as CFDictionary)
        if status != errSecSuccess {
            throw KeyStoreError.error(from: status)
        }
    }
}
