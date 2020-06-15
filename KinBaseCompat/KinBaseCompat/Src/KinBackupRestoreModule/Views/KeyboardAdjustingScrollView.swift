//
//  KeyboardAdjustingScrollView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 24/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class KeyboardAdjustingScrollView: UIScrollView {
    let contentView = UIStackView()

    private var contentLayoutGuideBottomConstraint: NSLayoutConstraint?
    private var bottomLayoutHeightConstraint: NSLayoutConstraint?
    var bottomLayoutHeight: CGFloat = 0 {
        didSet {
            let bottomOffset = traitCollection.verticalSizeClass == .compact ? layoutMargins.bottom : layoutMargins.left
            let bottomHeight = bottomLayoutHeight + bottomOffset

            contentLayoutGuideBottomConstraint?.constant = -bottomHeight
            bottomLayoutHeightConstraint?.constant = bottomHeight
        }
    }

    // MARK: Lifecycle

    required override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        backgroundColor = .white

        let contentLayoutGuide = UILayoutGuide()
        addLayoutGuide(contentLayoutGuide)
        contentLayoutGuide.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        contentLayoutGuideBottomConstraint = contentLayoutGuide.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        contentLayoutGuideBottomConstraint?.isActive = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 18
        addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.heightAnchor)
        contentViewHeightConstraint.priority = .defaultHigh
        contentViewHeightConstraint.isActive = true

        let bottomLayoutView = UIView()
        bottomLayoutView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLayoutView)
        bottomLayoutView.topAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomLayoutView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomLayoutHeightConstraint = bottomLayoutView.heightAnchor.constraint(equalToConstant: 0)
        bottomLayoutHeightConstraint?.isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Layout

    /**
     Add subview with a static height.
     */
    func addArrangedVerticalSpaceSubview(to stackView: UIStackView? = nil, spacing: Spacing = .small) {
        let spaceView = UIView()
        spaceView.setContentHuggingPriority(.required, for: .vertical)
        spaceView.setContentCompressionResistancePriority(.required, for: .vertical)
        (stackView ?? contentView).addArrangedSubview(spaceView)
        spaceView.heightAnchor.constraint(equalToConstant: spacing.constant).isActive = true
    }

    // MARK: Keyboard

    @objc
    private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        let frame = notification.endFrame

        guard frame != .null else {
            return
        }

        // iPhone X keyboard has a height when it's not displayed.
        let bottomHeight = max(0, bounds.height - frame.origin.y - layoutMargins.bottom)

        scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight, right: 0)

        let isViewOnScreen = layer.presentation() != nil

        if isViewOnScreen {
            UIView.animate(withDuration: notification.duration, delay: 0, options: notification.animationOptions, animations: { [weak self] in
                self?.bottomLayoutHeight = bottomHeight
                self?.layoutIfNeeded()
            })
        }
        else {
            bottomLayoutHeight = bottomHeight
        }
    }
}

// MARK: - Spacing

extension KeyboardAdjustingScrollView {
    enum Spacing {
        case small
        case medium
        case large
    }
}

extension KeyboardAdjustingScrollView.Spacing {
    var constant: CGFloat {
        switch self {
        case .small:
            return 0
        case .medium:
            return 14
        case .large:
            return 28
        }
    }
}
