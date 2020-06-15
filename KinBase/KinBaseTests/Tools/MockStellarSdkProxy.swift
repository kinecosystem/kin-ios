//
//  MockStellarSdkProxy.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk
@testable import KinBase

class MockStellarSdkProxy: StellarSdkProxy {

    var stubAccountResponse: AccountResponseEnum?
    var stubTransactionPostResponse: TransactionPostResponseEnum?
    var stubTransactionDetailsResponse: TransactionDetailsResponseEnum?
    var stubLedgerResponse: PageResponse<LedgerResponse>.ResponseEnum?
    var stubTransactionsResponse: PageResponse<TransactionResponse>.ResponseEnum?
    var stubAccountsStreamItem: AccountsStreamItem?
    var stubTransactionsStreamItem: TransactionsStreamItem?

    override func getAccountDetails(accountId: String, response: @escaping AccountResponseClosure) {
        response(stubAccountResponse!)
    }

    override func streamAccount(_ accountId: String) -> AccountsStreamItem {
        return stubAccountsStreamItem!
    }

    override func postTransaction(transactionEnvelope: String, response: @escaping TransactionPostResponseClosure) {
        response(stubTransactionPostResponse!)
    }

    override func getTransactionDetails(transactionHash: String, response: @escaping TransactionDetailsResponseClosure) {
        response(stubTransactionDetailsResponse!)
    }

    override func getLedgers(cursor: String? = nil, order: Order? = nil, limit: Int? = nil, response: @escaping PageResponse<LedgerResponse>.ResponseClosure) {
        response(stubLedgerResponse!)
    }

    override func getTransactions(forAccount accountId: String, from cursor: String? = nil, order: Order? = nil, limit: Int? = nil, response: @escaping PageResponse<TransactionResponse>.ResponseClosure) {
        response(stubTransactionsResponse!)
    }

    override func streamTransactions(for accountId: String, cursor: String?) -> TransactionsStreamItem {
        return stubTransactionsStreamItem!
    }
}
