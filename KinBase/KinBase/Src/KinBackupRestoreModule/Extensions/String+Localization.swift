//
//  String+Localization.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 05/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

extension String {
    func localized(_ args: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, tableName: nil, bundle: .backupRestore, value: "", comment: ""), arguments: args)
    }
}
