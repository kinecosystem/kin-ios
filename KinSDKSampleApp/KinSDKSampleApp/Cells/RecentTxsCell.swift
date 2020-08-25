//
//  RecentTxsCell.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit

class RecentTxsCell: KinClientCell {
    @IBOutlet weak var recentTxsButton: UIButton!

    override func tintColorDidChange() {
        super.tintColorDidChange()

        recentTxsButton.fill(with: tintColor)
    }

    @IBAction func recentTxsTapped(_ sender: Any) {
        kinClientCellDelegate?.recentTransactionsTapped()
    }
}
