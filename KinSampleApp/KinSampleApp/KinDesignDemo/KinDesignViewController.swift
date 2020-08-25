//
//  KinDesignViewController.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit
import KinDesign

class KinDesignViewController: UIViewController {
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = false
        table.register(KinDesignDemoTableViewCell.self,
                       forCellReuseIdentifier: "KinDesignDemoTableViewCell")
        return table
    }()

    lazy var primaryButton: PrimaryButton = {
        let button = PrimaryButton(frame: .zero)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Kin Design Demo"
        view.addSubview(tableView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tableView.frame = view.bounds
        tableView.reloadData()
    }
}

extension KinDesignViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KinDesignDemoCellType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KinDesignDemoTableViewCell") as? KinDesignDemoTableViewCell else {
            return .init()
        }

        let cellType = KinDesignDemoCellType.allCases[indexPath.row]
        cell.type = cellType

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = KinDesignDemoCellType.allCases[indexPath.row]
        return cellType.cellHeight
    }
}

extension KinDesignViewController: UITableViewDelegate {

}


