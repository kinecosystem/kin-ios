//
//  BackupFlowController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 23/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class BackupFlowController: FlowController {
    let kinAccount: KinAccount

    init(kinAccount: KinAccount, navigationController: UINavigationController) {
        self.kinAccount = kinAccount
        super.init(navigationController: navigationController)
    }

    private lazy var _entryViewController: UIViewController = {
        let viewController = BackupIntroViewController()
        viewController.lifeCycleDelegate = self
        viewController.doneButton.addTarget(self, action: #selector(pushPasswordViewController), for: .touchUpInside)
        return viewController
    }()
    
    override var entryViewController: UIViewController {
        return _entryViewController
    }
}

extension BackupFlowController: LifeCycleProtocol {
    func viewController(_ viewController: UIViewController, willAppear animated: Bool) {
        
    }
    
    func viewController(_ viewController: UIViewController, willDisappear animated: Bool) {
        cancelFlowIfNeeded(viewController)
    }
}

// MARK: - Navigation

extension BackupFlowController {
    // !!!: DEBUG
    @objc
    func test() {
//        let s = "{\"pkey\":\"GB2FKV3UT7HC4QCCRKZWNAYLTADH32HTUL3QMWA2IX44LUGVVH7CYENZ\",\"seed\":\"d4be9cabd685cf1c551122f9bf285ee2993d17ed8a7b68092cce7f976b2c5e50eb71b3231102289c06d7d1d4bff39effb07b85aef9c55953f833b4477643d1b482c7c38cbfdaed4f\",\"salt\":\"f8c47b5e960d1f13516fd2f136e358a5\"}"

        pushCompletedViewController()
    }

    @objc
    private func pushPasswordViewController() {
        let viewController = PasswordEntryViewController()
        viewController.delegate = self
        viewController.lifeCycleDelegate = self
        navigationController.pushViewController(viewController, animated: true)
    }

    @objc
    private func pushQRViewController(with qrString: String) {
        let viewController = QRViewController(qrString: qrString)
        viewController.delegate = self
        viewController.lifeCycleDelegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushCompletedViewController() {
        let viewController = BackupCompletedViewController()
        viewController.lifeCycleDelegate = self
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(completedFlow))
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func completedFlow() {
        delegate?.flowControllerDidComplete(self)
    }
}

// MARK: - Flow

extension BackupFlowController: PasswordEntryViewControllerDelegate {
    func passwordEntryViewController(_ viewController: PasswordEntryViewController, validate password: String) -> Bool {
        do {
            return try Password.matches(password)
        }
        catch {
            delegate?.flowController(self, error: error)
            return false
        }
    }

    func passwordEntryViewControllerDidComplete(_ viewController: PasswordEntryViewController, with password: String) {
        do {
            pushQRViewController(with: try kinAccount.export(passphrase: password))
        }
        catch {
            delegate?.flowController(self, error: error)
            viewController.presentErrorAlertController()
        }
    }
}

extension BackupFlowController: QRViewControllerDelegate {
    func qrViewControllerDidComplete(_ viewController: QRViewController) {
        pushCompletedViewController()
    }
}
