//
//  PasswordTextField.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 20/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordTextField: UITextField {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        isSecureTextEntry = true
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        backgroundColor = .white
        tintColor = Appearance.shared.primary

        layer.borderWidth = .borderWidth
        layer.cornerRadius = .cornerRadius
        layer.masksToBounds = true

        let horizontalPadding: CGFloat = 20

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalPadding, height: 0))
        leftViewMode = .always

        let revealButton = UIButton()
        revealButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: horizontalPadding)
        revealButton.setImage(UIImage(named: "Eye", in: .backupRestore, compatibleWith: nil), for: .normal)
        revealButton.addTarget(self, action: #selector(showPassword), for: .touchDown)
        revealButton.addTarget(self, action: #selector(hidePassword), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        revealButton.sizeToFit()
        rightView = revealButton
        rightViewMode = .whileEditing

        updateState()
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

    // MARK: State

    public var entryState: PasswordState = .default {
        didSet {
            updateState()
        }
    }
    
    private func updateState() {
        switch entryState {
        case .default:
            textColor = .kinDarkGray
            layer.borderColor = UIColor.kinDarkGray.cgColor
        case .valid:
            textColor = .kinDarkGray
            layer.borderColor = Appearance.shared.primary.cgColor
        case .invalid:
            textColor = .kinGray
            layer.borderColor = UIColor.kinWarning.cgColor
        }
    }

    // MARK: Password
    
    @objc
    private func showPassword() {
        updateText(isSecure: false)
    }
    
    @objc
    private func hidePassword() {
        updateText(isSecure: true)
    }
    
    private func updateText(isSecure: Bool) {
        let isFirst = isFirstResponder

        if isFirst {
            resignFirstResponder()
        }

        isSecureTextEntry = isSecure

        if isFirst {
            becomeFirstResponder()
        }
    }

    // MARK: Placeholder

    override var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.kinGray])
            }
        }
    }
}

extension PasswordTextField {
    enum PasswordState {
        case `default`
        case valid
        case invalid
    }
}
