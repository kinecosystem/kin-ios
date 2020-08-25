//
//  PaymentRecordView.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-11-28.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit

internal class PaymentRecordView: UIView {
    private struct Constants {
        static let viewHeight: CGFloat = 62
        static let imageSize = CGSize(width: 77, height: 77)
        static let sidePadding: CGFloat = 24
        static let textAreaLeftPadding: CGFloat = 12
        static let titleLabelHeight: CGFloat = 23
        static let descriptionLabelHeight: CGFloat = 19
        static let descriptionLabelTopPadding: CGFloat = 8
    }

    public static let height = Constants.viewHeight

    public lazy var kinIconView: OrderCellTimelineView = {
        let view = OrderCellTimelineView(frame: CGRect(origin: .zero,
                                                       size: CGSize(width: 48,
                                                                    height: Constants.viewHeight)))
        view.backgroundColor = .white
        view.icon = UIImage(named: "account_screen/kin_grey_icon",
                            in: Bundle.kinDesign(),
                            compatibleWith: nil)
        return view
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .kinPurple
        return label
    }()

    public lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14)
        label.textColor = .kinBlack
        return label
    }()

    public lazy var balanceChangeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .kinPurple
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(kinIconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(balanceChangeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: Constants.viewHeight)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.frame = CGRect(x: kinIconView.frame.maxY,
                                  y: 10,
                                  width: 300,
                                  height: Constants.titleLabelHeight)

        descriptionLabel.frame = CGRect(x: kinIconView.frame.maxY,
                                        y: titleLabel.frame.maxY,
                                        width: 300,
                                        height: Constants.descriptionLabelHeight)

        balanceChangeLabel.sizeToFit()
        balanceChangeLabel.frame = CGRect(x: frame.maxX - Constants.sidePadding - balanceChangeLabel.frame.width,
                                          y: titleLabel.frame.minY,
                                          width: balanceChangeLabel.frame.width,
                                          height: Constants.titleLabelHeight)
    }
}
