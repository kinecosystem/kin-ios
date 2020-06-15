//
//  PasswordLabel.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 17/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordLabel: UILabel {
    var instructionsAttributedString: NSAttributedString? {
        didSet {
            needsResetHeight = true
            syncState()
        }
    }
    var mismatchAttributedString: NSAttributedString? {
        didSet {
            needsResetHeight = true
            syncState()
        }
    }
    var invalidAttributedString: NSAttributedString? {
        didSet {
            needsResetHeight = true
            syncState()
        }
    }
    var successAttributedString: NSAttributedString? {
        didSet {
            needsResetHeight = true
            syncState()
        }
    }

    // MARK: State

    var state: State = .instructions {
        didSet {
            syncState()
        }
    }

    private func syncState() {
        switch state {
        case .instructions:
            attributedText = instructionsAttributedString
        case .mismatch:
            attributedText = mismatchAttributedString
        case .invalid:
            attributedText = invalidAttributedString
        case .success:
            attributedText = successAttributedString
        }
    }

    // MARK: Size

    private var needsResetHeight = true
    private var instructionsHeight: CGFloat = 0
    private var mismatchHeight: CGFloat = 0
    private var invalidHeight: CGFloat = 0
    private var successHeight: CGFloat = 0

    private func syncSize() {
        guard needsResetHeight else {
            return
        }

        needsResetHeight = false

        func height(with attributedString: NSAttributedString?) -> CGFloat {
            let string = attributedString?.string ?? ""
            let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            let font = self.font ?? UIFont.preferredFont(forTextStyle: .body)
            return ceil(string.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height)
        }

        instructionsHeight = height(with: instructionsAttributedString)
        mismatchHeight = height(with: mismatchAttributedString)
        invalidHeight = height(with: invalidAttributedString)
        successHeight = height(with: successAttributedString)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        syncSize()
    }

    override var intrinsicContentSize: CGSize {
        if bounds.isEmpty {
            layoutIfNeeded()
        }

        var size = super.intrinsicContentSize

        for height in [instructionsHeight, mismatchHeight, invalidHeight, successHeight] {
            size.height = max(size.height, height)
        }

        return size
    }
}

// MARK: - State

extension PasswordLabel {
    enum State {
        case instructions
        case mismatch
        case invalid
        case success
    }
}
