//
//  QRViewController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 18/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit
import MessageUI

protocol QRViewControllerDelegate: NSObjectProtocol {
    func qrViewControllerDidComplete(_ viewController: QRViewController)
}

class QRViewController: KinViewController {
    weak var delegate: QRViewControllerDelegate!

    let qrImage: UIImage?
    fileprivate var mailViewController: MFMailComposeViewController?

    // MARK: View

    private var imageView: UIImageView {
        return _view.imageView
    }

    private var confirmControl: UIControl {
        return _view.confirmControl
    }

    private var doneButton: RoundButton {
        return _view.doneButton
    }

    var _view: QRView {
        return view as! QRView
    }

    var classForView: QRView.Type {
        return QRView.self
    }

    override func loadView() {
        view = classForView.self.init(frame: .zero)
    }

    // MARK: Lifecycle

    init(qrString: String) {
        self.qrImage = QR.encode(string: qrString)

        super.init(nibName: nil, bundle: nil)

        title = "backup.title".localized()
        navigationItem.backBarButtonItem = UIBarButtonItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = qrImage

        confirmControl.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)

        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)

        syncState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func applicationDidTakeScreenshot() {
        if isViewLoaded && view.window != nil {
            state = .saved
        }
    }

    // MARK: State

    private var state: State = .default {
        didSet {
            syncState()
        }
    }

    private func syncState() {
        switch state {
        case .default:
            confirmControl.isHidden = true
            doneButton.isSelected = false
            doneButton.isEnabled = true
        case .saved:
            confirmControl.isHidden = false
            doneButton.isSelected = true
            doneButton.isEnabled = false
        }
    }

    // MARK: Actions

    @objc
    private func doneAction() {
        if state == .saved {
            delegate.qrViewControllerDidComplete(self)
        }
        else {
            presentMailViewController()
        }
    }
    
    @objc
    private func confirmAction() {
        doneButton.isEnabled = _view.isConfirmed
    }
}

// MARK: - State

extension QRViewController {
    fileprivate enum State {
        case `default`
        case saved
    }
}

// MARK: - Mail

extension QRViewController {
    fileprivate enum MailError: Error {
        case noClient
        case critical
    }
}

extension QRViewController.MailError {
    var title: String {
        switch self {
        case .noClient:
            return "qr.alert_no_client.title".localized()
        case .critical:
            return "generic.alert_error.title".localized()
        }
    }

    var message: String {
        switch self {
        case .noClient:
            return "qr.alert_no_client.message".localized()
        case .critical:
            return "generic.alert_error.message".localized()
        }
    }
}

extension QRViewController {
    fileprivate func presentMailViewController() {
        guard MFMailComposeViewController.canSendMail() else {
            presentMailErrorAlertController(.noClient)
            return
        }
        
        guard let data = qrImage?.pngData() else {
            presentMailErrorAlertController(.critical)
            return
        }
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("qr.email.subject".localized())
        mailViewController.addAttachmentData(data, mimeType: "image/png", fileName: "qr.png")
        present(mailViewController, animated: true)
        self.mailViewController = mailViewController
    }
    
    private func presentMailErrorAlertController(_ error: MailError) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "generic.ok".localized(), style: .cancel))
        present(alertController, animated: true)
    }
}

extension QRViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true) { [weak self] in
            self?.state = .saved
        }
        mailViewController = nil
    }
}
