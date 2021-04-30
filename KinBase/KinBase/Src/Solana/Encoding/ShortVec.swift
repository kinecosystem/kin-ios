//
//  ShortVec.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

enum ShortVec {
    static func encodeLength(_ length: UInt16) -> Data {
        var data = Data()
        
        var remaining = Int(length)
        while true {
            var byte = UInt8(remaining & 0x7f)
            remaining >>= 7
            
            if remaining == 0 {
                data.append(byte)
                return Data(data)
            }
            
            byte |= 0x80
            data.append(byte)
        }
        
        return data
    }
    
    static func encode(_ components: [Data]) -> Data {
        var container = encodeLength(UInt16(components.count))
        components.forEach {
            container.append($0)
        }
        return container
    }
    
    static func encode(_ data: Data) -> Data {
        var container = encodeLength(UInt16(data.count))
        container.append(data)
        return container
    }
    
    static func decodeLength(_ data: Data) -> (length: Int, remaining: Data) {
        var length = 0
        var size = 0
        
        guard data.count > 0 else {
            return (length, Data())
        }
        
        let bytes = data.bytes
        while size < data.count {
            let byte = Int(bytes[size])
            length |= (byte & 0x7f) << (size * 7)
            size += 1
            if (byte & 0x80) == 0 {
                break
            }
        }
        
        guard data.count > size else {
            return (length, Data())
        }
        
        return (
            length: length,
            remaining: data.tail(from: size)
        )
    }
}
