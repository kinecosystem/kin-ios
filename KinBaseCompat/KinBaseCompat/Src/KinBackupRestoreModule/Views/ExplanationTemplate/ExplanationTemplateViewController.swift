//
//  ExplanationTemplateViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 17/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

class ExplanationTemplateViewController: KinViewController {
    // MARK: View

    var contentView: UIStackView {
        return _view.contentView
    }

    var imageView: UIImageView {
        return _view.imageView
    }

    var titleLabel: UILabel {
        return _view.titleLabel
    }

    var descriptionLabel: UILabel {
        return _view.descriptionLabel
    }

    var doneButton: RoundButton {
        return _view.doneButton
    }

    var _view: ExplanationTemplateView {
        return view as! ExplanationTemplateView
    }

    var classForView: ExplanationTemplateView.Type {
        return ExplanationTemplateView.self
    }

    override func loadView() {
        view = classForView.self.init(frame: .zero)
    }

    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
