//
//  AccountListViewController.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 13/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

protocol AccountListViewControllerDelegate: NSObjectProtocol {
    func accountListViewController(_ viewController: AccountListViewController, didSelect account: KinAccount)
}

class AccountListViewController: UITableViewController {
    weak var delegate: AccountListViewControllerDelegate?

    let client: KinClient

    init(with client: KinClient) {
        self.client = client

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAccount))

        view.backgroundColor = .white

        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

// MARK: - Account

extension AccountListViewController {
    @objc
    private func addAccount() {
        if let _ = try? client.addAccount() {
            tableView.reloadData()
        }
    }

    private func deleteAccount(at index: Int) -> UIContextualAction.Handler {
        return { [weak self] (action, view, completion) in
            do {
                try self?.client.deleteAccount(at: index)
                completion(true)
            }
            catch {
                completion(false)
            }
        }
    }

    private func account(forPublicAddress publicAddress: String) -> KinAccount? {
        for account in client.accounts.makeIterator() {
            if account?.publicAddress == publicAddress {
                return account
            }
        }

        return nil
    }

    private func accountIndex(forPublicAddress publicAddress: String) -> Int? {
        for (i, account) in client.accounts.makeIterator().enumerated() {
            if account?.publicAddress == publicAddress {
                return i
            }
        }

        return nil
    }
}

// MARK: - Table View Data Source

extension AccountListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.accounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.baselineAdjustment = .alignCenters
        
        if let account = client.accounts[indexPath.row] {
            cell.textLabel?.text = account.publicAddress
        }
        else {
            cell.textLabel?.text = nil
        }

        return cell
    }
}

// MARK: - Table View Delegate

extension AccountListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let publicAddress = tableView.cellForRow(at: indexPath)?.textLabel?.text else {
            return
        }

        guard let account = self.account(forPublicAddress: publicAddress) else {
            return
        }

        delegate?.accountListViewController(self, didSelect: account)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let publicAddress = tableView.cellForRow(at: indexPath)?.textLabel?.text else {
            return nil
        }

        guard let accountIndex = self.accountIndex(forPublicAddress: publicAddress) else {
            return nil
        }

        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Delete", handler: deleteAccount(at: accountIndex))
            ])
    }
}
