//
//  RestoreViewController.swift
//  KinEcosystem
//
//  Created by Elazar Yifrach on 29/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

protocol RestoreViewControllerDelegate: NSObjectProtocol {
    func restoreViewController(_ viewController: RestoreViewController, importWith password: String, _ callback: @escaping (RestoreViewController.ImportResult)->())
    func restoreViewControllerDidComplete(_ viewController: RestoreViewController)
}

class RestoreViewController: KinViewController {
    weak var delegate: RestoreViewControllerDelegate?

    let qrImage: UIImage?

    // MARK: View

    private var imageView: UIImageView {
        return _view.imageView
    }

    private var passwordLabel: PasswordLabel {
        return _view.passwordLabel
    }

    private var passwordTextField: PasswordTextField {
        return _view.passwordTextField
    }

    private var doneButton: ConfirmButton {
        return _view.doneButton
    }

    var _view: RestoreView {
        return view as! RestoreView
    }

    var classForView: RestoreView.Type {
        return RestoreView.self
    }

    override func loadView() {
        view = classForView.self.init(frame: .zero)
    }

    // MARK: Lifecycle

    init(qrString: String) {
        self.qrImage = QR.encode(string: qrString)

        super.init(nibName: nil, bundle: nil)

        title = "restore.title".localized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = qrImage

        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
        passwordTextField.becomeFirstResponder()

        doneButton.isEnabled = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    @objc
    private func passwordTextFieldDidChange(_ textField: PasswordTextField) {
        passwordLabel.state = .instructions
        passwordTextField.entryState = .default
        doneButton.isEnabled = textField.hasText
    }
    
    @objc
    private func doneButtonTapped(_ button: ConfirmButton) {
        guard !navigationItem.hidesBackButton else {
            // Button in mid transition
            return
        }

        guard let delegate = delegate else {
            return
        }

        button.isEnabled = false
        navigationItem.hidesBackButton = true

        delegate.restoreViewController(self, importWith: passwordTextField.text ?? "") { (importResult) in
            DispatchQueue.main.async {
                if importResult == .success {
                    self.passwordLabel.state = .success
                    self.passwordTextField.entryState = .valid
                    self.passwordTextField.isEnabled = false

                    button.transitionToConfirmed {
                        delegate.restoreViewControllerDidComplete(self)
                    }
                }
                else {
                    self.passwordTextField.entryState = .invalid
                    button.isEnabled = true
                    self.navigationItem.hidesBackButton = false

                    if importResult == .wrongPassword {
                        self.passwordLabel.state = .invalid
                    }
                    else {
                        self.presentErrorAlertController(result: importResult)
                    }
                }
            }
        }
    }
}

// MARK: - Import Result

extension RestoreViewController {
    enum ImportResult {
        case success
        case wrongPassword
        case invalidImage
        case internalIssue
    }
}

extension RestoreViewController.ImportResult {
    var errorDescription: String? {
        switch self {
        case .success:
            return nil
        case .wrongPassword:
            return "restore.error.wrong_password".localized()
        case .invalidImage:
            return "restore.error.invalid_image".localized()
        case .internalIssue:
            return "restore.error.internal_issue".localized()
        }
    }
}

// MARK: - Error

extension RestoreViewController {
    fileprivate func presentErrorAlertController(result: ImportResult) {
        let alertController = UIAlertController(title: "restore.alert_error.title".localized(), message: result.errorDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "generic.ok".localized(), style: .cancel))
        present(alertController, animated: true)
    }
}
