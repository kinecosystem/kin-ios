//
//  DeleteAccountCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 26/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

class DeleteAccountCell: KinClientCell {
    @IBOutlet weak var deleteAccountButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        deleteAccountButton.fill(with: .red)
    }

    @IBAction func deleteAccountTapped(_ sender: Any) {
        kinClientCellDelegate?.deleteAccountTapped()
    }
}
