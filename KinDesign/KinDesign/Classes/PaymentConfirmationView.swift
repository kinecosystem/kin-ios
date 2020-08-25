//
//  PaymentConfirmationView.swift
//  KinDesign
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit

public protocol PaymentConfirmationViewDelegate: AnyObject {
    func paymentConfirmationPayNowTapped()
    func paymentConfirmationCancelTapped()
    func paymentConfirmationCloseTapped()
}

public class PaymentConfirmationView: UIView {
    public enum State {
        case info
        case pending
        case confirmed
        case error(message: String?)
    }

    public var state: State = .info {
        didSet {
            stateView.removeFromSuperview()

            switch state {
            case .pending:
                stateView = PendingView(frame: .zero)
            case .confirmed:
                stateView = ConfirmedView(frame: .zero)
            case .error(let message):
                stateView = ErrorView(frame: .zero)
                (stateView as! ErrorView).errorMessage = message
            default:
                return
            }

            stateView.delegate = delegate
            stateView.sizeToFit()
            addSubview(stateView)
        }
    }

    public weak var delegate: PaymentConfirmationViewDelegate? {
        didSet {
            stateView.delegate = delegate
        }
    }

    private var stateView: PaymentConfirmationStateView

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(merchantName: String,
                merchantIcon: UIImage,
                amount: Decimal,
                newBalance: Decimal,
                delegate: PaymentConfirmationViewDelegate? = nil) {
        let infoView = InfoView(merchantName: merchantName,
                                merchantIcon: merchantIcon,
                                amount: amount,
                                newBalance: newBalance)
        self.stateView = infoView
        self.stateView.delegate = delegate
        self.delegate = delegate

        super.init(frame: .zero)

        stateView.sizeToFit()
        addSubview(stateView)

        backgroundColor = .white

        layer.cornerRadius = StandardConstants.cornerRadius
        layer.masksToBounds = true

        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 15
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return stateView.sizeThatFits(size)
    }
}

fileprivate protocol PaymentConfirmationStateView: UIView {
    var delegate: PaymentConfirmationViewDelegate? { get set }
}

fileprivate class InfoView: UIView, PaymentConfirmationStateView {
    lazy var merchantIconView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        view.image = self.merchantIcon
        return view
    }()

    lazy var payButton: PositiveActionButton = {
        let button = PositiveActionButton(frame: .zero)
        button.setTitle("Pay Now", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(payNowTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var cancelButton: InlineActionButton = {
        let button = InlineActionButton(frame: .zero)
        button.setTitle("Cancel", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var amountView: KinAmountView = {
        let view = KinAmountView(frame: .zero)
        view.amount = self.amount
        view.sizeToFit()
        return view
    }()

    lazy var infoLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: .zero)
        label.text = "Spend on \(self.merchantName)? Your new balance will be \(self.newBalance.kinFormattedString) Kin."
        label.textAlignment = .center
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()

    let merchantName: String
    let merchantIcon: UIImage
    let amount: Decimal
    let newBalance: Decimal

    weak var delegate: PaymentConfirmationViewDelegate?

    init(merchantName: String,
         merchantIcon: UIImage,
         amount: Decimal,
         newBalance: Decimal) {
        self.merchantName = merchantName
        self.merchantIcon = merchantIcon
        self.amount = amount
        self.newBalance = newBalance

        super.init(frame: .zero)

        addSubview(merchantIconView)
        addSubview(payButton)
        addSubview(cancelButton)
        addSubview(amountView)
        addSubview(infoLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        cancelButton.frame.origin = CGPoint(x: bounds.width - cancelButton.bounds.width - 5,
                                            y: 5)
        merchantIconView.center = center
        merchantIconView.frame.origin.y = 68

        amountView.center = center
        amountView.frame.origin.y = merchantIconView.frame.maxY + 16

        infoLabel.frame.size.width = bounds.width - 55 * 2
        infoLabel.sizeToFit()
        infoLabel.center = center
        infoLabel.frame.origin.y = amountView.frame.maxY + 10

        payButton.sizeToFit()
        payButton.center = center
        payButton.frame.origin.y = infoLabel.frame.maxY + 20
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - StandardConstants.sidePadding * 2,
                      height: 339)
    }

    @objc func payNowTapped(_ sender: UIControl) {
        delegate?.paymentConfirmationPayNowTapped()
    }

    @objc func cancelTapped(_ sender: UIControl) {
        delegate?.paymentConfirmationCancelTapped()
    }
}

fileprivate class PendingView: UIView, PaymentConfirmationStateView {
    var delegate: PaymentConfirmationViewDelegate?

    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.hidesWhenStopped = false
        view.color = .kinPurple
        return view
    }()

    lazy var infoLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: .zero)
        label.text = "Confirming your transaction"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        addSubview(infoLabel)

        spinner.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        spinner.frame.size = CGSize(width: 64, height: 64)
        spinner.center = center
        spinner.frame.origin.y = 120

        infoLabel.center = center
        infoLabel.frame.origin.y = spinner.frame.maxY + 21
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - StandardConstants.sidePadding * 2,
                      height: 339)
    }
}

fileprivate class ConfirmedView: UIView, PaymentConfirmationStateView {
    var delegate: PaymentConfirmationViewDelegate?

    lazy var checkmarkView: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: 26.8, height: 20.6)))
        view.image = UIImage(named: "confirmation_check",
                             in: Bundle.kinDesign(),
                             compatibleWith: nil)
        return view
    }()

    lazy var circleView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = UIImage(named: "confirmation_circle",
                             in: Bundle.kinDesign(),
                             compatibleWith: nil)
        return view
    }()

    lazy var infoLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: .zero)
        label.text = "Confirmed"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(checkmarkView)
        addSubview(circleView)
        addSubview(infoLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        circleView.frame.size = CGSize(width: 64, height: 64)
        circleView.center = center
        circleView.frame.origin.y = 120

        checkmarkView.center = circleView.center

        infoLabel.center = center
        infoLabel.frame.origin.y = circleView.frame.maxY + 21
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - StandardConstants.sidePadding * 2,
                      height: 339)
    }
}

fileprivate class ErrorView: UIView, PaymentConfirmationStateView {
    var delegate: PaymentConfirmationViewDelegate?

    lazy var exclamationView: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: 10, height: 34)))
        view.image = UIImage(named: "error_exclamation",
                             in: Bundle.kinDesign(),
                             compatibleWith: nil)
        return view
    }()

    lazy var circleView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = UIImage(named: "error_circle",
                             in: Bundle.kinDesign(),
                             compatibleWith: nil)
        return view
    }()

    lazy var infoLabel: SecondaryLabel = {
        let label = SecondaryLabel(frame: .zero)
        label.text = self.errorMessage ?? "Oops! For some reason the transaction did not go through."
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    lazy var closeButton: NegativeActionButton = {
        let button = NegativeActionButton(frame: .zero)
        button.setTitle("Close", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        return button
    }()

    var errorMessage: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(exclamationView)
        addSubview(circleView)
        addSubview(infoLabel)
        addSubview(closeButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        circleView.frame.size = CGSize(width: 64, height: 64)
        circleView.center = center
        circleView.frame.origin.y = 79

        exclamationView.center = circleView.center

        infoLabel.frame.size.width = bounds.width - 55 * 2
        infoLabel.sizeToFit()
        infoLabel.center = center
        infoLabel.frame.origin.y = circleView.frame.maxY + 21

        closeButton.center = center
        closeButton.frame.origin.y = infoLabel.frame.maxY + 20
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - StandardConstants.sidePadding * 2,
                      height: 339)
    }

    @objc func closeTapped(_ sender: UIControl) {
        delegate?.paymentConfirmationCloseTapped()
    }
}
