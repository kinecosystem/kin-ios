//
//  KinWalletInvoiceListViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

func invoiceListStorageKey(for account: KinAccount.Id) -> String {
    return  "kin_wallet_demo_invoice_list_\(account)"
}

class KinWalletInvoiceListViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private var invoices = [Invoice]()

    let accountContext: KinAccountContext

    init(accountContext: KinAccountContext) {
        self.accountContext = accountContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let key = invoiceListStorageKey(for: accountContext.accountId)
        if let storedData = UserDefaults.standard.data(forKey: key),
            let invoiceListBlob = try? KinStorageInvoiceListBlob(data: storedData),
            let invoiceList = invoiceListBlob.invoiceList {
            invoices = invoiceList.invoices
        }

        if invoices.isEmpty {
            addInvoices()
        }

        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

    func addInvoices() {
        let lineItem = try! LineItem(title: "Default Item",
                                     description: "Description",
                                     amount: Kin(25),
                                     sku: SKU(bytes: [Byte]("jfskdflajdsf".data(using: .utf8)!)))
        let invoice = try! Invoice(lineItems: [lineItem])
        let invoiceList = try! InvoiceList(invoices: [invoice])
        let data = invoiceList.storableObject.data()!
        let key = invoiceListStorageKey(for: accountContext.accountId)
        UserDefaults.standard.set(data, forKey: key)

        invoices = invoiceList.invoices
    }

    func clearInvoices() {
        let key = invoiceListStorageKey(for: accountContext.accountId)
        UserDefaults.standard.set(nil, forKey: key)
    }

    @objc func createInvoiceButtonTapped() {
        let vc = KinWalletCreateInvoiceViewController(accountId: accountContext.accountId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension KinWalletInvoiceListViewController: UITableViewDataSource {
    var rowHeight: CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Subtitle")

        let invoice = invoices[indexPath.row]

        cell.textLabel?.text = invoice.title
        cell.textLabel?.textColor = .kinBlack

        cell.detailTextLabel?.text = invoice.subtitle
        cell.detailTextLabel?.textColor = .kinGray2

        let amountView = KinAmountView(frame: .zero)
        amountView.amount = invoice.total
        amountView.size = .small
        amountView.color = .kinBlack
        amountView.sizeToFit()

        cell.accessoryView = amountView

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
        label.text = "Invoices"
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
        button.setTitle("Create Invoice", for: .normal)
        button.sizeToFit()
        button.frame = CGRect(x: 20, y: 0, width: button.frame.width, height: rowHeight)
        button.addTarget(self, action: #selector(createInvoiceButtonTapped), for: .touchUpInside)
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: tableView.frame.width,
                                        height: rowHeight))
        view.backgroundColor = .white
        view.addSubview(button)
        return button
    }
}

extension KinWalletInvoiceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = KinWalletInvoiceViewController(accountContext: accountContext, invoice: invoices[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension Invoice {
    var title: String {
        guard let firstItem = lineItems.first else {
            return "No item"
        }

        if lineItems.count == 1 {
            return firstItem.title
        } else {
            return "\(firstItem.title) & \(lineItems.count - 1) more items"
        }
    }

    var subtitle: String {
        guard let firstItemSku = lineItems.first?.sku else {
            return ""
        }

        return String(bytes: firstItemSku.bytes, encoding: .utf8) ?? ""
    }
}
