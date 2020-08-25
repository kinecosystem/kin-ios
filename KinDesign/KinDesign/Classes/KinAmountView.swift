//
//  KinAmountView.swift
//  KinDesign
//
//  Created by Kik Interactive Inc. on 2019-11-22.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

public class KinAmountView: UIView {

    public enum Sign {
        case none
        case positive
        case negative
    }

    public enum Size: CGFloat {
        case small = 16
        case medium = 21
        case large = 31

        var kinIconSize: CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 10
            case .large:
                return 15
            }
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: self.size.rawValue)
        return label
    }()

    public var amount: Decimal = 0 {
        didSet {
            label.attributedText = amountAttributedString(amount.kinFormattedString,
                                                          font: label.font!,
                                                          color: color)

            label.sizeToFit()
        }
    }

    public var size: Size = .large {
        didSet {
            label.font = .boldSystemFont(ofSize: self.size.rawValue)
        }
    }

    public var color: UIColor = .black {
        didSet {
            setNeedsLayout()
        }
    }

    public var sign: Sign = .none {
        didSet {
            setNeedsLayout()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(label)
        label.backgroundColor = .clear
        label.textAlignment = .left
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return label.sizeThatFits(size)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Trigger reset
        let resetAmount = amount
        amount = resetAmount
    }

    private func amountAttributedString(_ string: String,
                                        font: UIFont,
                                        color: UIColor) -> NSAttributedString {
        guard var kinImage = UIImage(named: "kin_amount_icon",
                                     in: Bundle.kinDesign(),
                                     compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate) else {
                return NSAttributedString()
        }

        if #available(iOS 13.0, *) {
            kinImage = kinImage.withTintColor(color)
        } else if color == UIColor.kinGray2 {
            kinImage = UIImage(named: "kin_amount_icon_gray1",
                               in: Bundle.kinDesign(),
                               compatibleWith: nil) ?? kinImage
        }

        let imageSize = font.pointSize / 2

        // https://stackoverflow.com/questions/26105803/center-nstextattachment-image-next-to-single-line-uilabel
        let kinAttachment = NSTextAttachment()
        kinAttachment.bounds = CGRect(x: 0,
                                      y: (font.capHeight - imageSize) / 2,
                                      width: imageSize,
                                      height: imageSize)
        kinAttachment.image = kinImage

        // Apply Kin icon
        let mAttachmentString = NSMutableAttributedString(attachment: kinAttachment)
        mAttachmentString.appendSpacing(points: 5)

        // Apply color and font
        var string = string
        switch sign {
        case .positive:
            string = "+ " + string
        case .negative:
            string = "-" + string
        default:
            break
        }
        let mAttributedString = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: string.count)
        mAttributedString.addAttribute(.foregroundColor,
                                       value: color,
                                       range: range)
        mAttributedString.addAttribute(.font,
                                       value: font,
                                       range: range)

        var index = 0
        if sign == .positive {
            index = 2
        }
        mAttributedString.insert(mAttachmentString, at: index)

        return mAttributedString
    }
}

extension String {
    func attributed(_ size: CGFloat, weight: UIFont.Weight, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [.font : UIFont.systemFont(ofSize: size,
                                                                         weight: weight),
                                               .foregroundColor : color])
    }
}

extension NSAttributedString {

    func applyingTextAlignment(_ textAlignment: NSTextAlignment) -> NSAttributedString {
        let mAttributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        mAttributedString.addAttribute(.paragraphStyle,
                                       value: paragraphStyle,
                                       range: NSRange(location: 0, length: string.count))
        return mAttributedString
    }
}

func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()
    result.append(lhs)
    result.append(rhs)
    return result
}


extension NSMutableAttributedString {
    func appendSpacing(points: Float) {
        // zeroWidthSpace is 200B
        let spacing = NSAttributedString(string: "\u{200B}", attributes:[ NSAttributedString.Key.kern: points])
        append(spacing)
    }
}

extension Decimal {
    var kinFormattedString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber)!
    }
}
