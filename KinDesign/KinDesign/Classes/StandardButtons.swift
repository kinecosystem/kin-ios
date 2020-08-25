//
//  StandardButtons.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-12-03.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

public class StandardButton: UIButton {

    public struct Constants {
        public static let fontSize: CGFloat = 15
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        layer.cornerRadius = StandardConstants.cornerRadius
        layer.masksToBounds = true

        titleLabel?.font = .boldSystemFont(ofSize: Constants.fontSize)
    }
}

public class PrimaryButton: StandardButton {

    override func commonInit() {
        super.commonInit()

        backgroundColor = .kinPurple

        setTitleColor(.white, for: .normal)
        setTitleColor(.kinGray3, for: .highlighted)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superViewWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
        let titleSize = titleLabel?.sizeThatFits(size) ?? CGSize.zero

        return CGSize(width: superViewWidth - StandardConstants.sidePadding * 2,
                      height: titleSize.height + 41)
    }
}

public class PositiveActionButton: StandardButton {

    override func commonInit() {
        super.commonInit()

        backgroundColor = .kinPurple

        setTitleColor(.white, for: .normal)
        setTitleColor(.kinGray3, for: .highlighted)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleSize = titleLabel?.sizeThatFits(size) ?? CGSize.zero

        return CGSize(width: titleSize.width + 30,
                      height: titleSize.height + 30)
    }
}

public class NegativeActionButton: StandardButton {

    override func commonInit() {
        super.commonInit()

        backgroundColor = .kinGray4

        setTitleColor(.kinGray1, for: .normal)
        setTitleColor(.white, for: .highlighted)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleSize = titleLabel?.sizeThatFits(size) ?? CGSize.zero

        return CGSize(width: titleSize.width + 30,
                      height: titleSize.height + 30)
    }
}

public class InlineActionButton: StandardButton {

    override func commonInit() {
        super.commonInit()

        backgroundColor = .clear

        setTitleColor(.kinPurple, for: .normal)
        setTitleColor(.kinGray4, for: .highlighted)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleSize = titleLabel?.sizeThatFits(size) ?? CGSize.zero

        return CGSize(width: titleSize.width + 30,
                      height: titleSize.height + 30)
    }
}
