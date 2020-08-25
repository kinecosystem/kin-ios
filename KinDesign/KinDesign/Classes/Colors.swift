//
//  Colors.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-11-15.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit

public struct Colors {
    public struct Constants {
        public static let purpleHex: String     = "6F41E8"
        public static let orangeHex: String     = "F35041"
        public static let yellowHex: String     = "FFC34F"
        public static let greenHex: String      = "31D174"
        public static let gray1Hex: String      = "666666"
        public static let gray2Hex: String      = "8D8D94"
        public static let gray3Hex: String      = "BABBC2"
        public static let gray4Hex: String      = "E6E6EB"
        public static let gray5Hex: String      = "F0F0F5"
        public static let blackHex: String      = "272729"
    }
}

public extension UIColor {

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    static let kinPurple: UIColor = UIColor(hexString: Colors.Constants.purpleHex)
    static let kinOrange: UIColor = UIColor(hexString: Colors.Constants.orangeHex)
    static let kinYellow: UIColor = UIColor(hexString: Colors.Constants.yellowHex)
    static let kinGreen: UIColor = UIColor(hexString: Colors.Constants.greenHex)

    static let kinGray1: UIColor = UIColor(hexString: Colors.Constants.gray1Hex)
    static let kinGray2: UIColor = UIColor(hexString: Colors.Constants.gray2Hex)
    static let kinGray3: UIColor = UIColor(hexString: Colors.Constants.gray3Hex)
    static let kinGray4: UIColor = UIColor(hexString: Colors.Constants.gray4Hex)
    static let kinGray5: UIColor = UIColor(hexString: Colors.Constants.gray5Hex)

    static let kinBlack: UIColor = UIColor(hexString: Colors.Constants.blackHex)
}
