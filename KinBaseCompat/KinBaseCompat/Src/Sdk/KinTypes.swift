//
//  KinTypes.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

/**
 A protocol to encapsulate the formation of the endpoint `URL` and the `Network`.
 */
public protocol ServiceProvider {

    /**
     The `URL` of the block chain node.
     */
    var url: URL { get }

    /**
     The `Network` to be used.
     */
    var network: Network { get }
}
/**
 Type for `Transaction` identifier.
 */
public typealias TransactionId = String

/**
Closure type used by the generate transaction API upon completion, which contains a `TransactionEnvelope`
in case of success, or an error in case of failure.
*/
public typealias GenerateTransactionCompletion = (TransactionEnvelope?, Error?) -> Void

/**
 Closure type used by the send transaction API upon completion, which contains a `TransactionId` in
 case of success, or an error in case of failure.
 */
public typealias SendTransactionCompletion = (TransactionId?, Error?) -> Void
/**
 Closure type used by the balance API upon completion, which contains the `Balance` in case of
 success, or an error in case of failure.
 */
public typealias BalanceCompletion = (Kin?, Error?) -> Void

/**
 `AccountStatus` indicates the status of a `KinAccount`.
 */
public enum AccountStatus : Int {

    /**
     The `KinAccount` has not been created on the blockchain network.
     */
    case notCreated

    /**
     The `KinAccount` has been created on the blockchain network.
     */
    case created
}
//internal let AssetUnitDivisor: UInt64
/**
 Kin is the native currency of the network.
 */
public typealias Kin = Decimal

/**
 Quark is the smallest amount unit. It is one-hundred-thousandth of a Kin: `1/100000` or `0.00001`.
 */
public typealias Quark = UInt32
//@available(*, deprecated, renamed: "Quark")
public typealias Stroop = Quark

let AssetUnitDivisor: UInt64 = 100_000

/**
 `PaymentInfo` wraps all information related to a payment transaction.
 */
public struct PaymentInfo {

    /**
     Date of creation of the transaction.
     */
    public var createdAt: Date {
        return Date(timeIntervalSince1970: kinPayment.timestamp)
    }

    /**
     True if this account received this payment.
     False if this account sent this payment.
     */
    public var credit: Bool {
        return account == destination
    }

    /**
     True if this account sent this payment.
     False if this account received this payment.
     */
    public var debit: Bool {
        return !credit
    }

    /**
     Public address of the account from which this payment originates.
     */
    public var source: String {
        return kinPayment.sourceAccountId
    }

    /**
     Identification of this `PaymentInfo` transaction.
     */
    public var hash: String {
        return kinPayment.id.transactionHash.description
    }

    /**
     Amount in `Kin` of the payment
     */
    public var amount: Kin {
        return kinPayment.amount as Kin
    }

    /**
     Public address of the destination account of this payment.
     */
    public var destination: String {
        return kinPayment.destAccountId
    }

    /**
     Memo information - if any - as a `String` attached to this payment.
     */
    public var memoText: String? {
        return kinPayment.memo.text
    }

    /**
     Memo information - if any - as a `Data` object attached to this payment.
     */
    public var memoData: Data? {
        return kinPayment.memo.data
    }

    let kinPayment: KinPayment
    let account: KinBase.KinAccount.Id

    init(kinPayment: KinPayment, account: KinBase.KinAccount.Id) {
        self.kinPayment = kinPayment
        self.account = account
    }
}

/**
 Ensures the validity of the app id from the host application.

 The host application should pass a four character string. The string can only contain any combination
 of lowercase letters, uppercase letters and digits.
 */
public struct AppId {

    /**
     Value of the `AppId`
     */
    public let value: String

    /**
     Initialize the `AppId`

     - Parameter value: a string value that can only be 4 characters long and only contain alphanumeric characters.

     - Throws: `KinError.invalidAppId` if the string parameter does not meet the requirements
     */
    public init(_ value: String) throws {
        // Lowercase and uppercase letters + numbers
        let charSet = CharacterSet.lowercaseLetters.union(.uppercaseLetters).union(.decimalDigits)

        guard value == value.trimmingCharacters(in: charSet.inverted),
            value.rangeOfCharacter(from: charSet) != nil,
            (value.utf8.count == 4 || value.utf8.count == 3)
            else {
                throw KinError.invalidAppId
        }

        self.value = value
    }
}

extension AppId {
    /**
     Returns the prefix vased on the `AppId` value used to create the `Memo` of payment transactions.
     */
    public var memoPrefix: String {
        return "1-\(value)-"
    }
}

extension Memo {
    /**
     Prefixes the given `Memo` of the given `AppId` if it's not there already.

     - Parameter appId: `AppId` to prefix the `Memo` with.
     - Parameter to: `String` value to prefix.

     - Returns: the `Memo` value prefixed with the "1-[appId]" if the value does not contain it already.
     */
    public static func prependAppIdIfNeeded(_ appId: AppId, to memo: String) -> String {
        if let regex = try? NSRegularExpression(pattern: "^1-[A-z0-9]{3,4}-.*") {
            let range = NSRange(location: 0, length: memo.count)

            if regex.firstMatch(in: memo, options: [], range: range) != nil {
                return memo
            }
        }

        return appId.memoPrefix + memo
    }
}
