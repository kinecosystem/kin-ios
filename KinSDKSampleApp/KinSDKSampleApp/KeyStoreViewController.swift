//
//  KeyStoreViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class KeyStoreViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var kinClient: KinClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        showKeyStore()
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyStore), name: UITextField.textDidChangeNotification, object: nil)

        textField.becomeFirstResponder()
        saveButton.fill(with: view.tintColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        saveButton.fill(with: view.tintColor)
    }

    @objc func showKeyStore() {
        guard let exportPassphrase = textField.text,
            exportPassphrase.count > 0 else {
                textView?.text = "Add a passphrase to encrypt the account"
                saveButton.isEnabled = false
                return
        }

        guard let keyStore = try? kinClient.accounts[0]?.export(passphrase: exportPassphrase),
            let prettified = keyStore.prettified() else {
                return
        }

        textView?.text = prettified
        saveButton.isEnabled = true
    }

    @IBAction func exportTapped() {
        guard let text = textView?.text else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

extension KeyStoreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return false
    }
}
