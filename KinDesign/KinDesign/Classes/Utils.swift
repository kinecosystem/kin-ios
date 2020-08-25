//
//  Utils.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-11-15.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit

public struct Utils {
    static let onePx = 1.0 / UIScreen.main.scale
}

public struct StandardConstants {
    public static let sidePadding: CGFloat = 16
    public static let cornerRadius: CGFloat = 6
}

public extension Bundle {
    class func kinDesign() -> Bundle? {
        return Bundle(identifier: "org.kin..KinDesign")
    }
}
