//
//  Cache.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public class Cache<KEY: Hashable>{
    
    public enum Errors: Int, Error {
        case internalError
    }
    
    private var storage = Dictionary<KEY, (rawValue: Any, timeout:UInt64)>()
    private let defaultTimeout: UInt64 = 5000
    
    public func resolve<VALUE>(
        key: KEY,
        timeoutOverride: UInt64 = 0,
        fault: @escaping (KEY) -> Promise<VALUE>
    ) -> Promise<VALUE> {
        return Promise<VALUE>.init { [weak self] (resolve, reject) in
            guard let self = self else {
                reject(Errors.internalError)
                return
            }
            
            let tuple = self.storage[key]
            var value: Any? = nil
            if (tuple != nil) {
                let now = UInt64(Date().timeIntervalSince1970)
                let timeStored = tuple!.timeout
                var timeToExpiry: UInt64
                if (timeoutOverride > 0) {
                    timeToExpiry = timeoutOverride
                } else {
                    timeToExpiry = self.defaultTimeout
                }
                let expiryTime = timeStored + timeToExpiry
                if (expiryTime > now) {
                    value = tuple!.rawValue
                } else {
                    value = nil
                }
            }


            if (value != nil) {
                resolve(value as! VALUE)
            } else {
                fault(key).then { it in
                    self.storage[key] = (it, UInt64(Date().timeIntervalSince1970))
                    resolve(it)
                }.catch { it in
                    reject(it)
                }
            }
        }
    }

    public func warm<VALUE>(key: KEY, fault: @escaping (KEY) -> Promise<VALUE>) -> Promise<VALUE> {
        return Promise<VALUE>.init { [weak self] (resolve, reject) in
            fault(key).then { [weak self] it in
                guard let self = self else {
                    reject(Errors.internalError)
                    return
                }
            
                self.storage[key] = (it, UInt64(Date().timeIntervalSince1970))
                resolve(it)
            }
        }
    }
    
    public func invalidate(key: KEY) {
        storage.removeValue(forKey: key)
    }
}
