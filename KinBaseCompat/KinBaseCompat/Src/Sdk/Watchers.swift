//
//  Watchers.swift
//  KinBaseCompat
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `PaymentWatch` watches for `PaymentInfo` changes of a given account and sends the new `PaymentInfo` value when one is available.
 Refer to `KinAccount.watchPayments`.
 */
public class PaymentWatch {

    /**
     The `Observable` that will be signalled when a new `PaymentInfo` value is available.
     */
    public let emitter: Observable<PaymentInfo>

    /**
     The id of the last payment info after which we want to be signalled of new payments.
     */
    public var cursor: String?

    init(cursor: String? = nil, emitter: Observable<PaymentInfo>) {
        self.cursor = cursor
        self.emitter = emitter
    }
}

/**
 `BalanceWatch` watches for `Kin` balance changes of a given account and sends the new `Kin` value when one is available.
 Refer to `KinAccount.watchBalance`.

 ```
 if let balanceWatcher = try? account.watchBalance(nil) {
    balanceWatcher.emitter.on { (balance: Kin) in
        print("The account's balance has changed: \(balance) Kin")
    }
 }
 ```
 */
public class BalanceWatch {

    /**
     The `StatefulObserver` that will be signalled when a new `Kin` value is available.
    */
    public let emitter: StatefulObserver<Kin>

    init(emitter: StatefulObserver<Kin>) {
        self.emitter = emitter
    }
}
