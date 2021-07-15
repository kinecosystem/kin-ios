//
//  BackupIntroViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 16/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class BackupIntroViewController: ExplanationTemplateViewController {
    override init() {
        super.init()

        navigationItem.backBarButtonItem = UIBarButtonItem()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "Safe", in: .backupRestore, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        titleLabel.text = "backup.title".localized()

        descriptionLabel.text = "backup_intro.description".localized()

        doneButton.setTitle("backup_intro.next".localized(), for: .normal)
    }
}
