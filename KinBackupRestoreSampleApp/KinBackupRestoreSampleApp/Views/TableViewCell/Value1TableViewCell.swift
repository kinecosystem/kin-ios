//
//  Value1TableViewCell.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 17/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit

class Value1TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
