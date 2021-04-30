//
//  Extensions.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import XCTest

func XCTAssertError<T>(_ error: Error, is type: T) where T: Error, T: Equatable {
    if let typedError = error as? T {
        XCTAssertEqual(typedError, type)
    } else {
        XCTFail()
    }
}
