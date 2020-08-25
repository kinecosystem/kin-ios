//
//  BalanceTableViewCell.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class BalanceTableViewCell: KinClientCell {
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceActivityIndicator: UIActivityIndicatorView!
    var balance: Decimal = 0 {
        didSet {
            DispatchQueue.main.async {
                if let formattedBalance = self.numberFormatter.string(from: self.balance as NSDecimalNumber) {
                    self.balanceLabel.text = "\(formattedBalance) KIN"
                }
            }
        }
    }

    var ongoingRequests = 0 {
        didSet {
            self.refreshButton.isEnabled = ongoingRequests == 0
        }
    }

    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = ""

        return f
    }()

    override var kinAccount: KinAccount! {
        didSet {
            refreshBalance(self)
        }
    }

    @IBAction func refreshBalance(_ sender: Any) {
        ongoingRequests += 1
        balanceActivityIndicator.startAnimating()
        kinAccount.balance { [weak self] balance, error in
            DispatchQueue.main.async {
                self?.balanceActivityIndicator.stopAnimating()
                defer {
                    self?.ongoingRequests -= 1
                }

                guard let balance = balance,
                    error == nil else {
                        self?.balanceLabel.text = "Error"
                        return
                }

                self?.balance = balance
                if let formattedBalance = self?.numberFormatter.string(from: balance as NSDecimalNumber) {
                    self?.balanceLabel.text = "\(formattedBalance) KIN"
                }
            }
        }
    }
}
