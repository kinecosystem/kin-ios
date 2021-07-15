//
//  Animations.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 17/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class Animations {
    static func animation(with keyPath: String,
                          duration: TimeInterval,
                          beginTime: TimeInterval,
                          from: Any,
                          to: Any,
                          curve: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        animation.beginTime = beginTime
        animation.timingFunction = curve
        animation.fillMode = .forwards
        return animation
    }

    static func animationGroup(animations: [CABasicAnimation], duration: TimeInterval) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.animations = animations
        group.duration = duration
        group.repeatCount = 1
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return group
    }
}
