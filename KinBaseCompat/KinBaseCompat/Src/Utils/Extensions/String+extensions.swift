//
//  String+extensions.swift
//  KinUtil
//
//  Created by Kik Interactive Inc.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

public extension String {
    var urlEncoded: String? {
        var allowedQueryParamAndKey = NSMutableCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")

        return self.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey)
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    func split(on delimiter: Character) -> (Array<String>, String) {
        guard !isEmpty else {
            return ([], "")
        }

        let a = split(separator: delimiter)
        if suffix(1) == String(delimiter) {
            return (a.map { String($0) }, "")
        }
        else {
            let r = String(a.last!)
            return (a.dropLast().map { String($0) }, r)
        }
    }
}
