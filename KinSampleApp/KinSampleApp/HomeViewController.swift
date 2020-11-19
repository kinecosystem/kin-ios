//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc. on 2020-05-15.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinDesign
import KinUX
import KinBase

class HomeViewController: UIViewController {

    lazy var kinWalletDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kin Wallet Demo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(kinWalletDemoButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    lazy var kinDesignButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kin Design Demo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(kinDesignButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    lazy var kinDesignInvoiceTableButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kin Design - Invoice Table", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(kinDesignInvoiceButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    lazy var kinUXPaymentFlowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kin UX - Payment Flow", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(kinUXPaymentFlowTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    var paymentFlowController: PaymentFlowController?
    var kinAccountContext: KinAccountContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        // setup test account (GDV4TKOCDBHB3XGCKAXWYETQRIN4RTJKSD6FQV43E2AUHORR56B4YDC4)
        let key = try! KinAccount.Key(secretSeed: "SA7PKYPSJHOU5I6YTU6OJIOLZXREBCX6N5QK7USSXQCKS65SWSQPIMA7")
        kinAccountContext = try! KinAccountContext
            .Builder(env: KinEnvironment.Agora.testNet(testMigration: AppDelegate.enableTestMigration))
                   .importExistingPrivateKey(key)
                   .build()

               print(kinAccountContext!.accountId)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let padding = StandardConstants.sidePadding

        kinWalletDemoButton.center = view.center
        kinWalletDemoButton.frame.origin.y = view.safeAreaInsets.top + padding

        kinDesignButton.center = view.center
        kinDesignButton.frame.origin.y = kinWalletDemoButton.frame.maxY + padding

        kinDesignInvoiceTableButton.center = view.center
        kinDesignInvoiceTableButton.frame.origin.y = kinDesignButton.frame.maxY + padding

        kinUXPaymentFlowButton.center = view.center
        kinUXPaymentFlowButton.frame.origin.y = kinDesignInvoiceTableButton.frame.maxY + padding
    }

    @objc private func kinWalletDemoButtonTapped() {
        let vc = KinWalletDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func kinDesignButtonTapped() {
        let vc = KinDesignViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func kinDesignInvoiceButtonTapped() {
        let vc = KinDesignInvoiceTableView()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func kinUXPaymentFlowTapped() {
        paymentFlowController = PaymentFlowController(kinAccountContext: kinAccountContext!,
                                                      hostViewController: self)

        let invoice = try! Invoice(lineItems: [LineItem(title: "Test Title", amount: Kin(100))])
        let data = UIImage(named: "ic_launcher")!.pngData()!

        let appInfo = AppInfo(appIdx: .testApp,
                              kinAccountId: "GDV4TKOCDBHB3XGCKAXWYETQRIN4RTJKSD6FQV43E2AUHORR56B4YDC4",
                              name: "Test App",
                              appIconData: data)

        paymentFlowController?.confirmPaymentOfInvoice(invoice,
                                                       payerAccount: kinAccountContext!.accountId,
                                                       processingAppInfo: appInfo,
                                                       onResult: { result in
                                                        print(result)
        })
    }
}
