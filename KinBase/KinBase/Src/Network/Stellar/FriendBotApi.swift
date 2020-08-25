//
//  FriendBotApi.swift
//  KinBase
//
//  Created by Kik Interactive Inc. on 2020-03-30.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import stellarsdk

class FriendBotApi {
    enum Errors: Error, Equatable {
        case invalidJson
    }

    private let urlSession: URLSession
    private let friendBotUrl: URL
    private let jsonDecoder = JSONDecoder()

    init(urlSession: URLSession = URLSession.shared,
         friendBotUrl: URL = URL(string: "https://friendbot-testnet.kininfrastructure.com/")!) {
        self.urlSession = urlSession
        self.friendBotUrl = friendBotUrl
    }

    func fundAccount(request: CreateAccountRequest,
                     completion: @escaping (CreateAccountResponse) -> Void) {
        let url = friendBotUrl.appendingPathComponent("fund")
        let components = NSURLComponents(url: url,
                                         resolvingAgainstBaseURL: false)
        
        let item = URLQueryItem(name: "addr",
                                value: request.accountId)

        components?.queryItems = [item]

        let completeWithError: (Error) -> Void = { error in
            let response = CreateAccountResponse(result: .transientFailure,
                                                 error: error,
                                                 account: nil)
            completion(response)
        }

        let task = urlSession.dataTask(with: components!.url!) { data, httpResponse, error in
            guard error == nil else {
                completeWithError(error!)
                return
            }

            let response = CreateAccountResponse(result: .ok,
                                                 error: nil,
                                                 account: nil)
            completion(response)
        }

        task.resume()
    }
}

extension FriendBotApi: KinAccountCreationApi {
    func createAccount(request: CreateAccountRequest,
                       completion: @escaping (CreateAccountResponse) -> Void) {
        let components = NSURLComponents(url: friendBotUrl,
                                         resolvingAgainstBaseURL: false)

        let item = URLQueryItem(name: "addr",
                                value: request.accountId)

        components?.queryItems = [item]

        let completeWithError: (Error) -> Void = { error in
            let response = CreateAccountResponse(result: .transientFailure,
                                                 error: error,
                                                 account: nil)
            completion(response)
        }

        let task = urlSession.dataTask(with: components!.url!) { data, httpResponse, error in
            guard error == nil else {
                completeWithError(error!)
                return
            }

            do {
                guard let data = data else {
                    completeWithError(Errors.invalidJson)
                    return
                }

                let transactionResponse = try self.jsonDecoder.decode(CreateAccountTransactionResponse.self,
                                                                      from: data)

                guard let accountEntry = transactionResponse.accountEntry,
                    accountEntry.accountID.accountId == request.accountId else {
                    completeWithError(Errors.invalidJson)
                    return
                }

                let kinAccount = KinAccount(key: KinAccount.Key(publicKey: accountEntry.accountID),
                                            balance: KinBalance(Quark(accountEntry.balance).kin),
                                            status: .registered,
                                            sequence: accountEntry.sequenceNumber)

                let response = CreateAccountResponse(result: .ok,
                                                     error: nil,
                                                     account: kinAccount)
                completion(response)
            } catch let error {
                completeWithError(error)
            }
        }

        task.resume()
    }
}

private extension FriendBotApi {
    struct CreateAccountTransactionResponse: Decodable {
        var accountEntry: AccountEntryXDR?

        private enum CodingKeys: String, CodingKey {
            case transactionMeta = "result_meta_xdr"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let encodedMeta = try values.decode(String.self, forKey: .transactionMeta)
            let metaData = Data(base64Encoded: encodedMeta)
            let transactionMeta = try XDRDecoder.decode(CreateAccountTransactionMeta.self, data: metaData ?? Data())
            transactionMeta.operations.forEach { (operation) in
                operation.changes.ledgerEntryChanges.forEach { (change) in
                    if case let .created(entry) = change,
                        case let .account(account) = entry.data {
                        accountEntry = account
                        return
                    }
                }
            }
        }
    }

    struct CreateAccountTransactionMeta: XDRDecodable {
        var discriminant: Int32
        var operations: [OperationMetaXDR]

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            discriminant = try container.decode(Int32.self)
            operations = try decodeArray(type: OperationMetaXDR.self, dec: decoder)
        }
    }
}
