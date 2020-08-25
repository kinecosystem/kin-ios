//
//  KinNavigationController.swift
//  KinUX
//
//  Created by Kik Engineering on 2019-11-19.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit
import KinDesign

public class KinNavigationController: UINavigationController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .kinBlack
        view.backgroundColor = .clear
    }
}
