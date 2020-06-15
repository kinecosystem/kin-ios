//
//  UIFont+PreferredFont.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 17/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

extension UIFont {
    class func preferredFont(forTextStyle style: TextStyle, symbolicTraits: [UIFontDescriptor.SymbolicTraits]) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        var traits = font.fontDescriptor.symbolicTraits

        for symbolicTrait in symbolicTraits {
            traits.insert(symbolicTrait)
        }

        if let fontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: fontDescriptor, size: 0)
        }
        else {
            return font
        }
    }
}
