//
//  RestoreIntroViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 25/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

protocol RestoreIntroViewControllerDelegate: NSObjectProtocol {
    func restoreIntroViewControllerDidComplete(_ viewController: RestoreIntroViewController)
}

class RestoreIntroViewController: ExplanationTemplateViewController {
    weak var delegate: RestoreIntroViewControllerDelegate?
    private var canContinue = false

    override init() {
        super.init()

        navigationItem.backBarButtonItem = UIBarButtonItem()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "QRCode", in: .backupRestore, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        titleLabel.text = "restore.title".localized()

        descriptionLabel.text = "restore_intro.description".localized()

        doneButton.setTitle("restore_intro.next".localized(), for: .normal)
        doneButton.addTarget(self, action: #selector(continueAction), for: .touchUpInside)
    }
    
    @objc
    private func continueAction() {
        if canContinue {
            delegate?.restoreIntroViewControllerDidComplete(self)
        }
        else {
            presentAlertController()
        }
    }
    
    @objc
    private func presentAlertController() {
        let title = "restore_intro.alert.title".localized()
        let message = "restore_intro.alert.message".localized()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "generic.ok".localized(), style: .default) { _ in
            self.canContinue = true
            self.delegate?.restoreIntroViewControllerDidComplete(self)
        }
        alertController.addAction(UIAlertAction(title: "generic.cancel".localized(), style: .cancel))
        alertController.addAction(continueAction)
        alertController.preferredAction = continueAction
        present(alertController, animated: true)
    }
}

