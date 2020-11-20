//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK
import SafariServices

struct Provider: ServiceProvider {
    public let url: URL
    public let network: Network

    init(url: URL, network: Network) {
        self.url = url
        self.network = network
    }
}

class HomeViewController: UIViewController {
    @IBOutlet weak var testNetButton: UIButton!
    @IBOutlet weak var mainNetButton: UIButton!
    @IBOutlet weak var githubInfoStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        testNetButton.fill(with: UIColor.testNet)
        mainNetButton.fill(with: UIColor.mainNet)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(githubInfoTapped))
        githubInfoStackView.addGestureRecognizer(tapRecognizer)
    }

    @IBAction func networkSelected(_ sender: UIButton) {
        let production = sender == mainNetButton

        let provider: Provider
        if production {
            provider = Provider(url: URL(string: "https://horizon.kininfrastructure.com")!, network: .mainNet)
        } else {
            provider = Provider(url: URL(string: "http://horizon-testnet.kininfrastructure.com")!, network: .testNet)
        }
        
        do {
            let kinClient = KinClient(provider: provider, appId: try AppId("test"), testMigration: false)
            
            if let kinAccount = kinClient.accounts.first {
                //if we already have the account, pass it on to KinSampleViewController
                showSampleViewController(with: kinClient, kinAccount: kinAccount, production: production)
            } else {
                //if we don't have an account yet on the device, let's create one
                createKinAccount(with: kinClient, production: production)
            }
        }
        catch {
            print("AppId doesn't match the valid pattern: \(error)")
        }
    }

    @objc func githubInfoTapped() {
        let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/kinfoundation")!)
        present(safariViewController, animated: true, completion: nil)
    }

    func createKinAccount(with kinClient: KinClient, production: Bool) {
        let testOrMainNet = production ? "Main" : "Test"
        let alertController = UIAlertController(title: "No \(testOrMainNet) Net Wallet Yet", message: "Let's create a new one, using the kinClient.createAccountIfNeeded() api.", preferredStyle: .alert)
        let createWalletAction = UIAlertAction(title: "Create a Wallet", style: .default) { _ in
            do {
                let kinAccount = try kinClient.addAccount()
                self.showSampleViewController(with: kinClient, kinAccount: kinAccount, production: production)
            } catch {
                print("KinAccount couldn't be created: \(error)")
            }
        }
        let importWalletAction = UIAlertAction(title: "Import a Wallet", style: .default) { _ in
            self.importKinAccount(with: kinClient, production: production)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(createWalletAction)
        alertController.addAction(importWalletAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func importKinAccount(with kinClient: KinClient, production: Bool) {
        var removeObserver: (()->())?
        let passphraseTag = 1
        let importTag = 2
        
        let alertController = UIAlertController(title: "Import a Wallet", message: nil, preferredStyle: .alert)
        let importWalletAction = UIAlertAction(title: "Import", style: .default) { _ in
            if let removeObserver = removeObserver {
                removeObserver()
            }
            
            guard let importTextField = alertController.textFields?.first(where: { $0.tag == importTag }),
                let jsonString = importTextField.text,
                let passphraseTextField = alertController.textFields?.first(where: { $0.tag == passphraseTag })
                else {
                    print("Invalid import string")
                    return
            }
            
            let passphrase = passphraseTextField.text ?? ""
            
            do {
                let kinAccount = try kinClient.importAccount(jsonString, passphrase: passphrase)
                self.showSampleViewController(with: kinClient, kinAccount: kinAccount, production: production)
            }
            catch {
                print("KinAccount couldn't be imported: \(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            if let removeObserver = removeObserver {
                removeObserver()
            }
        }
        
        importWalletAction.isEnabled = false
        
        alertController.addTextField { passphraseTextField in
            passphraseTextField.tag = passphraseTag
            passphraseTextField.placeholder = "Passphrase"
        }
        alertController.addTextField { importTextField in
            let observer = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: importTextField, queue: nil, using: { _ in
                guard let importString = importTextField.text?.trimmingCharacters(in: .whitespaces) else {
                    return
                }
                
                importWalletAction.isEnabled = !importString.isEmpty
            })
            
            removeObserver = {
                NotificationCenter.default.removeObserver(observer)
            }
            
            importTextField.tag = importTag
            importTextField.placeholder = "JSON String"
        }
        alertController.addAction(importWalletAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    func showSampleViewController(with kinClient: KinClient, kinAccount: KinAccount, production: Bool) {
        let sampleViewController = KinSampleViewController.instantiate(with: kinClient, kinAccount: kinAccount)
        sampleViewController.view.tintColor = production ? .mainNet : .testNet
        navigationController?.pushViewController(sampleViewController, animated: true)
    }
}
