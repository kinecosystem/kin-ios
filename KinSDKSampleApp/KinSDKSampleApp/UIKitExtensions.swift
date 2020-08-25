//
//  UIKitExtensions.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

extension UIColor {
    static var kin = UIColor(red:0.00, green:0.80, blue:0.92, alpha:1.00)
    static var testNet = UIColor(red:0.00, green:0.75, blue:0.98, alpha:1.00)
    static var mainNet = UIColor(red:0.94, green:0.56, blue:0.21, alpha:1.00)
}

extension UIImage {
    class func from(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
