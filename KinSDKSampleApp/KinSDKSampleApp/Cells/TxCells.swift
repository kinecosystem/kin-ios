//
//  TxCells.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit

class TxCell: KinClientCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
}

class IncomingTxCell: TxCell {
}

class OutgoingTxCell: TxCell {
}

