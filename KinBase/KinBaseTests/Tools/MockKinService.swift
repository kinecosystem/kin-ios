//
//  MockKinService.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises
@testable import KinBase

class MockKinService: KinServiceType {

    var stubGetAccountResult: KinAccount?
    var stubGetAccountResultPromise: Promise<KinAccount>?
    var stubCreateAccountResult: KinAccount?
    var stubGetTransactionResult: KinTransaction?
    var stubBuildAndSignTransactionResult: KinTransaction?
    var stubSignTransactionResult: Promise<KinTransaction>?
    var stubSubmitTransactionResult: Promise<KinTransaction>?
    var stubBuildSignAndSubmitTransactionResult: Promise<KinTransaction>?
    var stubStreamAccountObservable: Observable<KinAccount>?
    var stubStreamTransactionObservable: Observable<KinTransaction>?
    var stubGetLatestTransactions: [KinTransaction]?
    var stubGetTransactionPageResult: [KinTransaction]?
    var stubCanWhitelistTransactionResult: Bool?
    var stubMinFee: Quark?
    var stubResolveTokenAccounts: Promise<[AccountDescription]>?

    init() { }

    func getAccount(account: PublicKey) -> Promise<KinAccount> {
        if stubGetAccountResult != nil {
            return .init(stubGetAccountResult!)
        }

        return stubGetAccountResultPromise!
    }
    
    func mergeTokenAccounts(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<Void> {
        return .init(())
    }

    func createAccount(account: PublicKey, signer: KeyPair, appIndex: AppIndex?) -> Promise<KinAccount> {
        return .init(stubCreateAccountResult!)
    }

    func streamAccount(account: PublicKey) -> Observable<KinAccount> {
        return stubStreamAccountObservable!
    }

    func getLatestTransactions(account: PublicKey) -> Promise<[KinTransaction]> {
        return .init(stubGetLatestTransactions!)
    }

    func getTransactionPage(account: PublicKey, pagingToken: String, order: TransactionOrder) -> Promise<[KinTransaction]> {
        return .init(stubGetTransactionPageResult!)
    }

    func getTransaction(transactionHash: KinTransactionHash) -> Promise<KinTransaction> {
        return .init(stubGetTransactionResult!)
    }

    func getMinFee() -> Promise<Quark> {
        return .init(stubMinFee!)
    }

    func canWhitelistTransactions() -> Promise<Bool> {
        return .init(stubCanWhitelistTransactionResult!)
    }
    
    func buildAndSignTransaction(ownerKey: KeyPair, sourceKey: PublicKey, nonce: Int64, paymentItems: [KinPaymentItem], memo: KinMemo, fee: Quark) -> Promise<KinTransaction> {
        return .init(stubBuildAndSignTransactionResult!)
    }

    func signTransaction(transaction: KinTransaction) -> Promise<KinTransaction> {
        return stubSignTransactionResult!
    }
    
    func submitTransaction(transaction: KinTransaction) -> Promise<KinTransaction> {
        return stubSubmitTransactionResult!
    }
    
    func buildSignAndSubmitTransaction(buildAndSignTransaction: @escaping () -> Promise<KinTransaction>) -> Promise<KinTransaction> {
        return buildAndSignTransaction()
            .then { it in self.submitTransaction(transaction: it)}
    }

    func streamNewTransactions(account: PublicKey) -> Observable<KinTransaction> {
        return stubStreamTransactionObservable!
    }
    
    func resolveTokenAccounts(account: PublicKey) -> Promise<[AccountDescription]> {
        return stubResolveTokenAccounts ?? Promise { [AccountDescription(publicKey: account, balance: nil, closeAuthority: nil)] }
    }
    
    func invalidateRecentBlockHashCache() {
        
    }
    
    func invalidateTokenAccountsCache(account: PublicKey) {
        
    }
}
