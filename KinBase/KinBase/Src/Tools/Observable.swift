//
//  Observer.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public protocol Disposable {
    func dispose()

    func doOnDisposed(_ onDisposed: @escaping () -> Void) -> Self

    @discardableResult
    func disposedBy(_ disposeBag: DisposeBag) -> Self
}

public protocol ObserverType {
    associatedtype Element

    func onNext(_ newValue: Element)
}

public class DisposeBag {
    private let queue = DispatchQueue(label: "KinBase.DisposeBag")
    private var disposables = [Disposable]()

    public init() {}

    public func add(_ disposable: Disposable) {
        queue.async {
            self.disposables.append(disposable)
        }
    }

    public func dispose() {
        queue.async {
            self.disposables.forEach { $0.dispose() }
        }
    }
}

public class Observable<Element>: Disposable {
    public typealias ValueListener = (Element) -> Void

    @discardableResult
    public func subscribe(_ listener: @escaping ValueListener) -> Self {
        fatalError("Missing Implementation")
    }

    public func dispose() {
        fatalError("Missing Implementation")
    }

    public func doOnDisposed(_ onDisposed: @escaping () -> Void) -> Self {
        fatalError("Missing Implementation")
    }

    public func invalidate() -> Self {
        fatalError("Missing Implementation")
    }

    @discardableResult
    public func disposedBy(_ disposeBag: DisposeBag) -> Self {
        disposeBag.add(self)
        return self
    }
}

public class ValueSubject<Element>: Observable<Element>, ObserverType {
    public typealias Element = Element

    private var invalidation: (() -> Void)?
    private var listeners = [ValueListener]()
    private var onDisposed = [() -> Void]()

    private let queue = DispatchQueue(label: "KinBase.ValueSubject")

    private var currentValue: Element?

    public override func subscribe(_ listener: @escaping ValueListener) -> Self {
        queue.sync {
            listeners.append(listener)

            if let value = currentValue {
                listener(value)
            }
        }

        return self
    }

    public func onNext(_ newValue: Element) {
        listeners.forEach { $0(newValue) }
        currentValue = newValue
    }

    @discardableResult
    public func setInvalidation(_ invalidation: @escaping () -> Void) -> Self {
        self.invalidation = invalidation
        return self
    }

    public override func invalidate() -> Self {
        invalidation?()
        return self
    }

    public override func dispose() {
        queue.sync {
            listeners.removeAll()
            onDisposed.forEach { $0() }
            onDisposed.removeAll()
        }
    }

    public override func doOnDisposed(_ onDisposed: @escaping () -> Void) -> Self {
        queue.sync {
            self.onDisposed.append(onDisposed)
        }

        return self
    }
}
