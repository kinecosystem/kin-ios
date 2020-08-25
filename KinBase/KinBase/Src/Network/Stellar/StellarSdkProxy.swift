//
//  StellarSdkProxy.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

/// A proxy layer for `StellarSDK` to make testing easier, as classes in `StellarSDK` are not open for overrides.
public class StellarSdkProxy {

    let network: KinNetwork
    let sdk: StellarSDK

    init(network: KinNetwork) {
        self.network = network
        self.sdk = StellarSDK(withHorizonUrl: network.horizonUrl)
    }

    func getAccountDetails(accountId: String,
                           response: @escaping AccountResponseClosure) {
        sdk.accounts.getAccountDetails(accountId: accountId,
                                       response: response)
    }

    func streamAccount(_ accountId: String) -> AccountsStreamItem {
        return sdk.accounts.stream(accountId: accountId)
    }

    func postTransaction(transactionEnvelope: String,
                         response: @escaping TransactionPostResponseClosure) {
        sdk.transactions.postTransaction(transactionEnvelope: transactionEnvelope,
                                         response: response)
    }

    func getTransactionDetails(transactionHash: String,
                               response: @escaping TransactionDetailsResponseClosure) {
        sdk.transactions.getTransactionDetails(transactionHash: transactionHash,
                                               response: response)
    }

    func getLedgers(cursor: String? = nil,
                    order: Order? = nil,
                    limit: Int? = nil,
                    response: @escaping PageResponse<LedgerResponse>.ResponseClosure) {
        sdk.ledgers.getLedgers(cursor: cursor,
                               order: order,
                               limit: limit,
                               response: response)
    }

    func getTransactions(forAccount accountId: String,
                         from cursor: String? = nil,
                         order: Order? = nil,
                         limit: Int? = nil,
                         response: @escaping PageResponse<TransactionResponse>.ResponseClosure) {
        sdk.transactions.getTransactions(forAccount: accountId,
                                         from: cursor,
                                         order: order,
                                         limit: limit,
                                         response: response)
    }

    func streamTransactions(for accountId: String,
                            cursor: String?) -> TransactionsStreamItem {
        return sdk.transactions.stream(for: .transactionsForAccount(account: accountId,
                                                                    cursor: cursor))
    }
}
