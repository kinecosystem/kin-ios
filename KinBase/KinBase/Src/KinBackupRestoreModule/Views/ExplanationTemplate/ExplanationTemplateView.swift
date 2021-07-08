//
//  ExplanationTemplateView.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 25/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class ExplanationTemplateView: KeyboardAdjustingScrollView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let doneButton = RoundButton()

    // MARK: Lifecycle

    required init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedVerticalSpaceSubview(spacing: .large)

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Appearance.shared.primary
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        contentView.addArrangedSubview(imageView)

        addArrangedVerticalSpaceSubview()

        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .kinDarkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView.addArrangedSubview(titleLabel)

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .kinDarkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView.addArrangedSubview(descriptionLabel)

        addArrangedVerticalSpaceSubview()

        doneButton.setContentCompressionResistancePriority(.required, for: .vertical)
        doneButton.setContentHuggingPriority(.required, for: .vertical)
        contentView.addArrangedSubview(doneButton)

        addArrangedVerticalSpaceSubview(spacing: .large)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
