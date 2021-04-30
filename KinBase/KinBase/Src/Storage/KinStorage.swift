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
    func hasPrivateKey(_ account: PublicKey) -> Bool
    
    func addAccount(_ account: KinAccount) throws -> KinAccount

//    func addAccount(_ account: KinAccount) -> Promise<KinAccount>

    func getAccount(_ account: PublicKey) -> Promise<KinAccount?>

    func updateAccount(_ account: KinAccount) -> Promise<KinAccount>

    func removeAccount(account: PublicKey) -> Promise<Void>

    func getAllAccountIds() -> Promise<[PublicKey]>

    func advanceSequence(account: PublicKey) -> Promise<KinAccount>

    func deductFromAccountBalance(account: PublicKey, amount: Kin) -> Promise<KinAccount>

    func storeTransactions(account: PublicKey, transactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func getStoredTransactions(account: PublicKey) -> Promise<KinTransactions?>


    func upsertNewTransactions(account: PublicKey, newTransactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func upsertOldTransactions(account: PublicKey, oldTransactions: [KinTransaction]) -> Promise<[KinTransaction]>

    func insertNewTransaction(account: PublicKey, newTransaction: KinTransaction) -> Promise<[KinTransaction]>

    func addInvoiceLists(account: PublicKey, invoiceLists: [InvoiceList]) -> Promise<[InvoiceList]>

    func getInvoiceListsMapForAccountId(account: PublicKey) -> Promise<[InvoiceList.Id: InvoiceList]>

    func setMinFee(_ fee: Quark)

    func getMinFee() -> Quark?
    
    func getOrCreateCID() -> String
    
    func setMinApiVersion(apiVersion: Int) -> Promise<Int>

    func getMinApiVersion() -> Promise<Int?>

    func clearStorage() -> Promise<Void>
}
