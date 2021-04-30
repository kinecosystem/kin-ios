//
//  KinWalletInvoiceViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinUX
import KinDesign

class KinWalletInvoiceViewController: UIViewController {

    let invoice: Invoice
    let accountContext: KinAccountContext
    var paymentFlowController: PaymentFlowController?

    var invoiceDisplayable: InvoiceDisplayable {
        return invoice.displayable
    }

    lazy var tableViewController: InvoiceTableViewController = {
        let table = InvoiceTableViewController()
        table.invoice = self.invoiceDisplayable
        table.delegate = self
        return table
    }()

    init(accountContext: KinAccountContext, invoice: Invoice) {
        self.accountContext = accountContext
        self.invoice = invoice
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(tableViewController)

        view.addSubview(tableViewController.view)
    }
}

extension KinWalletInvoiceViewController: InvoiceTableViewControllerDelegate {
    
    func invoiceTablePayTapped() {
        paymentFlowController = PaymentFlowController(kinAccountContext: accountContext,
                                                      hostViewController: self)

        let data = UIImage(named: "ic_launcher")!.pngData()!

        let account = PublicKey(base58: "GsRAL8GEGbYxfDT53gSEXTxpThzuyrqmkg6iv4o2kC35")!
        let appInfo = AppInfo(
            appIdx: .testApp,
            kinAccount: account,
            name: "Test App",
            appIconData: data
        )

        let resultHandler = { [weak self] (result: PaymentFlowViewModelResult) in
            if case .success(_) = result {
                guard let navigationController = self?.navigationController,
                    let accountVCIndex = navigationController.viewControllers.firstIndex(where: { $0 is KinWalletAccountViewController
                })
                    else {
                    return
                }
                let vc = navigationController.viewControllers[accountVCIndex]
                navigationController.popToViewController(vc, animated: true)
            }
        }

        paymentFlowController?.confirmPaymentOfInvoice(
            invoice,
            payerAccount: accountContext.accountPublicKey,
            processingAppInfo: appInfo,
            onResult: resultHandler
        )
    }
}
