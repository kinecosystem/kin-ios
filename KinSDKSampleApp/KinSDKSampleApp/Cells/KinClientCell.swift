//
//  KinClientCell.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

protocol KinClientCellDelegate: class {
    func revealKeyStore()
    func startSendTransaction()
    func deleteAccountTapped()
    func recentTransactionsTapped()
    func getTestKin(cell: KinClientCell)
}

class KinClientCell: UITableViewCell {
    weak var kinClientCellDelegate: KinClientCellDelegate?
    var kinClient: KinClient!
    var kinAccount: KinAccount!
}

