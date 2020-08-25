//
//  Utils.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    static let defaultPadding: CGFloat = 20
}


extension UIViewController {
    func presentSimpleAlert(title: String? = nil,
                            message: String? = nil,
                            callback: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: callback)
        }))
        present(alert, animated: true, completion: nil)
    }
}
