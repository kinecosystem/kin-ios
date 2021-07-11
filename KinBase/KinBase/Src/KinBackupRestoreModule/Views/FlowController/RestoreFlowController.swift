//
//  RestoreFlowController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 23/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class RestoreFlowController: FlowController {
    let kinEnvironment: KinEnvironment
    var importedKinAccount: KinAccount?

    init(kinEnvironment: KinEnvironment, navigationController: UINavigationController) {
        self.kinEnvironment = kinEnvironment
        super.init(navigationController: navigationController)
    }

    private var qrPickerController: QRPickerController?
    
    private lazy var _entryViewController: UIViewController = {
        let viewController = RestoreIntroViewController()
        viewController.delegate = self
        viewController.lifeCycleDelegate = self
        return viewController
    }()
    
    override var entryViewController: UIViewController {
        return _entryViewController
    }
}

extension RestoreFlowController: LifeCycleProtocol {
    func viewController(_ viewController: UIViewController, willAppear animated: Bool) {
        
    }
    
    func viewController(_ viewController: UIViewController, willDisappear animated: Bool) {
        cancelFlowIfNeeded(viewController)
    }
}

// MARK: - Navigation

extension RestoreFlowController {
    fileprivate func presentQRPickerViewController() {
        guard QRPickerController.canOpenImagePicker else {
            delegate?.flowController(self, error: KinBackupRestoreError.cantOpenImagePicker)
            return
        }
        
        let qrPickerController = QRPickerController()
        qrPickerController.delegate = self
        navigationController.present(qrPickerController.imagePickerController, animated: true)
        self.qrPickerController = qrPickerController
    }
    
    fileprivate func pushPasswordViewController(with qrString: String) {
        let restoreViewController = RestoreViewController(qrString: qrString)
        restoreViewController.delegate = self
        restoreViewController.lifeCycleDelegate = self
        navigationController.pushViewController(restoreViewController, animated: true)
    }
}

// MARK: - Flow

extension RestoreFlowController: RestoreIntroViewControllerDelegate {
    func restoreIntroViewControllerDidComplete(_ viewController: RestoreIntroViewController) {
        presentQRPickerViewController()
    }
}

extension RestoreFlowController: QRPickerControllerDelegate {
    func qrPickerControllerDidComplete(_ controller: QRPickerController, with qrString: String?) {
        controller.imagePickerController.presentingViewController?.dismiss(animated: true)
        importedKinAccount = nil

        if let qrString = qrString {
            pushPasswordViewController(with: qrString)
        }
    }
}

extension RestoreFlowController: RestoreViewControllerDelegate {
    func restoreViewController(_ viewController: RestoreViewController, importWith password: String) -> RestoreViewController.ImportResult {
        guard let qrImage = viewController.qrImage, let json = QR.decode(image: qrImage) else {
            return .invalidImage
        }

        let (result, kinAccount) = isAccountInEnvironment(json: json, password: password)

        if let result = result {
            importedKinAccount = kinAccount
            return result
        }

        do {
            importedKinAccount = try kinEnvironment.importAccount(json, passphrase: password)
            return .success
        }
        catch {
            if case KeyUtilsError.passphraseIncorrect = error {
                return .wrongPassword
            }
            else {
                delegate?.flowController(self, error: error)
                return .internalIssue
            }
        }
    }
    
    func restoreViewControllerDidComplete(_ viewController: RestoreViewController) {
        // Delay to give the UX some time after the button animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.flowControllerDidComplete(self)
            self.importedKinAccount = nil
        }
    }
}

// MARK: - Account Duplication

extension RestoreFlowController {
    fileprivate func accountData(in json: String) throws -> KeyUtils.AccountData? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        return try JSONDecoder().decode(KeyUtils.AccountData.self, from: data)
    }

    fileprivate func isAccountInEnvironment(json: String, password: String) -> (RestoreViewController.ImportResult?, kinAccount: KinAccount?) {
        var data: KeyUtils.AccountData?

        do {
            data = try accountData(in: json)
        }
        catch {
            return (.internalIssue, nil)
        }

        guard let d = data else {
            return (.internalIssue, nil)
        }

        do {
            _ = try KeyUtils.seed(from: password, encryptedSeed: d.seed, salt: d.salt)
        }
        catch {
            return (.wrongPassword, nil)
        }

        let foundAccount = kinClient.accounts.makeIterator().first { $0?.publicAddress == d.pkey }

        if let kinAccount = foundAccount {
            return (.success, kinAccount)
        }

        return (nil, nil)
    }
}
