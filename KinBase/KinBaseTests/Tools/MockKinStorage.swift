//
//  MockKinStorage.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
@testable import KinBase

class MockKinStorage: KinStorageType {
    var stubGetAccountResult: KinAccount!
    var stubUpdateAccountResult: KinAccount!
    var stubAdvanceSequenceResult: KinAccount!
    var stubDeductFromBalanceResult: KinAccount!
    var stubInsertNewTransactionResult: [KinTransaction]!
    var stubGetStoredTransactionsResult: KinTransactions?
    var stubGetFeeResult: Quark?

    var sequenceAdvanced = false
    var remainingBalance: KinBalance!
    var transactionInserted: KinTransaction!
    var storageCleared = false
    var accountRemoved: PublicKey?
    var stubSetMinApiVersionResult: Promise<Int>!
    var stubGetMinApiVersionResult: Promise<Int?>!

    init() { }

    func addAccount(_ account: KinAccount) throws -> KinAccount {
        return account
    }

    func addAccount(_ account: KinAccount) -> Promise<KinAccount> {
        TODO()
    }

    func getAccount(_ account: PublicKey) -> Promise<KinAccount?> {
        return .init(stubGetAccountResult)
    }

    func updateAccount(_ account: KinAccount) -> Promise<KinAccount> {
        return .init(stubUpdateAccountResult)
    }

    func removeAccount(account: PublicKey) -> Promise<Void> {
        accountRemoved = account
        return .init(())
    }

    func getAllAccountIds() -> Promise<[PublicKey]> {
        TODO()
    }

    func storeTransactions(account: PublicKey, transactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        TODO()
    }

    func getStoredTransactions(account: PublicKey) -> Promise<KinTransactions?> {
        return .init(stubGetStoredTransactionsResult)
    }

    func clearStorage() -> Promise<Void> {
        storageCleared = true
        return .init(())
    }

    func advanceSequence(account: PublicKey) -> Promise<KinAccount> {
        sequenceAdvanced = true
        return .init(stubAdvanceSequenceResult)
    }

    func deductFromAccountBalance(account: PublicKey, amount: Kin) -> Promise<KinAccount> {
        remainingBalance = KinBalance(stubGetAccountResult.balance.amount - amount)
        return .init(stubDeductFromBalanceResult)
    }

    func insertNewTransaction(account: PublicKey, newTransaction: KinTransaction) -> Promise<[KinTransaction]> {
        transactionInserted = newTransaction
        return .init(stubInsertNewTransactionResult)
    }

    func upsertNewTransactions(account: PublicKey, newTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return .init(newTransactions)
    }

    func upsertOldTransactions(account: PublicKey, oldTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return .init(oldTransactions)
    }

    func addInvoiceLists(account: PublicKey, invoiceLists: [InvoiceList]) -> Promise<[InvoiceList]> {
        return .init([])
    }

    func getInvoiceListsMapForAccountId(account: PublicKey) -> Promise<[InvoiceList.Id : InvoiceList]> {
        return .init([:])
    }

    func setMinFee(_ fee: Quark) {

    }

    func getMinFee() -> Quark? {
        return stubGetFeeResult
    }
    
    func setMinApiVersion(apiVersion: Int) -> Promise<Int> {
        return stubSetMinApiVersionResult
    }
    
    func getMinApiVersion() -> Promise<Int?> {
        return stubGetMinApiVersionResult
    }
    
    func getOrCreateCID() -> String {
        return UUID().uuidString
    }
    
    func hasPrivateKey(_ account: PublicKey) -> Bool {
        false
    }
}
