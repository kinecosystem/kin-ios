//
//  KinWalletDemoViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

let accountsStorageKey = "kin_wallet_demo_accounts"

class KinWalletDemoViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private var accounts = [KinAccount.Id]()

    init() {
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Kin Wallet Demo"

        view.addSubview(tableView)
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accounts = (UserDefaults.standard.array(forKey: accountsStorageKey) as? [String]) ?? []
        tableView.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

    @objc func addNewAccountButtonTapped() {
        guard let newAccountContext = try? KinAccountContext
            .Builder(env: KinEnvironment.Agora.testNet(testMigration: AppDelegate.enableTestMigration))
            .createNewAccount()
            .build() else {
                return
        }

        accounts.append(newAccountContext.accountId)
        UserDefaults.standard.set(accounts, forKey: accountsStorageKey)

        tableView.reloadData()
    }
}

extension KinWalletDemoViewController: UITableViewDataSource {
    var rowHeight: CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description()) else {
            return .init()
        }

        cell.textLabel?.text = accounts[indexPath.row]
        cell.textLabel?.textColor = .kinBlack

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = SecondaryLabel()
        label.text = "Test Network"
        label.frame = CGRect(x: 20,
                             y: 0,
                             width: tableView.frame.width,
                             height: rowHeight)
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: tableView.frame.width,
                                        height: rowHeight))
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let button = InlineActionButton(frame: .zero)
        button.setTitle("Add New Wallet", for: .normal)
        button.sizeToFit()
        button.frame = CGRect(x: 20, y: 0, width: button.frame.width, height: rowHeight)
        button.addTarget(self, action: #selector(addNewAccountButtonTapped), for: .touchUpInside)
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: tableView.frame.width,
                                        height: rowHeight))
        view.backgroundColor = .white
        view.addSubview(button)
        return button
    }
}

extension KinWalletDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let accountViewController = KinWalletAccountViewController(accountId: accounts[indexPath.row])
        navigationController?.pushViewController(accountViewController, animated: true)
    }
}
