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
    var accountRemoved: KinAccount.Id?

    init() { }

    func addAccount(_ account: KinAccount) throws -> KinAccount {
        return account
    }

    func addAccount(_ account: KinAccount) -> Promise<KinAccount> {
        TODO()
    }

    func getAccount(_ accountId: KinAccount.Id) -> Promise<KinAccount?> {
        return .init(stubGetAccountResult)
    }

    func updateAccount(_ account: KinAccount) -> Promise<KinAccount> {
        return .init(stubUpdateAccountResult)
    }

    func removeAccount(accountId: KinAccount.Id) -> Promise<Void> {
        accountRemoved = accountId
        return .init(())
    }

    func getAllAccountIds() -> Promise<[KinAccount.Id]> {
        TODO()
    }

    func storeTransactions(accountId: KinAccount.Id, transactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        TODO()
    }

    func getStoredTransactions(accountId: KinAccount.Id) -> Promise<KinTransactions?> {
        return .init(stubGetStoredTransactionsResult)
    }

    func clearStorage() -> Promise<Void> {
        storageCleared = true
        return .init(())
    }

    func advanceSequence(accountId: KinAccount.Id) -> Promise<KinAccount> {
        sequenceAdvanced = true
        return .init(stubAdvanceSequenceResult)
    }

    func deductFromAccountBalance(accountId: KinAccount.Id, amount: Kin) -> Promise<KinAccount> {
        remainingBalance = KinBalance(stubGetAccountResult.balance.amount - amount)
        return .init(stubDeductFromBalanceResult)
    }

    func insertNewTransaction(accountId: KinAccount.Id, newTransaction: KinTransaction) -> Promise<[KinTransaction]> {
        transactionInserted = newTransaction
        return .init(stubInsertNewTransactionResult)
    }

    func upsertNewTransactions(accountId: KinAccount.Id, newTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return .init(newTransactions)
    }

    func upsertOldTransactions(accountId: KinAccount.Id, oldTransactions: [KinTransaction]) -> Promise<[KinTransaction]> {
        return .init(oldTransactions)
    }

    func addInvoiceLists(accountId: KinAccount.Id, invoiceLists: [InvoiceList]) -> Promise<[InvoiceList]> {
        return .init([])
    }

    func getInvoiceListsMapForAccountId(account: KinAccount.Id) -> Promise<[InvoiceList.Id : InvoiceList]> {
        return .init([:])
    }

    func setMinFee(_ fee: Quark) {

    }

    func getMinFee() -> Quark? {
        return stubGetFeeResult
    }
}
