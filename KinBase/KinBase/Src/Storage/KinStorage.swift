//
//  KinStorage.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-04-02.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public protocol KinStorageType {
    func hasPrivateKey(_ privateKey: KinAccount.Key) -> Bool
    
    func addAccount(_ account: KinAccount) throws -> KinAccount

    func addAccount(_ account: KinAccount) -> Promise<KinAccount>

    func getAccount(_ accountId: KinAccount.Id) -> Promise<KinAccount?>

    func updateAccount(_ account: KinAccount) -> Promise<KinAccount>

    func removeAccount(accountId: KinAccount.Id) -> Promise<Void>

    func getAllAccountIds() -> Promise<[KinAccount.Id]>

    func advanceSequence(accountId: KinAccount.Id) -> Promise<KinAccount>

    func deductFromAccountBalance(accountId: KinAccount.Id,
                                  amount: Kin) -> Promise<KinAccount>

    func storeTransactions(accountId: KinAccount.Id,
                           transactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func getStoredTransactions(accountId: KinAccount.Id) -> Promise<KinTransactions?>


    func upsertNewTransactions(accountId: KinAccount.Id,
                               newTransactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func upsertOldTransactions(accountId: KinAccount.Id,
                               oldTransactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func insertNewTransaction(accountId: KinAccount.Id,
                              newTransaction: KinTransaction) -> Promise<[KinTransaction]>

    func addInvoiceLists(accountId: KinAccount.Id,
                         invoiceLists: [InvoiceList]) -> Promise<[InvoiceList]>

    func getInvoiceListsMapForAccountId(account: KinAccount.Id) -> Promise<[InvoiceList.Id: InvoiceList]>

    func setMinFee(_ fee: Quark)

    func getMinFee() -> Quark?
    
    func getOrCreateCID() -> String
    
    func setMinApiVersion(apiVersion: Int) -> Promise<Int>

    func getMinApiVersion() -> Promise<Int?>

    func clearStorage() -> Promise<Void>
}
