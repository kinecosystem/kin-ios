//
//  OrderCellTimelineView.swift
//  KinEcosystem
//
//  Created by Elazar Yifrach on 05/03/2018.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

internal class OrderCellTimelineView: UIView {

    public var last: Bool? {
        didSet {
            setNeedsDisplay()
        }
    }

    public var first: Bool? {
        didSet {
            setNeedsDisplay()
        }
    }

    var icon: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }

    public override func draw(_ rect: CGRect) {

        guard let last = last, let first = first, let icon = icon else {
            super.draw(rect)
            return
        }
        let midX = rect.midX + 4.0
        let top = CGPoint(x: midX, y: 0.0)
        let mid = CGPoint(x: midX, y: rect.midY - 10.0)
        let bottom = CGPoint(x: midX, y: rect.height)
        let line = UIBezierPath()

        line.lineWidth = 1.0
        line.setLineDash([5.0, 4.0], count: 2, phase: 0)
        line.lineCapStyle = .round
        line.move(to: top)

        if last == false {
            if first {
                line.move(to: mid)
            }
            line.addLine(to: bottom)
        } else if first == false {
            line.addLine(to: mid)
        }
        UIColor.kinGray3.setStroke()
        line.stroke()

        UIColor.white.setFill()
        let imageSize = icon.size.width
        let imagePad = icon.size.width / 2.0
        let imageRect = CGRect(x: mid.x - imagePad, y: mid.y - imagePad, width: imageSize, height: imageSize)
        icon.draw(in: imageRect)
    }
}
