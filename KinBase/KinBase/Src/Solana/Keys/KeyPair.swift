//
//  KeyPair.swift
//  KinSDK
//
//  Created by Dima Bart on 2021-05-01.
//

import Foundation

public struct KeyPair: Equatable {
    
    public let publicKey: PublicKey
    public let privateKey: PrivateKey
    public let seed: Seed?
    
    // MARK: - Init -
    
    public static func generate() -> KeyPair? {
        guard let seed = Seed.generate() else {
            return nil
        }
        
        return KeyPair(seed: seed)
    }
    
    public init(publicKey: PublicKey, privateKey: PrivateKey) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.seed = nil
    }
    
    public init(seed: Seed) {
        var publicBytes  = [Byte].zeroed(with: Key32.length)
        var privateBytes = [Byte].zeroed(with: PrivateKey.length)
        
        privateBytes.withUnsafeMutableBufferPointer { `private` in
            publicBytes.withUnsafeMutableBufferPointer { `public` in
                seed.bytes.withUnsafeBufferPointer { seed in
                    ed25519_create_keypair(
                        `public`.baseAddress,
                        `private`.baseAddress,
                        seed.baseAddress
                    )
                }
            }
        }
        
        self.seed = seed
        self.publicKey = PublicKey(publicBytes)!
        self.privateKey = PrivateKey(privateBytes)!
    }
    
    // MARK: - Signing -
    
    public func sign(_ data: Data) -> Data {
        sign(data.bytes).data
    }
    
    public func sign(_ bytes: [Byte]) -> [Byte] {
        var signature = [Byte].zeroed(with: Signature.length)
        
        signature.withUnsafeMutableBufferPointer { signature in
            privateKey.bytes.withUnsafeBufferPointer { `private` in
                publicKey.bytes.withUnsafeBufferPointer { `public` in
                    bytes.withUnsafeBufferPointer { msg in
                        ed25519_sign(
                            signature.baseAddress,
                            msg.baseAddress,
                            bytes.count,
                            `public`.baseAddress,
                            `private`.baseAddress
                        )
                    }
                }
            }
        }
        
        return signature
    }
    
    public func verify(signature: Signature, data: Data) -> Bool {
        publicKey.verify(signature: signature, data: data)
    }

    public func verify(signature: Signature, bytes: [Byte]) -> Bool {
        publicKey.verify(signature: signature, bytes: bytes)
    }
}

// MARK: - PublicKey -

extension PublicKey {
    
    public func isOnCurve() -> Bool {
        bytes.withUnsafeBufferPointer {
            ed25519_on_curve($0.baseAddress) == 1
        }
    }
    
    public func verify(signature: Signature, data: Data) -> Bool {
        verify(signature: signature, bytes: data.bytes)
    }
    
    public func verify(signature: Signature, bytes: [Byte]) -> Bool {
        signature.bytes.withUnsafeBufferPointer { signature in
            bytes.withUnsafeBufferPointer { message in
                self.bytes.withUnsafeBufferPointer { `public` in
                    ed25519_verify(
                        signature.baseAddress,
                        message.baseAddress,
                        message.count,
                        `public`.baseAddress
                    ) == 1
                }
            }
        }
    }
}

// MARK: - Seed -

extension Seed {
    
    public static func generate() -> Seed? {
        var bytes = [Byte].zeroed(with: Seed.length)
        let result = bytes.withUnsafeMutableBufferPointer {
            ed25519_create_seed($0.baseAddress)
        }
        
        guard result == 0 else {
            return nil
        }
        
        return Seed(bytes)
    }
}
