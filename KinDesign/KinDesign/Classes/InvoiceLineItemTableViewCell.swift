//
//  InvoiceLineItemTableViewCell.swift
//  KinDesign
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit

public class InvoiceLineItemTableViewCell: UITableViewCell {

    public struct Constants {
        public static let defaultCellHeight: CGFloat = 71
    }

    public lazy var titleLabel: PrimaryLabel = {
        let label = PrimaryLabel(frame: .zero)
        return label
    }()

    public lazy var descriptionLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: .zero)
        label.numberOfLines = 2
        return label
    }()

    public lazy var amountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.size = .small
        return view
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(amountView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        amountView.sizeToFit()
        amountView.frame.origin = CGPoint(x: contentView.bounds.width - amountView.bounds.width - 20,
                                          y: 15)

        titleLabel.frame = CGRect(x: 20,
                                  y: 15,
                                  width: amountView.frame.minX - 40 - 20,
                                  height: 20)

        descriptionLabel.frame = CGRect(x: 20,
                                        y: titleLabel.frame.maxY + 5,
                                        width: titleLabel.frame.width,
                                        height: 0)
        descriptionLabel.sizeToFit()
    }

    public static func cellHeight(width: CGFloat, amount: Decimal, description: String) -> CGFloat {
        let amountView = KinAmountView(frame: .zero)
        amountView.size = .small
        amountView.amount = amount
        amountView.sizeToFit()

        let maxDescriptionWidth = width - amountView.frame.width - 20 * 2 - 40
        let label = SecondaryLabel(frame: CGRect(x: 0, y: 0, width: maxDescriptionWidth, height: 0))
        label.text = description
        label.numberOfLines = 2
        label.sizeToFit()

        return 40 + label.frame.height + 15
    }
}
