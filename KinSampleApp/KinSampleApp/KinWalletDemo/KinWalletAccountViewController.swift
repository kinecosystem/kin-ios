//
//  KinWalletAccountViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

class KinWalletAccountViewController: UIViewController {

    let env: KinEnvironment
    let accountContext: KinAccountContext
    var kinAccount: KinAccount?
    var paymentHistory = [KinPayment]()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    lazy var headerView: AccountHeaderView = {
        let view = AccountHeaderView(frame: .zero)
        return view
    }()

    lazy var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .kinPurple
        spinner.center = self.view.center
        return spinner
    }()

    init(account: PublicKey) {
        self.env = KinEnvironment.Agora.testNet()
        self.accountContext = KinAccountContext
            .Builder(env: self.env)
            .useExistingAccount(account)
            .build()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        headerView.addressLabel.text = accountContext.accountPublicKey.base58

        loadingSpinner.startAnimating()
        accountContext.getAccount(forceUpdate: true)
            .then(on: .main) { [weak self] account in
                self?.kinAccount = account
                self?.headerView.amountView.amount = account.balance.amount
                self?.headerView.setNeedsLayout()
                self?.loadingSpinner.stopAnimating()
                
                _ = self?.accountContext.mergeTokenAccounts(for: account, appIndex: nil).then {
                    print("Merge token accounts success")
                }
            }
            .catch(on: .main) { [weak self] error in
                self?.loadingSpinner.stopAnimating()
                self?.presentSimpleAlert(title: nil, message: error.localizedDescription)
            }
        

        accountContext.observeBalance(mode: .active)
            .subscribe { [weak self] balance in
                DispatchQueue.main.async {
                    self?.headerView.amountView.amount = balance.amount
                    self?.headerView.setNeedsLayout()
                }
            }

        accountContext.observePayments(mode: .active)
            .subscribe { [weak self] payments in
                self?.paymentHistory = payments.sorted(by: { (payment1, payment2) -> Bool in
                    return payment1.timestamp < payment2.timestamp
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }

        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        tableView.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func copyWalletAddressTapped() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = accountContext.accountPublicKey.base58
    }

    private func sendKinTapped() {
        let vc = KinWalletSendKinViewController(accountContext: accountContext)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func invoicesTapped() {
        let vc = KinWalletInvoiceListViewController(accountContext: accountContext)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func fundWalletTapped() {
        loadingSpinner.startAnimating()
        env.testService?.fundAccount(accountContext.accountPublicKey, amount: 100)
            .then(on: .main) { [weak self] _ in
                print("funded")
                self?.loadingSpinner.stopAnimating()
            }
            .catch(on: .main) { [weak self] error in
                self?.loadingSpinner.stopAnimating()
                print(error)
            }
    }

    private func deleteAccountTapped() {
        accountContext.clearStorage()
            .then(on: .main) {  _ in
                var accounts = UserDefaults.standard.array(forKey: accountsStorageKey) as? [String] ?? []
                accounts.removeAll { $0 == self.accountContext.accountPublicKey.base58 }
                UserDefaults.standard.set(accounts, forKey: accountsStorageKey)

                self.navigationController?.popViewController(animated: true)
            }
    }
}

extension KinWalletAccountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }

        return paymentHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = .init()

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Copy Wallet Address"
                cell.textLabel?.textColor = .kinBlack
            }

            if indexPath.row == 1 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

                cell.textLabel?.text = "Send Kin"
                cell.textLabel?.textColor = .kinBlack

                cell.detailTextLabel?.text = "Transfer Kin to another wallet"
                cell.detailTextLabel?.textColor = .kinGray2
            }

            if indexPath.row == 2 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

                cell.textLabel?.text = "Invoices"
                cell.textLabel?.textColor = .kinBlack

                cell.detailTextLabel?.text = "Create & demo pay invoices"
                cell.detailTextLabel?.textColor = .kinGray2
            }

            if indexPath.row == 3 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

                cell.textLabel?.text = "Fund Wallet"
                cell.textLabel?.textColor = .kinBlack

                cell.detailTextLabel?.text = "Fund the wallet with 10K Kin"
                cell.detailTextLabel?.textColor = .kinGray2
            }

            if indexPath.row == 4 {
                cell = UITableViewCell(style: .default, reuseIdentifier: nil)

                cell.textLabel?.text = "Delete Wallet"
                cell.textLabel?.textColor = .kinOrange
            }
        }

        if indexPath.section == 1 {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Subtitle")
            let payment = paymentHistory[indexPath.row]

            cell.textLabel?.text = payment.destAccount.base58
            cell.textLabel?.textColor = .kinBlack

            cell.detailTextLabel?.text = payment.memo.text
            cell.detailTextLabel?.textColor = .kinGray2

            let amountView = KinAmountView(frame: .zero)
            amountView.amount = payment.amount
            amountView.size = .small
            amountView.color = .kinBlack
            amountView.sign = payment.destAccount == accountContext.accountPublicKey ? .positive : .negative
            amountView.sizeToFit()

            cell.accessoryView = amountView
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 157
        } else {
            return 50
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 157)
            return headerView
        }

        if section == 1 {
            let label = SecondaryLabel()
            label.text = "History"
            label.frame = CGRect(x: 20,
                                 y: 0,
                                 width: tableView.frame.width,
                                 height: 50)
            let view = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: tableView.frame.width,
                                            height: 50))
            view.backgroundColor = .white
            view.addSubview(label)
            return view
        }

        return UIView()
    }
}

extension KinWalletAccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                copyWalletAddressTapped()
            case 1:
                sendKinTapped()
            case 2:
                invoicesTapped()
            case 3:
                fundWalletTapped()
            case 4:
                deleteAccountTapped()
            default:
                break
            }
        }
    }
}

class AccountHeaderView: UIView {
    lazy var amountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.size = .large
        view.color = .kinBlack
        return view
    }()

    lazy var addressLabel: PrimaryLabel = {
        let view = PrimaryLabel(frame: .zero)
        view.numberOfLines = 2
        view.textColor = .kinGray2
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        addSubview(amountView)
        addSubview(addressLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        amountView.sizeToFit()
        amountView.center = center
        amountView.frame.origin.y = 30

        addressLabel.frame.size.width = 330
        addressLabel.sizeToFit()
        addressLabel.center = center
        addressLabel.frame.origin.y = amountView.frame.maxY + 20
    }
}

