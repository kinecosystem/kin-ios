//
//  SubtitleTableViewCell.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 17/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        detailTextLabel?.minimumScaleFactor = 0.5
        detailTextLabel?.adjustsFontSizeToFitWidth = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
