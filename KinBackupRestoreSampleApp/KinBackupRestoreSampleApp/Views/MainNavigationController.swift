//
//  MainNavigationController.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 13/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class MainNavigationController: UINavigationController {
    let network: Network = .testNet
    var brManager = KinBackupRestoreManager()
    let kinClient: KinClient
    var brAccount: KinAccount?

    private let loaderView = UIActivityIndicatorView(style: .whiteLarge)

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let appId: AppId

        do {
            appId = try AppId(network: network)
        }
        catch {
            fatalError()
        }

        kinClient = KinClient(with: .blockchain(network), network: network, appId: appId)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        brManager.delegate = self

        let accountListViewController = AccountListViewController(with: kinClient)
        accountListViewController.title = "Accounts"
        accountListViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restoreAction))
        accountListViewController.delegate = self

        viewControllers = [accountListViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions

    @objc
    fileprivate func restoreAction() {
        brManager.restore(kinClient, presentedOnto: self)
    }
}

// MARK: - Account List View Controller

extension MainNavigationController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelect account: KinAccount) {
        let viewController = AccountViewController(account, network: network)
        viewController.delegate = self
        pushViewController(viewController, animated: true)
    }
}

// MARK: - Account View Controller

extension MainNavigationController: AccountViewControllerDelegate {
    func accountViewController(_ viewController: AccountViewController, backupAccount account: KinAccount) {
        brAccount = account

        brManager.backup(account, pushedOnto: self)
    }
}

// MARK: - Backup and Restore

extension MainNavigationController: KinBackupRestoreManagerDelegate {
    func kinBackupRestoreManagerDidComplete(_ manager: KinBackupRestoreManager, kinAccount: KinAccount?) {
        self.brAccount = nil
    }

    func kinBackupRestoreManagerDidCancel(_ manager: KinBackupRestoreManager) {
        self.brAccount = nil
    }

    func kinBackupRestoreManager(_ manager: KinBackupRestoreManager, error: Error) {

    }
}

// MARK: - Loader

extension MainNavigationController {
    fileprivate func presentLoaderView() {
        guard loaderView.superview == nil else {
            return
        }

        loaderView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.startAnimating()
        view.addSubview(loaderView)
        loaderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    fileprivate func dismissLoaderView() {
        guard loaderView.superview != nil else {
            return
        }

        loaderView.stopAnimating()
        loaderView.removeFromSuperview()
    }
}
