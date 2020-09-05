//
//  PaymentFlowController.swift
//  KinUX
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinBase

public class PaymentFlowController {
    private let hostViewController: UIViewController
    private let kinAccountContext: KinAccountContext

    private var transition: SheetTransition?

    public init(kinAccountContext: KinAccountContext,
                hostViewController: UIViewController) {
        self.kinAccountContext = kinAccountContext
        self.hostViewController = hostViewController
    }

    public func confirmPaymentOfInvoice(_ invoice: Invoice,
                                        payerAccount: KinAccount.Id,
                                        processingAppInfo: AppInfo,
                                        onResult: @escaping (PaymentFlowViewModelResult) -> Void) {
        let vc = PaymentFlowViewController()
        vc.resultCallback = onResult

        let viewModel = PaymentFlowViewModel(navigator: vc,
                                             args: .init(invoice: invoice,
                                                         payerAccountId: payerAccount,
                                                         appInfo: processingAppInfo),
                                             kinAccountContext: kinAccountContext,
                                             logger: kinAccountContext.env.logger)

        vc.attachViewModel(viewModel)

        presentPaymentFlow(vc)
    }

    private func presentPaymentFlow(_ vc: UIViewController) {
        transition = SheetTransition(covering: .custom(height: 339))

        let nav = KinNavigationController()
        nav.transitioningDelegate = transition
        nav.modalPresentationStyle = .custom
        nav.navigationBar.isHidden = true

        nav.pushViewController(vc, animated: false)

        hostViewController.present(nav, animated: true, completion: nil)
    }
}
