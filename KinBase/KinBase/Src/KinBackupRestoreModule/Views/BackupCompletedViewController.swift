//
//  BackupCompletedViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 17/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class BackupCompletedViewController: ExplanationTemplateViewController {
    override init() {
        super.init()

        navigationItem.hidesBackButton = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.alignment = .center
        
        imageView.image = UIImage(named: "Safe", in: .backupRestore, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        titleLabel.text = "backup_completed.title".localized()
        titleLabel.preferredMaxLayoutWidth = 260

        descriptionLabel.attributedText = NSMutableAttributedString(attributedStrings: [
            NSAttributedString(string: "backup_completed.description".localized(), attributes: [.foregroundColor: UIColor.kinDarkGray]),
            NSAttributedString(string: "reminder.title".localized(), attributes: [.foregroundColor: UIColor.kinWarning])
            ], separator: "\n\n")
        descriptionLabel.preferredMaxLayoutWidth = titleLabel.preferredMaxLayoutWidth

        doneButton.isHidden = true
    }
}
