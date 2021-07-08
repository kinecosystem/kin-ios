//
//  Password.swift
//  KinBackupRestoreModule
//
//  Created by Corey Werner on 26/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class Password {
    static let pattern: String = {
        let digit = "(?=.*\\d)"
        let upper = "(?=.*[A-Z])"
        let lower = "(?=.*[a-z])"
        let special = "(?=.*[!@#$%^&*()_+{}\\[\\]])"
        let min = 9
        return "^\(digit)\(upper)\(lower)\(special)(.{\(min),})$"
    }()

    static func matches(_ string: String) throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        return !results.isEmpty
    }
}
