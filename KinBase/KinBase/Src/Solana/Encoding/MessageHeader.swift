//
//  MessageHeader.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-03.
//

import Foundation

public struct MessageHeader: Equatable {
    
    static let length: Int = 3
    
    public let signatureCount: Int
    public let readOnlySignedCount: Int
    public let readOnlyCount: Int
    
    public init(signatureCount: Int, readOnlySignedCount: Int, readOnlyCount: Int) {
        self.signatureCount = signatureCount
        self.readOnlySignedCount = readOnlySignedCount
        self.readOnlyCount = readOnlyCount
    }
}

// MARK: - SolanaCodable -

extension MessageHeader: SolanaCodable {
    public init?(data: Data) {
        guard data.count == 3 else {
            return nil
        }
        
        let bytes = data.bytes
        
        self.signatureCount      = Int(bytes[0])
        self.readOnlySignedCount = Int(bytes[1])
        self.readOnlyCount       = Int(bytes[2])
    }
    
    public func encode() -> Data {
        [
            Byte(signatureCount),
            Byte(readOnlySignedCount),
            Byte(readOnlyCount),
        ].data
    }
}
