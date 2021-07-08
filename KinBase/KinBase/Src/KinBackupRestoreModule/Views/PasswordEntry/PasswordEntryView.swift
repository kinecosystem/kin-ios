//
//  PasswordEntryView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 19/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class PasswordEntryView: KeyboardAdjustingScrollView {
    let passwordLabel = PasswordLabel()
    let passwordTextField = PasswordTextField()
    let passwordConfirmTextField = PasswordTextField()
    private let confirmStackView = UIStackView()
    private let confirmImageView = CheckboxImageView()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalSpaceSubview(spacing: .medium)

        let titleLabel = UILabel()
        titleLabel.text = "password_entry.title".localized()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .kinDarkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(titleLabel)

        passwordLabel.instructionsAttributedString = NSAttributedString(attributedStrings: [
            NSAttributedString(string: "password_entry.instructions".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray]),
            NSAttributedString(string: "password_entry.pattern".localized(), attributes: [.foregroundColor: UIColor.kinGray])
            ])
        passwordLabel.mismatchAttributedString = NSAttributedString(attributedStrings: [
            NSAttributedString(string: "password_entry.mismatch".localized(), attributes: [.foregroundColor: UIColor.kinWarning]),
            NSAttributedString(string: "password_entry.pattern".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray])
            ])
        passwordLabel.invalidAttributedString = NSAttributedString(attributedStrings: [
            NSAttributedString(string: "password_entry.invalid".localized(), attributes: [.foregroundColor: UIColor.kinWarning]),
            NSAttributedString(string: "password_entry.pattern".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray])
            ])
        passwordLabel.font = .preferredFont(forTextStyle: .body)
        passwordLabel.numberOfLines = 0
        passwordLabel.textAlignment = .center
        passwordLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordLabel)

        addArrangedVerticalSpaceSubview()

        passwordTextField.placeholder = "password_entry.password.placeholder".localized()
        passwordTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordTextField)

        passwordConfirmTextField.placeholder = "password_entry.password_confirm.placeholder".localized()
        passwordConfirmTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordConfirmTextField)

        confirmStackView.alignment = .top
        confirmStackView.spacing = 10
        contentView.addArrangedSubview(confirmStackView)

        confirmStackView.addArrangedSubview(confirmImageView)

        let confirmLabel = UILabel()
        confirmLabel.text = "password_entry.confirmation".localized()
        confirmLabel.font = .preferredFont(forTextStyle: .footnote)
        confirmLabel.textColor = .kinDarkGray
        confirmLabel.numberOfLines = 0
        confirmLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        confirmStackView.addArrangedSubview(confirmLabel)

        addArrangedVerticalSpaceSubview()

        let doneButtonStackView = UIStackView()
        doneButtonStackView.axis = .vertical
        doneButtonStackView.alignment = .center
        contentView.addArrangedSubview(doneButtonStackView)

        doneButton.isEnabled = false
        doneButton.setTitle("generic.next".localized(), for: .normal)
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButtonStackView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor).isActive = true

        addArrangedVerticalSpaceSubview(spacing: .medium)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Interaction

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if touches.first?.view == confirmStackView,
            let point = touches.first?.location(in: self),
            hitTest(point, with: event) == confirmStackView
        {
            confirmImageView.isHighlighted = !confirmImageView.isHighlighted
            updateDoneButton()
        }
    }

    // MARK: View Updates

    func updateDoneButton() {
        let isPasswordTextFieldEnabled = passwordTextField.hasText && passwordTextField.entryState != .invalid
        let isConfirmPasswordTextFieldEnabled = passwordConfirmTextField.hasText && passwordConfirmTextField.entryState != .invalid
        doneButton.isEnabled = isPasswordTextFieldEnabled && isConfirmPasswordTextFieldEnabled && confirmImageView.isHighlighted
    }
}
