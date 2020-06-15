//
//  Helper.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

func TODO(file: String = #file, function: String = #function, line: Int = #line) -> Never {
    let className = file.components(separatedBy: "/").last
    fatalError(" ❌ TODO ENCOUNTERED ❌ File: \(className ?? ""), Function: \(function), Line: \(line)")
}
