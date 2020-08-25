//
//  TransactionTableViewCell.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 19/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    let addressLabel = UILabel()
    let amountLabel = UILabel()
    let dateLabel = UILabel()
    let memoLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let marginX = contentView.layoutMargins.left
        let marginY = contentView.layoutMargins.top

        addressLabel.minimumScaleFactor = 0.5
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.baselineAdjustment = .alignCenters
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressLabel)
        addressLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        addressLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        amountLabel.minimumScaleFactor = 0.5
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.baselineAdjustment = .alignCenters
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(amountLabel)
        amountLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: marginY).isActive = true
        amountLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        amountLabel.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.4).isActive = true

        dateLabel.textAlignment = .right
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.baselineAdjustment = .alignCenters
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: amountLabel.topAnchor).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: marginX).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        memoLabel.minimumScaleFactor = 0.5
        memoLabel.adjustsFontSizeToFitWidth = true
        memoLabel.baselineAdjustment = .alignCenters
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(memoLabel)
        memoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: marginY).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        memoLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
