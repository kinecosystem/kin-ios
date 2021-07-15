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
    func restoreViewController(_ viewController: RestoreViewController, importWith password: String, _ callback: @escaping (RestoreViewController.ImportResult)->()) {
        guard let qrImage = viewController.qrImage, let json = QR.decode(image: qrImage) else {
            callback(.invalidImage)
            return
        }

        isAccountInEnvironment(json: json, password: password) { (result, kinAccount) in
            if let result = result {
                self.importedKinAccount = kinAccount
                callback(result)
                return
            }

            do {
                self.importedKinAccount = try self.kinEnvironment.importAccount(json, passphrase: password)
                callback(.success)
                return
            }
            catch {
                if case KeyUtilsError.passphraseIncorrect = error {
                    callback(.wrongPassword)
                    return
                }
                else {
                    self.delegate?.flowController(self, error: error)
                    callback(.internalIssue)
                    return
                }
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

    fileprivate func isAccountInEnvironment(json: String, password: String, _ callback: @escaping (RestoreViewController.ImportResult?, KinAccount?)->()) {
        var data: KeyUtils.AccountData?

        do {
            data = try accountData(in: json)
        }
        catch {
            callback(.internalIssue, nil)
            return
        }

        guard let d = data else {
            callback(.internalIssue, nil)
            return
        }

        do {
            _ = try KeyUtils.seed(from: password, encryptedSeed: d.seed, salt: d.salt)
        }
        catch {
            callback(.wrongPassword, nil)
            return
        }

        kinEnvironment.allAccountIds().then { (envKeys: [PublicKey]) in
            let foundKey = envKeys.makeIterator().first { $0.base58 == d.pkey || $0.stellarID == d.pkey }

            if let key = foundKey {
                callback(.success, KinAccount(publicKey: key))
                return
            } else {
                callback(nil, nil)
                return
            }
        }
    }
}
