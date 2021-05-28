//
//  Byte+Data.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-07.
//

import Foundation

extension Array where Element == Byte {
    
    static func zeroed(with length: Int) -> [Element] {
        [Element](repeating: 0, count: length)
    }
    
    var data: Data {
        Data(self)
    }
}

extension Data {
    var bytes: [Byte] {
        Array(self)
    }
}
