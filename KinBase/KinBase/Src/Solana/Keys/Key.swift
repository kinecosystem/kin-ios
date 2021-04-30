//
//  Key.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-01.
//

import Foundation

public typealias Byte = UInt8

public protocol KeyType {
    
    static var length: Int { get }
    
    var bytes: [Byte] { get }
    
    init?(_ bytes: [Byte])
}

// MARK: - Data -

extension KeyType {
    
    public static var zero: Self {
        self.init([Byte].zeroed(with: Self.length))!
    }
    
    public init?(_ data: Data) {
        self.init(data.bytes)
    }
    
    var data: Data {
        bytes.data
    }
}

// MARK: - Base58 -

extension KeyType {
    
    public var base58: String {
        Base58.base58FromBytes(bytes)
    }
    
    public init?(base58: String) {
        self.init(Base58.bytesFromBase58(base58))
    }
}

// MARK: - Key32 -

public struct Key32: Equatable, KeyType {
    
    public static let length = 32
    
    public let bytes: [Byte]
    
    public init?(_ bytes: [Byte]) {
        guard bytes.count == Self.length else {
            return nil
        }

        self.bytes = bytes
    }
}

extension Key32: CustomStringConvertible {
    public var description: String {
        base58
    }
}

// MARK: - Key64 -

public struct Key64: Equatable, KeyType {
    
    public static let length = 64
    
    public let bytes: [Byte]

    public init?(_ bytes: [Byte]) {
        guard bytes.count == Self.length else {
            return nil
        }

        self.bytes = bytes
    }
}

extension Key64: CustomStringConvertible {
    public var description: String {
        base58
    }
}
