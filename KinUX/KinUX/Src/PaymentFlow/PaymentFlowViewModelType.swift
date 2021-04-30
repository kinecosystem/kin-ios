//
//  PaymentFlowViewModelType.swift
//  KinViewModel
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

public struct PaymentFlowViewModelArgs {
    public let invoice: Invoice
    public let payerAccount: PublicKey
    public let appInfo: AppInfo
}

public enum PaymentFlowViewModelState: Equatable {
    case `init`
    case confirmation(appIcon: Data?, amount: Decimal, appName: String, newBalanceAfter: Decimal)
    case processing
    case succes(transactionHash: String)
    case error(error: PaymentFlowError, balance: Decimal)
    case closed
}

public enum PaymentFlowViewModelResult {
    case success(transactionHash: String)
    case failure(error: PaymentFlowError)
}

public struct PaymentFlowError: Error, Equatable {
    let reason: PaymentFlowFailureReason
    let message: String?

    public static func withReason(_ reason: PaymentFlowFailureReason) -> Self {
        return PaymentFlowError(reason: reason,
                                message: nil)
    }

    public static func fromError(_ error: Error) -> Self {
        return PaymentFlowError(reason: .errorMessage,
                                message: error.localizedDescription)
    }
}

public enum PaymentFlowFailureReason: Int {
    case errorMessage
    case canceled
    case alreadyPurchased
    case unknownFailure
    case unknownInvoice
    case unknownPayerAccount
    case insufficientBalance
    case misconfiguredRequest
    case deniedByService
    case sdkUpgradeRequired
    case badNetwork
}

public protocol PaymentFlowViewModelType: ViewModelType where ArgsType == PaymentFlowViewModelArgs, StateType == PaymentFlowViewModelState {

    func listenerReady()

    func onCancelTapped(onCompleted: () -> Void)

    func onConfirmTapped()
}
