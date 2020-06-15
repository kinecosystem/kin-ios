//
//  KinBackupRestoreError.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 24/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public enum KinBackupRestoreError: Error {
    case cantOpenImagePicker
    case internalInconsistency
}

extension KinBackupRestoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cantOpenImagePicker:
            return "Can't open the image picker."
        case .internalInconsistency:
            return "Internal inconsistency."
        }
    }
}
