//
//  KinPresentationController.swift
//  KinUX
//
//  Created by Kik Engineering on 2019-11-18.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import UIKit

public enum SheetTransitionCover: RawRepresentable {
    public typealias RawValue = CGFloat

    case custom(height: CGFloat)
    case half
    case most
    case all

    public var rawValue: CGFloat {
        switch self {
        case .custom(let height):
            return height
        case .half:
            return 0.5
        case .most:
            return 0.75
        case .all:
            return 0.9
        }
    }

    public init?(rawValue: CGFloat) {
        if rawValue == 0.5 {
            self = .half
        } else if rawValue == 0.75 {
            self = .most
        } else if rawValue == 0.9 {
            self = .all
        } else {
            self = .custom(height: rawValue)
        }
    }
}

public class KinPresentationController: UIPresentationController {
    private var calculatedFrameOfPresentedViewInContainerView = CGRect.zero
    private var shouldSetFrameWhenAccessingPresentedView = false

    override public var presentedView: UIView? {
        if shouldSetFrameWhenAccessingPresentedView {
            super.presentedView?.frame = calculatedFrameOfPresentedViewInContainerView
        }

        return super.presentedView
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        shouldSetFrameWhenAccessingPresentedView = completed
    }

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        shouldSetFrameWhenAccessingPresentedView = false
    }

    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        calculatedFrameOfPresentedViewInContainerView = frameOfPresentedViewInContainerView
    }
}

// TODO: clean up
public class SheetPresentationController: KinPresentationController {

    var cover: SheetTransitionCover = .half

    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let frame = containerView.bounds
        var frameHeight = frame.height * cover.rawValue
        if case let .custom(height) = cover {
            frameHeight = height
        }
        return CGRect(x: 0.0, y: frame.height - frameHeight, width: frame.width, height: frameHeight)
    }

    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard let pView = presentedView else { return }
        pView.frame = frameOfPresentedViewInContainerView
        let viewMask = CAShapeLayer()
        viewMask.fillColor = UIColor.green.cgColor
        viewMask.frame = pView.bounds
        viewMask.path = UIBezierPath(roundedRect: pView.bounds,
                                     byRoundingCorners: [.topLeft, .topRight],
                                     cornerRadii: CGSize(width: 10.4, height: 10.4)).cgPath
        pView.layer.mask = viewMask
    }

    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.backgroundColor = .clear
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                }, completion: nil)
        }
    }

    override public func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.containerView?.backgroundColor = .clear
                }, completion: nil)
        }
    }
}

// TODO: clean up
public class SheetTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, CAAnimationDelegate {

    var isPresenting = true
    var transitionDuration: TimeInterval = 0.6
    var cover: SheetTransitionCover

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.cover = cover
        return presentationController
    }

    public init(covering: SheetTransitionCover = .half) {
        self.cover = covering
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let blurEffectView: UIVisualEffectView

        let frame = transitionContext.containerView.bounds

        var frameHeight = frame.height * cover.rawValue
        if case let .custom(height) = cover {
            frameHeight = height
        }

        let inFrame = CGRect(x: 0.0, y: frame.height - frameHeight, width: frame.width, height: frameHeight)
        let outFrame = CGRect(x: 0.0, y: frame.height, width: frame.width, height: frameHeight)
        let spendController = transitionContext.viewController(forKey: isPresenting ? .to : .from)!
        let presentor = transitionContext.viewController(forKey: isPresenting ? .from : .to)!
        spendController.view.frame = isPresenting ? outFrame : inFrame


        if isPresenting {
            let blurEffect = UIBlurEffect(style: .dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.tag = 26163
        } else {
            blurEffectView = presentor.view.viewWithTag(26163)! as! UIVisualEffectView
        }
        blurEffectView.frame = frame
        blurEffectView.alpha = isPresenting ? 0.0 : 0.8
        if isPresenting {
            presentor.view.addSubview(blurEffectView)
            transitionContext.containerView.addSubview(spendController.view)
        }
        let p = isPresenting
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 3.9, options: [], animations: {
            blurEffectView.alpha = p ? 0.8 : 0.0
            spendController.view.frame = p ? inFrame : outFrame
        }, completion: { finished in
            if p == false {
                blurEffectView.removeFromSuperview()
                spendController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}
