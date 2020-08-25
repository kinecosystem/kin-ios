//
//  PaymentFlowViewController.swift
//  KinUX
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

public class PaymentFlowViewController: UIViewController, Navigator {

    private var paymentView: PaymentConfirmationView?

    private var viewModel: PaymentFlowViewModel?

    public var resultCallback: ((PaymentFlowViewModelResult) -> Void)?

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func attachViewModel(_ viewModel: PaymentFlowViewModel) {
        self.viewModel = viewModel
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        viewModel?.addStateUpdateListener { state in
            switch state {
            case .`init`:
                break
            case .confirmation(let appIcon,
                               let amount,
                               let appName,
                               let newBalanceAfter):
                self.paymentView = PaymentConfirmationView(merchantName: appName,
                                                           merchantIcon: UIImage(data: appIcon ?? Data()) ?? UIImage(),
                                                           amount: amount,
                                                           newBalance: newBalanceAfter,
                                                           delegate: self)
                self.view.addSubview(self.paymentView!)
            case .processing:
                self.paymentView?.state = .pending
            case .succes(let transactionHash):
                self.paymentView?.state = .confirmed
                let result = PaymentFlowViewModelResult.success(transactionHash: transactionHash)
                self.resultCallback?(result)
            case .error(let error, _):
                self.paymentView?.state = .error(message: error.message)
                let result = PaymentFlowViewModelResult.failure(error: error)
                self.resultCallback?(result)
            case .closed:
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }

        viewModel?.listenerReady()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        paymentView?.sizeToFit()
        paymentView?.center = view.center
    }
}

extension PaymentFlowViewController: PaymentConfirmationViewDelegate {
    public func paymentConfirmationPayNowTapped() {
        viewModel?.onConfirmTapped()
    }

    public func paymentConfirmationCancelTapped() {
        viewModel?.onCancelTapped {
            self.dismiss(animated: true, completion: nil)
        }
    }

    public func paymentConfirmationCloseTapped() {
        viewModel?.onCancelTapped {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
