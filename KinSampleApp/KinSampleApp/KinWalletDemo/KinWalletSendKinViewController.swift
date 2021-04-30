//
//  KinWalletSendKinViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

class KinWalletSendKinViewController: UIViewController {

    lazy var destTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Destination Address"
        return field
    }()

    lazy var destLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.destTextField.addSubview(line)
        return line
    }()

    lazy var amountTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Amount"
        field.keyboardType = .decimalPad
        return field
    }()

    lazy var amountLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.amountTextField.addSubview(line)
        return line
    }()

    lazy var feeTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Fee"
        field.keyboardType = .decimalPad
        return field
    }()

    lazy var feeLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.feeTextField.addSubview(line)
        return line
    }()

    lazy var memoTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Transaction Memo"
        return field
    }()

    lazy var memoLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.memoTextField.addSubview(line)
        return line
    }()

    lazy var sendButton: PrimaryButton = {
        let button = PrimaryButton(frame: .zero)
        button.setTitle("Send Kin", for: .normal)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .kinPurple
        spinner.center = self.view.center
        return spinner
    }()

    let accountContext: KinAccountContext

    init(accountContext: KinAccountContext) {
        self.accountContext = accountContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        view.addSubview(destTextField)
        view.addSubview(amountTextField)
        view.addSubview(feeTextField)
        view.addSubview(memoTextField)
        view.addSubview(sendButton)
        view.addSubview(loadingSpinner)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let height: CGFloat = 50

        destTextField.frame = CGRect(x: .defaultPadding,
                                     y: .defaultPadding + view.safeAreaInsets.top,
                                     width: view.bounds.width - .defaultPadding * 2,
                                     height: height)
        destLine.frame = CGRect(x: 0,
                                y: destTextField.frame.height - 1,
                                width: destTextField.frame.width,
                                height: 0.5)

        amountTextField.frame = CGRect(x: .defaultPadding,
                                       y: .defaultPadding + destTextField.frame.maxY,
                                       width: view.bounds.width - .defaultPadding * 2,
                                       height: height)
        amountLine.frame = CGRect(x: 0,
                                  y: amountTextField.frame.height - 1,
                                  width: amountTextField.frame.width,
                                  height: 0.5)

        feeTextField.frame = CGRect(x: .defaultPadding,
                                    y: .defaultPadding + amountTextField.frame.maxY,
                                    width: view.bounds.width - .defaultPadding * 2,
                                    height: height)
        feeLine.frame = CGRect(x: 0,
                               y: feeTextField.frame.height - 1,
                               width: feeTextField.frame.width,
                               height: 0.5)

        memoTextField.frame = CGRect(x: .defaultPadding,
                                    y: .defaultPadding + feeTextField.frame.maxY,
                                    width: view.bounds.width - .defaultPadding * 2,
                                    height: height)
        memoLine.frame = CGRect(x: 0,
                               y: memoTextField.frame.height - 1,
                               width: memoTextField.frame.width,
                               height: 0.5)

        sendButton.sizeToFit()
        sendButton.center = view.center
        sendButton.frame.origin.y = view.bounds.height - view.safeAreaInsets.bottom - .defaultPadding - sendButton.frame.height
    }

    @objc func sendButtonTapped() {
        guard let amount = Kin(string: amountTextField.text ?? ""),
            let dest = destTextField.text,
            let destAccount = PublicKey(base58: dest),
            let memo = memoTextField.text else {
                presentSimpleAlert(message: "Invalid Input")
            return
        }

        loadingSpinner.startAnimating()

        let item = KinPaymentItem(amount: amount, destAccount: destAccount)
        accountContext.sendKinPayment(item, memo: KinMemo(text: memo))
            .then(on: .main) { [weak self] payment in
                self?.loadingSpinner.stopAnimating()
                self?.presentSimpleAlert(message: "Transaction Succeed", callback: {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
            .catch(on: .main) { [weak self] error in
                self?.loadingSpinner.stopAnimating()
                self?.presentSimpleAlert(title: "Tranasction Error", message: error.localizedDescription)
            }
    }
}
