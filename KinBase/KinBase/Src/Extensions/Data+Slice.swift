//
//  Data+Slice.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-05.
//

import Foundation

extension Data {
    mutating func consume(_ length: Int) -> Data {
        if length > 0 {
            let data = Data(prefix(length))
            self = Data(suffix(from: Swift.min(length, count)))
            return data
        }
        return Data()
    }
    
    func tail(from index: Int) -> Data {
        if index >= 0 && index < count {
            return Data(suffix(from: index))
        }
        return Data()
    }
    
    func chunk<T>(size: Int, count: Int, block: (Data) -> T) -> [T]? {
        let requestSize = size * count
        
        guard requestSize <= self.count else {
            return nil
        }
        
        var container: [T] = []
        for i in 0..<count {
            let index = i * size
            let slice = subdata(in: index..<index + size)
            container.append(block(slice))
        }
        return container
    }
}
