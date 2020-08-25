//
//  AccountViewController.swift
//  KinMigrationSampleApp
//
//  Created by Corey Werner on 13/12/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

protocol AccountViewControllerDelegate: NSObjectProtocol {
    func accountViewController(_ viewController: AccountViewController, backupAccount account: KinAccount)
}

class AccountViewController: UITableViewController {
    weak var delegate: AccountViewControllerDelegate?

    let account: KinAccount
    let network: Network

    private let createAccountPromise = Promise<Void>()
    private var watch: BalanceWatch?
    private let linkBag = LinkBag()

    private let datasource: [Row]
    private var balance: Kin?

    init(_ account: KinAccount, network: Network) {
        self.account = account
        self.network = network

        datasource = {
            var datasource: [Row] = [
                .publicAddress,
                .balance,
                .backup
            ]
            
            if network != .mainNet {
                datasource.append(.createAccount)
            }

            return datasource
        }()

        super.init(nibName: nil, bundle: nil)

        watchAccountBalance()
        updateAccountBalance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        tableView.tableFooterView = UIView()
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "subtitle")
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: "value1")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
    }
}

// MARK: - Account

extension AccountViewController {
    @discardableResult
    fileprivate func createAccount() -> Promise<Void> {
        let promise = Promise<Void>()
        let url: URL = .friendBot(network, publicAddress: account.publicAddress)
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                promise.signal(error)
                return
            }

            guard let data = data, let _ = try? JSONSerialization.jsonObject(with: data, options: []) else {
                promise.signal(Error.invalidResponse(message: nil))
                return
            }

            promise.signal(Void())
        }).resume()

        return promise
    }

    @discardableResult
    fileprivate func fundAccount() -> Promise<Void> {
        let promise = Promise<Void>()
        let url: URL = .fund(network, publicAddress: account.publicAddress, amount: 1000)

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                promise.signal(error)
                return
            }

            guard let data = data, let d = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                promise.signal(Error.invalidResponse(message: nil))
                return
            }

            if let error = d["error"] as? String {
                promise.signal(Error.invalidResponse(message: error))
                return
            }

            promise.signal(Void())
        }).resume()

        return promise
    }

    @discardableResult
    fileprivate func updateAccountBalance() -> Promise<Void> {
        let promise = Promise<Void>()

        account.balance()
            .then(on: .main, { [weak self] balance in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.balance = balance

                if let indexPath = strongSelf.tableViewIndexPath(for: .balance) {
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                else {
                    strongSelf.tableView.reloadData()
                }

                promise.signal(Void())
            })
            .error { [weak self] error in
                DispatchQueue.main.async {
                    guard let strongSelf = self else {
                        return
                    }

                    guard let cell = strongSelf.tableViewCell(for: .balance) else {
                        return
                    }

                    if case KinError.invalidAmount = error {
                        cell.detailTextLabel?.text = "N/A"
                    }
                    else {
                        cell.detailTextLabel?.text = error.localizedDescription
                    }

                    promise.signal(error)
                }
        }

        return promise
    }

    fileprivate func watchAccountBalance() {
        self.watch = try? account.watchBalance(nil)
        self.watch?.emitter
            .on(queue: .main, next: { [weak self] balance in
                self?.updateAccountBalance()
            })
            .add(to: linkBag)
    }

    fileprivate func backupAccount() -> Promise<String> {
        do {
            let json = try account.export(passphrase: "")
            return Promise(json)
        }
        catch {
            return Promise(error)
        }
    }
}

// MARK: - Data Source

extension AccountViewController {
    fileprivate enum Row {
        case publicAddress
        case balance
        case backup
        case createAccount
    }
}

extension AccountViewController.Row {
    fileprivate var reuseIdentifier: String {
        switch self {
        case .publicAddress:
            return "subtitle"
        case .balance,
             .createAccount:
            return "value1"
        case .backup:
            return "default"
        }
    }

    fileprivate var title: String {
        switch self {
        case .publicAddress:
            return "Public Address"
        case .balance:
            return "Balance"
        case .backup:
            return "Backup"
        case .createAccount:
            return "Create Account"
        }
    }
}

// MARK: - Table View Data Source

extension AccountViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = row.title

        if row == .publicAddress {
            cell.detailTextLabel?.text = account.publicAddress
        }
        else if row == .balance {
            if let balance = balance {
                cell.detailTextLabel?.text = "\(balance) KIN"
            }
            else {
                cell.detailTextLabel?.text = "Loading..."
            }
        }

        return cell
    }
}

// MARK: - Table View Delegate

extension AccountViewController {
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let row = datasource[indexPath.row]

        switch row {
        case .balance:
            return false
        default:
            return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = datasource[indexPath.row]

        switch row {
        case .publicAddress:
            UIPasteboard.general.string = account.publicAddress
            tableView.deselectRow(at: indexPath, animated: true)
            print(account.publicAddress)

        case .backup:
            delegate?.accountViewController(self, backupAccount: account)

        case .createAccount:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.detailTextLabel?.text = "Creating..."

            createAccount()
                .then(on: .main) { [weak self] _ -> Promise<Void> in
                    guard let strongSelf = self else {
                        return Promise(Error.internalInconsistency)
                    }

                    guard strongSelf.network == .testNet else {
                        return Promise(Void())
                    }

                    cell?.detailTextLabel?.text = "Funding..."
                    return strongSelf.fundAccount()
                }
                .then(on: .main) { _ in
                    cell?.detailTextLabel?.text = nil
                }
                .error { error in
                    print(error)

                    DispatchQueue.main.async {
                        cell?.detailTextLabel?.text = "Error"
                    }
                }
                .finally {
                    DispatchQueue.main.async {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
            }

        default:
            break
        }
    }
}

// MARK: Table View

extension AccountViewController {
    fileprivate func tableViewIndexPath(for row: Row) -> IndexPath? {
        guard let balanceIndex = datasource.firstIndex(of: row) else {
            return nil
        }

        return IndexPath(row: balanceIndex, section: 0)
    }

    fileprivate func tableViewCell(for row: Row) -> UITableViewCell? {
        guard let indexPath = tableViewIndexPath(for: row) else {
            return nil
        }

        return tableView.cellForRow(at: indexPath)
    }
}

// MARK: - Error

extension AccountViewController {
    enum Error: Swift.Error {
        case invalidResponse (message: String?)
        case internalInconsistency
    }
}
