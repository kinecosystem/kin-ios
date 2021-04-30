//
//  KinWalletCreateInvoiceViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinBase
import KinDesign

class KinWalletCreateInvoiceViewController: UIViewController {

    lazy var amountTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Amount"
        field.keyboardType = .decimalPad
        return field
    }()

    lazy var amountLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.amountTextField.addSubview(line)
        return line
    }()

    lazy var titleTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Title"
        return field
    }()

    lazy var titleLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.titleTextField.addSubview(line)
        return line
    }()

    lazy var descTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "Description"
        return field
    }()

    lazy var descLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.descTextField.addSubview(line)
        return line
    }()

    lazy var skuTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "SKU"
        field.keyboardType = .numberPad
        return field
    }()

    lazy var skuLine: UIView = {
        let line = UIView(frame: .zero)
        line.backgroundColor = .kinGray2
        self.skuTextField.addSubview(line)
        return line
    }()

    lazy var addLineItemButton: InlineActionButton = {
        let button = InlineActionButton(frame: .zero)
        button.setTitle("Add Line Item", for: .normal)
        button.addTarget(self, action: #selector(addLineItemButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var createInvoiceButton: PrimaryButton = {
        let button = PrimaryButton(frame: .zero)
        button.setTitle("Create Invoice", for: .normal)
        button.addTarget(self, action: #selector(createInvoiceButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.separatorStyle = .none
        tableView.dataSource = self
        return tableView
    }()

    var lineItems = [LineItem]()

    let account: PublicKey

    init(account: PublicKey) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(amountTextField)
        view.addSubview(titleTextField)
        view.addSubview(descTextField)
        view.addSubview(skuTextField)
        view.addSubview(createInvoiceButton)
        view.addSubview(addLineItemButton)

        view.addSubview(tableView)
        tableView.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let height: CGFloat = 50

        amountTextField.frame = CGRect(x: .defaultPadding,
                                       y: .defaultPadding + view.safeAreaInsets.top,
                                       width: view.bounds.width - .defaultPadding * 2,
                                       height: height)
        amountLine.frame = CGRect(x: 0,
                                  y: amountTextField.frame.height - 1,
                                  width: amountTextField.frame.width,
                                  height: 0.5)

        titleTextField.frame = CGRect(x: .defaultPadding,
                                      y: .defaultPadding + amountTextField.frame.maxY,
                                      width: view.bounds.width - .defaultPadding * 2,
                                      height: height)
        titleLine.frame = CGRect(x: 0,
                                 y: titleTextField.frame.height - 1,
                                 width: titleTextField.frame.width,
                                 height: 0.5)

        descTextField.frame = CGRect(x: .defaultPadding,
                                    y: .defaultPadding + titleTextField.frame.maxY,
                                    width: view.bounds.width - .defaultPadding * 2,
                                    height: height)
        descLine.frame = CGRect(x: 0,
                                y: descTextField.frame.height - 1,
                                width: descTextField.frame.width,
                                height: 0.5)

        skuTextField.frame = CGRect(x: .defaultPadding,
                                    y: .defaultPadding + descTextField.frame.maxY,
                                    width: view.bounds.width - .defaultPadding * 2,
                                    height: height)
        skuLine.frame = CGRect(x: 0,
                               y: skuTextField.frame.height - 1,
                               width: skuTextField.frame.width,
                               height: 0.5)

        addLineItemButton.sizeToFit()
        addLineItemButton.frame.origin = CGPoint(x: .defaultPadding, y: skuTextField.frame.maxY + .defaultPadding)

        createInvoiceButton.sizeToFit()
        createInvoiceButton.center = view.center
        createInvoiceButton.frame.origin.y = view.bounds.height - view.safeAreaInsets.bottom - .defaultPadding - createInvoiceButton.frame.height

        tableView.frame = CGRect(x: 0,
                                 y: addLineItemButton.frame.maxY,
                                 width: view.frame.width,
                                 height: createInvoiceButton.frame.minY - addLineItemButton.frame.maxY)
    }

    @objc func createInvoiceButtonTapped() {
        guard !lineItems.isEmpty else {
            return
        }

        guard let newInvoice = try? Invoice(lineItems: lineItems) else {
            return
        }

        let key = invoiceListStorageKey(for: account)

        var invoices = [Invoice]()
        if let storedData = UserDefaults.standard.data(forKey: key),
            let invoiceListBlob = try? KinStorageInvoiceListBlob(data: storedData),
            let invoiceList = invoiceListBlob.invoiceList {
            invoices = invoiceList.invoices
        }

        invoices.append(newInvoice)

        guard let newInvoiceList = try? InvoiceList(invoices: invoices),
            let data = newInvoiceList.storableObject.data() else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)

        navigationController?.popViewController(animated: true)
    }

    @objc func addLineItemButtonTapped() {
        guard let amountText = amountTextField.text,
            let amountDecimal = Decimal(string: amountText),
            let title = titleTextField.text else {
                return
        }

        var sku: SKU?
        if let skuText = skuTextField.text,
            let skuData = skuText.data(using: .utf8) {
            sku = SKU(bytes: [Byte](skuData))
        }
        guard let lineItem = try? LineItem(title: title,
                                           description: descTextField.text,
                                           amount: amountDecimal,
                                           sku: sku) else {
                                            return
        }

        lineItems.append(lineItem)
        tableView.reloadData()

        amountTextField.text = nil
        titleTextField.text = nil
        descTextField.text = nil
        skuTextField.text = nil
    }
}

extension KinWalletCreateInvoiceViewController: UITableViewDataSource {
    var rowHeight: CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Subtitle")

        let item = lineItems[indexPath.row]

        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = .kinBlack

        cell.detailTextLabel?.text = item.description
        cell.detailTextLabel?.textColor = .kinGray2

        let amountView = KinAmountView(frame: .zero)
        amountView.amount = item.amount
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
        label.text = "Line Items"
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
}
