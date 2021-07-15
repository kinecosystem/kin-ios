//
//  Notification+Convenience.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 21/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

extension Notification {
    var endFrame: CGRect {
        if let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            return value
        }
        else {
            return .null
        }
    }
    
    var duration: TimeInterval {
        if let value = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            return value
        }
        else {
            return 0.25
        }
    }

    var animationOptions: UIView.AnimationOptions {
        if let value = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            return UIView.AnimationOptions(rawValue: UInt(value.uintValue << 16))
        }
        else {
            return []
        }
    }
}
