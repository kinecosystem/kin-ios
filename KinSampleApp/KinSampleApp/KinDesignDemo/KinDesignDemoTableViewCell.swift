//
//  KinDesignDemoTableViewCell.swift
//  KinSampleApp
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import KinDesign
import UIKit

enum KinDesignDemoCellType: String, CaseIterable {
    case primaryButton                      = "Primary Button"
    case positiveActionButton               = "Positive Action Button"
    case negativeActionButton               = "Negative Action Button"
    case inlineActionButton                 = "Inline Action Button"
    case kinAmountViewLarge                 = "Kin Amount View Large"
    case kinAmountViewMedium                = "Kin Amount View Medium Positive"
    case kinAmountViewSmall                 = "Kin Amount View Small"
    case kinAmountViewLargeNegative         = "Kin Amount View Large Negative"
    case paymentConfirmationInfoState       = "Payment Confirmation Info State"
    case paymentConfirmationPendingState    = "Payment Confirmation Pending State"
    case paymentConfirmationConfirmedState  = "Payment Confirmation Confirmed State"
    case paymentConfirmationErrorState      = "Payment Confirmation Error State"

    var cellHeight: CGFloat {
        switch self {
        case .primaryButton:
            return 124
        case .positiveActionButton,
             .negativeActionButton,
             .inlineActionButton:
            return 114
        case .kinAmountViewLarge:
            return 106
        case .kinAmountViewMedium:
            return 94
        case .kinAmountViewSmall:
            return 88
        case .kinAmountViewLargeNegative:
            return 106
        case .paymentConfirmationInfoState,
             .paymentConfirmationPendingState,
             .paymentConfirmationConfirmedState,
             .paymentConfirmationErrorState:
            return 408
        }
    }
}

class KinDesignDemoTableViewCell: UITableViewCell {
    var type: KinDesignDemoCellType {
        didSet {
            update()
        }
    }

    lazy var titleLabel: PrimaryLabel = {
        return PrimaryLabel(frame: .zero)
    }()

    var demoView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        type = .primaryButton
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        contentView.backgroundColor = .white

        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let padding = StandardConstants.sidePadding

        guard let demoView = demoView else {
            return
        }

        demoView.sizeToFit()
        demoView.frame.origin = CGPoint(x: padding,
                                        y: titleLabel.frame.maxY + padding)
    }

    private func update() {
        let padding = StandardConstants.sidePadding

        titleLabel.text = type.rawValue
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: padding, y: padding)
        contentView.addSubview(titleLabel)

        demoView = self.createDemoView(for: type)
        contentView.addSubview(demoView!)
    }

    private func createDemoView(for type: KinDesignDemoCellType) -> UIView {
        switch type {
        case .primaryButton:
            let button = PrimaryButton(frame: .zero)
            button.setTitle(type.rawValue, for: .normal)
            return button
        case .positiveActionButton:
            let button = PositiveActionButton(frame: .zero)
            button.setTitle("Confirm", for: .normal)
            return button
        case .negativeActionButton:
            let button = NegativeActionButton(frame: .zero)
            button.setTitle("Cancel", for: .normal)
            return button
        case .inlineActionButton:
            let button = InlineActionButton(frame: .zero)
            button.setTitle("Cancel", for: .normal)
            return button
        case .kinAmountViewLarge:
            let kinAmountView = KinAmountView(frame: .zero)
            kinAmountView.size = .large
            kinAmountView.amount = Decimal(floatLiteral: 10999000.01)
            return kinAmountView
        case .kinAmountViewMedium:
            let kinAmountView = KinAmountView(frame: .zero)
            kinAmountView.size = .medium
            kinAmountView.sign = .positive
            kinAmountView.amount = Decimal(floatLiteral: 10999000.01)
            return kinAmountView
        case .kinAmountViewSmall:
            let kinAmountView = KinAmountView(frame: .zero)
            kinAmountView.size = .small
            kinAmountView.amount = Decimal(floatLiteral: 10999000.01)
            return kinAmountView
        case .kinAmountViewLargeNegative:
            let kinAmountView = KinAmountView(frame: .zero)
            kinAmountView.size = .large
            kinAmountView.amount = Decimal(floatLiteral: 10999000.01)
            kinAmountView.sign = .negative
            return kinAmountView
        case .paymentConfirmationInfoState:
            contentView.backgroundColor = .kinGray4
            let confirmationView = PaymentConfirmationView(merchantName: "Demo App",
                                                           merchantIcon: UIImage(named: "ic_launcher")!,
                                                           amount: Decimal(integerLiteral: 100),
                                                           newBalance: Decimal(integerLiteral: 9900))
            confirmationView.delegate = self
            return confirmationView
        case .paymentConfirmationPendingState:
            contentView.backgroundColor = .kinGray4
            let confirmationView = PaymentConfirmationView(merchantName: "Demo App",
                                                           merchantIcon: UIImage(named: "ic_launcher")!,
                                                           amount: Decimal(integerLiteral: 100),
                                                           newBalance: Decimal(integerLiteral: 9900))
            confirmationView.state = .pending
            confirmationView.delegate = self
            return confirmationView
        case .paymentConfirmationConfirmedState:
            contentView.backgroundColor = .kinGray4
            let confirmationView = PaymentConfirmationView(merchantName: "Demo App",
                                                           merchantIcon: UIImage(named: "ic_launcher")!,
                                                           amount: Decimal(integerLiteral: 100),
                                                           newBalance: Decimal(integerLiteral: 9900))
            confirmationView.state = .confirmed
            confirmationView.delegate = self
            return confirmationView
        case .paymentConfirmationErrorState:
            contentView.backgroundColor = .kinGray4
            let confirmationView = PaymentConfirmationView(merchantName: "Demo App",
                                                           merchantIcon: UIImage(named: "ic_launcher")!,
                                                           amount: Decimal(integerLiteral: 100),
                                                           newBalance: Decimal(integerLiteral: 9900))
            confirmationView.state = .error(message: nil)
            confirmationView.delegate = self
            return confirmationView
        }
    }
}

extension KinDesignDemoTableViewCell: PaymentConfirmationViewDelegate {
    func paymentConfirmationPayNowTapped() {
        print("pay now tapped")
    }

    func paymentConfirmationCancelTapped() {
        print("cancel tapped")
    }

    func paymentConfirmationCloseTapped() {
        print("close tapped")
    }
}
