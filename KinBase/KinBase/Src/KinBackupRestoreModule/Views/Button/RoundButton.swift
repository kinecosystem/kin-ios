//
//  RoundButton.swift
//  KinEcosystem
//
//  Created by Corey Werner on 17/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        syncAppearance()

        let whiteAlpha = UIColor(white: 1, alpha: 0.5)

        setTitleColor(.white, for: .normal)
        setTitleColor(whiteAlpha, for: .highlighted)
        setTitleColor(whiteAlpha, for: [.selected, .highlighted])
        setTitleColor(.kinGray, for: .disabled)

        layer.cornerRadius = .cornerRadius
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = .minTapSurface
        return size
    }

    // MARK: Interaction
    
    override var isEnabled: Bool {
        didSet {
            syncAppearance()
        }
    }

    // MARK: Appearance

    fileprivate func syncAppearance() {
        backgroundColor = isEnabled ? Appearance.shared.primary : .kinLightGray
    }
}
