//
//  RestoreView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 24/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class RestoreView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    let passwordLabel = PasswordLabel()
    let passwordTextField = PasswordTextField()
    let doneButton = ConfirmButton()

    // MARK: Lifecycle

    required init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalSpaceSubview(spacing: .medium)

        let imageViewStackView = UIStackView()
        imageViewStackView.axis = .vertical
        imageViewStackView.alignment = .center
        contentView.addArrangedSubview(imageViewStackView)

        let imageWidth: CGFloat = 100

        imageView.contentMode = .scaleAspectFit
        imageViewStackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true

        let checkWidth: CGFloat = 24
        let checkBorder: CGFloat = 2
        let checkOffset: CGFloat = 4
        let checkBorderWidth = checkWidth + (checkBorder * 2)

        // Prevent aliasing from layer.border
        let checkBorderView = UIView()
        checkBorderView.translatesAutoresizingMaskIntoConstraints = false
        checkBorderView.backgroundColor = .white
        checkBorderView.layer.cornerRadius = checkBorderWidth / 2
        checkBorderView.layer.rasterizationScale = UIScreen.main.scale
        checkBorderView.layer.shouldRasterize = true
        imageViewStackView.addSubview(checkBorderView)
        checkBorderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: checkOffset).isActive = true
        checkBorderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: checkOffset).isActive = true
        checkBorderView.widthAnchor.constraint(equalToConstant: checkBorderWidth).isActive = true
        checkBorderView.heightAnchor.constraint(equalToConstant: checkBorderWidth).isActive = true

        let checkImageView = UIImageView()
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.image = UIImage(named: "Checkmark", in: .backupRestore, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        checkImageView.tintColor = .white
        checkImageView.contentMode = .center
        checkImageView.backgroundColor = Appearance.shared.primary
        checkImageView.layer.cornerRadius = checkWidth / 2
        checkImageView.layer.rasterizationScale = UIScreen.main.scale
        checkImageView.layer.shouldRasterize = true
        checkBorderView.addSubview(checkImageView)
        checkImageView.centerXAnchor.constraint(equalTo: checkBorderView.centerXAnchor).isActive = true
        checkImageView.centerYAnchor.constraint(equalTo: checkBorderView.centerYAnchor).isActive = true
        checkImageView.widthAnchor.constraint(equalToConstant: checkWidth).isActive = true
        checkImageView.heightAnchor.constraint(equalToConstant: checkWidth).isActive = true

        addArrangedVerticalSpaceSubview()

        passwordLabel.instructionsAttributedString = NSAttributedString(string: "restore.instructions".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray])
        passwordLabel.invalidAttributedString = NSAttributedString(string: "restore.invalid".localized(), attributes: [.foregroundColor: UIColor.kinWarning])
        passwordLabel.successAttributedString = NSAttributedString(string: "restore.success".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray])
        passwordLabel.font = .preferredFont(forTextStyle: .body)
        passwordLabel.textColor = .kinDarkGray
        passwordLabel.textAlignment = .center
        passwordLabel.numberOfLines = 0
        passwordLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordLabel)

        addArrangedVerticalSpaceSubview()

        passwordTextField.placeholder = "restore.password.placeholder".localized()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.setContentCompressionResistancePriority(.required, for: .vertical)
        passwordTextField.setContentHuggingPriority(.required, for: .vertical)
        contentView.addArrangedSubview(passwordTextField)

        doneButton.setTitle("generic.done".localized(), for: .normal)
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentView.addArrangedSubview(doneButton)

        addArrangedVerticalSpaceSubview(spacing: .medium)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
