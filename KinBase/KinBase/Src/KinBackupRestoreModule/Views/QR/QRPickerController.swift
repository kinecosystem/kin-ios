//
//  QRPickerController.swift
//  KinEcosystem
//
//  Created by Corey Werner on 25/10/2018.
//  Copyright © 2018 Kik Interactive. All rights reserved.
//

import UIKit

protocol QRPickerControllerDelegate: NSObjectProtocol {
    func qrPickerControllerDidComplete(_ controller: QRPickerController, with qrString: String?)
}

class QRPickerController: NSObject {
    weak var delegate: QRPickerControllerDelegate?
    
    let imagePickerController = UIImagePickerController()
    
    static var canOpenImagePicker: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    override init() {
        super.init()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
    }
}

extension QRPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.qrPickerControllerDidComplete(self, with: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.global().async {
                if let qrString = QR.decode(image: image) {
                    DispatchQueue.main.async {
                        self.delegate?.qrPickerControllerDidComplete(self, with: qrString)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.presentImageErrorAlertController()
                    }
                }
            }
        }
        else {
            self.presentImageErrorAlertController()
        }
    }
    
    func presentImageErrorAlertController() {
        let title = "qr_picker.alert_error.title".localized()
        let message = "qr_picker.alert_error.message".localized()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "generic.ok".localized(), style: .cancel))
        self.imagePickerController.present(alertController, animated: true)
    }
}
