//
//  PasswordEntryViewController.swift
//  KinEcosystem
//
//  Created by Elazar Yifrach on 16/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

protocol PasswordEntryViewControllerDelegate: NSObjectProtocol {
    func passwordEntryViewController(_ viewController: PasswordEntryViewController, validate password: String) -> Bool
    func passwordEntryViewControllerDidComplete(_ viewController: PasswordEntryViewController, with password: String)
}

class PasswordEntryViewController: KinViewController {
    weak var delegate: PasswordEntryViewControllerDelegate?

    // MARK: View

    private var passwordLabel: PasswordLabel {
        return _view.passwordLabel
    }

    private var passwordTextField: PasswordTextField {
        return _view.passwordTextField
    }

    private var passwordConfirmTextField: PasswordTextField {
        return _view.passwordConfirmTextField
    }

    private var doneButton: RoundButton {
        return _view.doneButton
    }

    var _view: PasswordEntryView {
        return view as! PasswordEntryView
    }

    var classForView: PasswordEntryView.Type {
        return PasswordEntryView.self
    }

    override func loadView() {
        view = classForView.self.init(frame: .zero)
    }

    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "backup.title".localized()
        navigationItem.backBarButtonItem = UIBarButtonItem()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
        passwordTextField.becomeFirstResponder()

        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    @objc
    private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        let frame = notification.endFrame

        guard frame != .null else {
            return
        }

        // iPhone X keyboard has a height when it's not displayed.
        let bottomHeight = max(0, view.bounds.height - frame.origin.y - view.layoutMargins.bottom)

        _view.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight, right: 0)

        let isViewOnScreen = view.layer.presentation() != nil

        if isViewOnScreen {
            UIView.animate(withDuration: notification.duration, delay: 0, options: notification.animationOptions, animations: {
                self._view.bottomLayoutHeight = bottomHeight
                self._view.layoutIfNeeded()
            })
        }
        else {
            _view.bottomLayoutHeight = bottomHeight
        }
    }

    // MARK: Text Field

    @objc
    private func textFieldDidChange(_ textField: PasswordTextField) {
        passwordLabel.state = .instructions
        textField.entryState = .default

        _view.updateDoneButton()
    }

    @objc
    private func textFieldDidEnd(_ textField: PasswordTextField) {
        if let password = textField.text, !password.isEmpty {
            if let delegate = delegate, delegate.passwordEntryViewController(self, validate: password) {
                textField.entryState = .valid
            }
            else {
                passwordLabel.state = .invalid
                textField.entryState = .invalid
            }
        }
        else {
            textField.entryState = .default
        }

        _view.updateDoneButton()
    }

    // MARK: Done Button
    
    @objc
    private func doneButtonTapped(_ button: UIButton) {
        guard let password = passwordTextField.text, passwordTextField.hasText && passwordConfirmTextField.hasText else {
            return // Shouldn't happen
        }

        guard passwordTextField.text == passwordConfirmTextField.text else {
            passwordLabel.state = .mismatch

            passwordTextField.becomeFirstResponder()
            passwordTextField.entryState = .invalid

            passwordConfirmTextField.text = ""
            passwordConfirmTextField.entryState = .invalid

            _view.updateDoneButton()
            return
        }

        guard let delegate = delegate else {
            return
        }
        
        guard delegate.passwordEntryViewController(self, validate: password) else {
            passwordLabel.state = .invalid

            passwordTextField.entryState = .invalid
            passwordConfirmTextField.entryState = .invalid

            _view.updateDoneButton()
            return
        }

        delegate.passwordEntryViewControllerDidComplete(self, with: password)
    }
}

// MARK: - Error

extension PasswordEntryViewController {
    func presentErrorAlertController() {
        let title = "generic.alert_error.title".localized()
        let message = "generic.alert_error.message".localized()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "generic.ok".localized(), style: .cancel))
        present(alertController, animated: true)
    }
}
