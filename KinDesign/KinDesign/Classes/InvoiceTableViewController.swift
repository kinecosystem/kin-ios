//
//  InvoiceTableViewController.swift
//  KinDesign
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit

public struct InvoiceDisplayable {
    public struct LineItemDisplayable {
        public let title: String
        public let description: String
        public let amount: Decimal

        public init(title: String,
                    description: String,
                    amount: Decimal) {
            self.title = title
            self.description = description
            self.amount = amount
        }
    }

    public let lineItems: [LineItemDisplayable]
    public let fee: Decimal

    public init(lineItems: [LineItemDisplayable],
                fee: Decimal = Decimal(100)) {
        self.lineItems = lineItems
        self.fee = fee
    }
}

public protocol InvoiceTableViewControllerDelegate: AnyObject {
    func invoiceTablePayTapped()
}

public class InvoiceTableViewController: UIViewController {

    public var invoice: InvoiceDisplayable? {
        didSet {
            tableView.reloadData()
            footerView.invoice = invoice
        }
    }

    lazy var footerView: InvoiceTableFooterView = {
        let view = InvoiceTableFooterView(frame: .zero)
        view.payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InvoiceLineItemTableViewCell.self, forCellReuseIdentifier: InvoiceLineItemTableViewCell.description())
        tableView.scrollIndicatorInsets.bottom = footerView.defaultHeight
        tableView.contentInset.bottom = footerView.defaultHeight
        return tableView
    }()

    public weak var delegate: InvoiceTableViewControllerDelegate?

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        view.addSubview(tableView)
        view.addSubview(footerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var safeAreaBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaBottom = view.safeAreaInsets.bottom
        }

        footerView.frame = CGRect(x: 0,
                                  y: view.bounds.height - safeAreaBottom - footerView.defaultHeight,
                                  width: view.bounds.width,
                                  height: safeAreaBottom + footerView.defaultHeight)
    }

    @objc func payTapped() {
        delegate?.invoiceTablePayTapped()
    }
}

extension InvoiceTableViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoice?.lineItems.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceLineItemTableViewCell.description()) as? InvoiceLineItemTableViewCell,
            let item = invoice?.lineItems[indexPath.row] else {
            return .init()
        }

        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.description
        cell.amountView.amount = item.amount

        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = invoice?.lineItems[indexPath.row] else {
            return 0
        }

        return InvoiceLineItemTableViewCell.cellHeight(width: tableView.frame.width,
                                                       amount: item.amount,
                                                       description: item.description)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: tableView.frame.width,
                                        height: 55))
        view.backgroundColor = .white

        let label = PrimaryLabel(frame: CGRect(x: 20,
                                               y: 30,
                                               width: tableView.frame.width,
                                               height: 20))
        label.textColor = .kinPurple
        label.text = "Items"

        view.addSubview(label)

        return view
    }
}

extension InvoiceTableViewController: UITableViewDelegate {
    
}

public class InvoiceTableFooterView: UIView {

    lazy var subtotalLabel: PrimaryLabel = {
        let label = PrimaryLabel(frame: CGRect(x: 20,
                                               y: 30,
                                               width: self.frame.width,
                                               height: 20))
        label.text = "Subtotal"
        return label
    }()

    lazy var feeLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: CGRect(x: 20,
                                                 y: self.subtotalLabel.frame.maxY + 10,
                                               width: self.frame.width,
                                               height: 20))
        label.text = "Fee"
        return label
    }()

    lazy var totalLabel: PrimaryLabel = {
        let label = PrimaryLabel(frame: CGRect(x: 20,
                                               y: 30,
                                               width: self.frame.width,
                                               height: 20))
        label.text = "Total"
        return label
    }()

    lazy var subtotalAmountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.size = .small
        return view
    }()

    lazy var feeAmountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.size = .small
        view.color = .kinGray2
        return view
    }()

    lazy var totalAmountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.size = .large
        return view
    }()

    lazy var payButton: PrimaryButton = {
        let button = PrimaryButton(frame: .zero)
        button.setTitle("Pay Now", for: .normal)
        return button
    }()

    var invoice: InvoiceDisplayable? {
        didSet {
            guard let invoice = invoice else {
                return
            }

            subtotalAmountView.amount = invoice.lineItems.reduce(Decimal(0)) { $0 + $1.amount }
            feeAmountView.amount = invoice.fee
            totalAmountView.amount = subtotalAmountView.amount + feeAmountView.amount
            setNeedsLayout()
        }
    }

    var defaultHeight: CGFloat = 239

    override public init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(subtotalLabel)
        addSubview(feeLabel)
        addSubview(totalLabel)
        addSubview(subtotalAmountView)
        addSubview(feeAmountView)
        addSubview(totalAmountView)
        addSubview(payButton)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let sidePadding: CGFloat = 20

        subtotalAmountView.sizeToFit()
        subtotalAmountView.frame.origin = CGPoint(x: bounds.width - sidePadding - subtotalAmountView.bounds.width,
                                                  y: 30)

        feeAmountView.sizeToFit()
        feeAmountView.frame.origin = CGPoint(x: bounds.width - sidePadding - feeAmountView.bounds.width,
                                             y: subtotalAmountView.frame.maxY + 6)

        totalAmountView.sizeToFit()
        totalAmountView.frame.origin = CGPoint(x: bounds.width - sidePadding - totalAmountView.bounds.width,
                                             y: feeAmountView.frame.maxY + 24)

        subtotalLabel.sizeToFit()
        subtotalLabel.frame.origin = CGPoint(x: sidePadding,
                                             y: subtotalAmountView.frame.minY)

        feeLabel.sizeToFit()
        feeLabel.frame.origin = CGPoint(x: sidePadding,
                                        y: feeAmountView.frame.minY)

        totalLabel.sizeToFit()
        totalLabel.frame.origin = CGPoint(x: sidePadding,
                                          y: totalAmountView.frame.minY)

        payButton.sizeToFit()
        payButton.frame.origin = CGPoint(x: sidePadding,
                                         y: totalAmountView.frame.maxY + sidePadding)
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = superview?.bounds.width ?? 0
        return CGSize(width: width, height: defaultHeight)
    }
}
