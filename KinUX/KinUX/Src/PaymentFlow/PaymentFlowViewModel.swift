//
//  PaymentFlowViewModel.swift
//  KinUX
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

public class PaymentFlowViewModel: BaseViewModel<PaymentFlowViewModelArgs, PaymentFlowViewModelState>, PaymentFlowViewModelType {

    private let navigator: Navigator
    private let args: PaymentFlowViewModelArgs
    private let kinAccountContext: KinAccountContext
    private var account: KinAccount?
    private let logger: KinLoggerFactory
    private lazy var log: KinLogger = {
        logger.getLogger(name: String(describing: self))
    }()

    public init(navigator: Navigator,
                args: PaymentFlowViewModelArgs,
                kinAccountContext: KinAccountContext,
                logger: KinLoggerFactory) {
        self.navigator = navigator
        self.args = args
        self.kinAccountContext = kinAccountContext
        self.logger = logger
        
        super.init()
        
        log.info(msg: "Navigated to: \(self)")

        updateState { _ in .`init` }
    }

    public override func getDefaultState() -> StateType {
        return .`init`
    }

    public override func onStateUpdated(_ state: StateType) {
        log.info(msg: "\(#function):\(state)")
        if state == .`init` {
            setup()
        }
    }

    private func setup() {
        kinAccountContext.getAccount()
            .then { account in
                self.account = account

                DispatchQueue.main.sync {
                    self.updateState { _ in
                        PaymentFlowViewModelState.confirmation(appIcon: self.args.appInfo.appIconData,
                                                               amount: self.args.invoice.total,
                                                               appName: self.args.appInfo.name,
                                                               newBalanceAfter: (self.account?.balance.amount ?? Kin(0)) - self.args.invoice.total)
                    }
                }
            }
    }

    public func listenerReady() {
//        updateState { _ in
//            PaymentFlowViewModelState.confirmation(appIcon: args.appInfo.appIconData,
//                                                   amount: args.invoice.total,
//                                                   appName: args.appInfo.name,
//                                                   newBalanceAfter: (account?.balance.amount ?? Kin(0)) - args.invoice.total)
//        }
    }

    public func onCancelTapped(onCompleted: () -> Void) {
        log.info(msg: #function)
        // TODO use real balance
        updateState { _ in .closed }
    }

    public func onConfirmTapped() {
        log.info(msg: #function)
        updateState { _ in
            weak var weakSelf = self
            kinAccountContext.payInvoice(processingAppIdx: args.appInfo.appIdx,
                                         destinationAccount: args.appInfo.kinAccountId,
                                         invoice: args.invoice)
                .then { (kinPayment) in
                    DispatchQueue.main.sync {
                        weakSelf?.updateState { _ in
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                                weakSelf?.updateState { _ in
                                    return .closed
                                }
                            }

                            return .succes(transactionHash: kinPayment.id.transactionHash.description)
                        }
                    }
                }
                .catch { error in
                    DispatchQueue.main.sync {
                        weakSelf?.updateState { _ in
                            return .error(error: .fromError(error),
                                          balance: weakSelf?.account?.balance.amount ?? Kin(0))
                        }
                    }
                }

            return .processing
        }
    }
}
