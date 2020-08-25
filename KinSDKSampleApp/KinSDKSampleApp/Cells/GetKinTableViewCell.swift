//
//  GetKinTableViewCell.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class GetKinTableViewCell: KinClientCell {
    @IBOutlet weak var getKinButton: UIButton!

    override func tintColorDidChange() {
        super.tintColorDidChange()

        getKinButton.fill(with: tintColor)
    }

    override var kinClient: KinClient! {
        didSet {
            verifyGetKinButtonAvailability()
        }
    }

    @IBAction func getKinTapped(_ sender: Any) {
        kinClientCellDelegate?.getTestKin(cell: self)
    }

    func verifyGetKinButtonAvailability() {
        getKinButton.isEnabled = kinClient.network != .mainNet
    }
}
