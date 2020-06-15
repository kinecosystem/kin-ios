//
//  ConfirmButton.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 25/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

class ConfirmButton: RoundButton {
    fileprivate var transitionToConfirmedCompletion: (()->())?
    
    func transitionToConfirmed(completion: (()->())? = nil) {
        backgroundColor = .clear
        setTitleColor(.clear, for: .normal)

        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.fillColor = Appearance.shared.primary.cgColor
        shape.strokeColor = UIColor.clear.cgColor
        let shapePath = UIBezierPath(roundedRect: shape.bounds, cornerRadius: shape.bounds.height / 2).cgPath
        shape.path = shapePath
        layer.addSublayer(shape)

        let vShape = CAShapeLayer()
        vShape.bounds = CGRect(x: 0, y: 0, width: 19, height: 12)
        vShape.position = shape.position
        vShape.strokeColor = UIColor.white.cgColor
        vShape.lineWidth = 2

        let vPath = UIBezierPath()
        vPath.move(to: CGPoint(x: 0, y: 6))
        vPath.addLine(to: CGPoint(x: 6, y: vShape.bounds.height))
        vPath.addLine(to: CGPoint(x: vShape.bounds.width, y: 0))
        vShape.path = vPath.cgPath
        vShape.fillColor = UIColor.clear.cgColor
        vShape.strokeStart = 0
        vShape.strokeEnd = 0
        layer.addSublayer(vShape)

        let duration = 0.64

        var pathRect = CGRect()
        pathRect.size.width = bounds.size.height
        pathRect.size.height = bounds.size.height
        pathRect.origin.x = (bounds.size.width / 2) - (pathRect.size.width / 2)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: pathRect.size.height / 2).cgPath

        let pathAnimation = Animations.animation(with: "path", duration: duration * 0.25, beginTime: 0, from: shapePath, to: path)
        let shapeGroup = Animations.animationGroup(animations: [pathAnimation], duration: duration)
        shape.add(shapeGroup, forKey: "shrink")

        let vPathAnimation = Animations.animation(with: "strokeEnd", duration: duration * 0.45, beginTime: duration * 0.55, from: 0, to: 1)
        let vPathGroup = Animations.animationGroup(animations: [vPathAnimation], duration: duration)
        vPathGroup.delegate = self
        vShape.add(vPathGroup, forKey: "vStroke")

        transitionToConfirmedCompletion = completion
    }
}

extension ConfirmButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        transitionToConfirmedCompletion?()
        transitionToConfirmedCompletion = nil
    }
}
