//
//  MarketplaceItemView.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-11-25.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit

internal class MarketplaceItemView: UIView {
    private struct Constants {
        static let viewHeight: CGFloat = 108
        static let imageSize = CGSize(width: 77, height: 77)
        static let sidePadding: CGFloat = 16
        static let textAreaLeftPadding: CGFloat = 12
        static let titleLabelHeight: CGFloat = 22
        static let descriptionLabelHeight: CGFloat = 18
        static let descriptionLabelTopPadding: CGFloat = 8
    }

    public static let height = Constants.viewHeight

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

    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: Constants.sidePadding,
                                                                  y: Constants.sidePadding),
                                                  size: Constants.imageSize))
        return imageView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(imageView)

        setUpBorder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor.kinGray4.cgColor
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: Constants.viewHeight)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let textAreaX = imageView.frame.maxY + Constants.textAreaLeftPadding
        let textAreaMaxWidth = frame.width - textAreaX - Constants.sidePadding

        titleLabel.frame = CGRect(x: imageView.frame.maxY + Constants.textAreaLeftPadding,
                                  y: 30,
                                  width: textAreaMaxWidth,
                                  height: Constants.titleLabelHeight)

        descriptionLabel.frame = CGRect(x: imageView.frame.maxY + Constants.textAreaLeftPadding,
                                        y: titleLabel.frame.maxY + Constants.descriptionLabelTopPadding,
                                        width: textAreaMaxWidth,
                                        height: Constants.descriptionLabelHeight)
    }
}
