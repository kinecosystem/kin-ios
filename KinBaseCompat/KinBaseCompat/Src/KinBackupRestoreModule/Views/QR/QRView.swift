//
//  QRView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 20/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class QRView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    let confirmControl = UIControl()
    private let confirmImageView = CheckboxImageView()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalSpaceSubview(spacing: .medium)

        let titleLabel = UILabel()
        titleLabel.text = "qr.title".localized()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .kinDarkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.addArrangedSubview(titleLabel)

        let descriptionLabel = UILabel()
        descriptionLabel.text = "qr.description".localized()
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .kinDarkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addArrangedSubview(descriptionLabel)

        addArrangedVerticalSpaceSubview()

        let imageViewStackView = UIStackView()
        imageViewStackView.axis = .vertical
        imageViewStackView.alignment = .center
        contentView.addArrangedSubview(imageViewStackView)

        let imageWidth: CGFloat = 280

        imageView.contentMode = .scaleAspectFit
        imageViewStackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true

        let reminderStackView = UIStackView()
        reminderStackView.alignment = .center
        reminderStackView.axis = .vertical
        contentView.addArrangedSubview(reminderStackView)

        let reminderLabel = UILabel()
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.text = "reminder.title".localized()
        reminderLabel.font = .preferredFont(forTextStyle: .footnote)
        reminderLabel.textColor = .kinWarning
        reminderLabel.numberOfLines = 0
        reminderLabel.textAlignment = .center
        reminderLabel.preferredMaxLayoutWidth = imageWidth
        reminderStackView.addArrangedSubview(reminderLabel)
        reminderLabel.topAnchor.constraint(equalTo: reminderStackView.topAnchor).isActive = true
        reminderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: reminderStackView.leadingAnchor).isActive = true
        reminderLabel.bottomAnchor.constraint(equalTo: reminderStackView.bottomAnchor).isActive = true
        reminderLabel.trailingAnchor.constraint(lessThanOrEqualTo: reminderStackView.trailingAnchor).isActive = true
        reminderLabel.centerXAnchor.constraint(equalTo: reminderStackView.centerXAnchor).isActive = true

        addArrangedVerticalSpaceSubview()

        confirmControl.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        contentView.addArrangedSubview(confirmControl)

        let confirmStackView = UIStackView()
        confirmStackView.translatesAutoresizingMaskIntoConstraints = false
        confirmStackView.axis = .horizontal
        confirmStackView.spacing = 10
        confirmStackView.alignment = .center
        confirmStackView.isUserInteractionEnabled = false
        confirmControl.addSubview(confirmStackView)
        confirmStackView.topAnchor.constraint(equalTo: confirmControl.topAnchor).isActive = true
        confirmStackView.leadingAnchor.constraint(greaterThanOrEqualTo: confirmControl.leadingAnchor).isActive = true
        confirmStackView.bottomAnchor.constraint(equalTo: confirmControl.bottomAnchor).isActive = true
        confirmStackView.trailingAnchor.constraint(lessThanOrEqualTo: confirmControl.trailingAnchor).isActive = true
        confirmStackView.centerXAnchor.constraint(equalTo: confirmControl.centerXAnchor).isActive = true

        confirmStackView.addArrangedSubview(confirmImageView)

        let confirmLabel = UILabel()
        confirmLabel.text = "qr.saved".localized()
        confirmLabel.font = .preferredFont(forTextStyle: .body)
        confirmLabel.textColor = .kinDarkGray
        confirmStackView.addArrangedSubview(confirmLabel)

        doneButton.setTitle("qr.save".localized(), for: .normal)
        doneButton.setTitle("generic.done".localized(), for: .selected)
        doneButton.setTitle("generic.done".localized(), for: [.selected, .highlighted])
        doneButton.setTitle("generic.done".localized(), for: [.selected, .disabled])
        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentView.addArrangedSubview(doneButton)

        addArrangedVerticalSpaceSubview(spacing: .medium)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Confirm

    var isConfirmed: Bool {
        get {
            return confirmImageView.isHighlighted
        }
        set {
            confirmImageView.isHighlighted = newValue
        }
    }

    @objc
    private func confirmAction() {
        isConfirmed = !isConfirmed
    }
}
