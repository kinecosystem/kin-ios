//
// Observables.swift
// KinUtil
//
// Created by Kik Interactive Inc.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import Dispatch

public final class StatefulObserver<Value>: Observable<Value> {
    public private(set) var value: Value?

    @discardableResult
    override public func on(queue: DispatchQueue? = nil,
                            next: @escaping (Value) -> Void) -> Observable<Value> {
        let wasZero = buffer.isEmpty

        super.on(queue: queue, next: next)

        if let value = value, wasZero {
            super.next(value)
        }

        return self
    }

    override public func next(_ value: Value) {
        self.value = value

        super.next(value)
    }
}
