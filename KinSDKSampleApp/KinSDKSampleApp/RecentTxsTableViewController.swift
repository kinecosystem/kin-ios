//
//  RecentTxsTableViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class RecentTxsTableViewController: UITableViewController {
    private var txs = [PaymentInfo]()
    private var filteredTxs: [PaymentInfo]?

    private var watch: PaymentWatch?
    private var memoFilter = Observable<String?>()
    private let linkBag = LinkBag()

    private var formatter: DateFormatter!

    var kinAccount: KinAccount!

    override func viewDidLoad() {
        super.viewDidLoad()

        formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long

        watch = try? kinAccount.watchPayments(cursor: nil)
        watch?.emitter
            .accumulate(limit: 100)
            .combine(with: memoFilter)
            .map({ (payments, filterText) -> [PaymentInfo]? in
                return payments?.reversed().filter({
                    guard let filterText = filterText else {
                        return true
                    }

                    if let filterText = filterText, !filterText.isEmpty {
                        return $0.memoText?.contains(filterText) ?? false
                    }

                    return true
                })
            })
            .on(next: { [weak self] payments in
                self?.filteredTxs = payments
            })
            .on(queue: .main, next: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .add(to: linkBag)
    }
}

// MARK: - Table view data source

extension RecentTxsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTxs?.count ?? txs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tx = filteredTxs?[indexPath.row] ?? txs[indexPath.row]

        let cell: TxCell

        let reuseIdentifier = tx.debit ? "OutgoingCell" : "IncomingCell"

        cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TxCell

        cell.addressLabel.text = tx.source == kinAccount.publicAddress ? tx.destination : tx.source
        cell.amountLabel.text = String(describing: tx.amount)
        cell.dateLabel.text = formatter.string(from: tx.createdAt)

        cell.memoLabel.text = tx.memoText

        return cell
    }
}

extension RecentTxsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let new = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        memoFilter.next(new)

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        memoFilter.next(nil)

        return true
    }
}
