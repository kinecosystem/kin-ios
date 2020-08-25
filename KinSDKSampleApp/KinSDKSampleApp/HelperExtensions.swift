//
//  HelperExtensions.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

extension String {
    func prettified() -> String? {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: []),
            let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let prettyPrinted = String(data: prettyPrintedData, encoding: String.Encoding.utf8)
            else {
                return nil
        }
        
        return prettyPrinted
    }
}

extension UIButton {
    func fill(with color: UIColor) {
        setTitleColor(.white, for: .normal)
        setBackgroundImage(UIImage.from(color), for: .normal)
        setBackgroundImage(UIImage.from(color.withAlphaComponent(0.9)), for: .highlighted)
    }
}
