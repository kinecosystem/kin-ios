//
//  ListSubject.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public class ListSubject<Element>: ListObservable<Element>, ListObserverType {
    public typealias Element = Element

    private var invalidation: (() -> Void)?
    private var fetchNextPage: (() -> Void)?
    private var fetchPreviousPage: (() -> Void)?

    private var listeners = [ValueListener]()
    private var onDisposed = [() -> Void]()

    private let queue = DispatchQueue(label: "KinBase.ListSubject")

    private var currentValue: [Element]?

    public override func subscribe(_ listener: @escaping ValueListener) -> Self {
        queue.sync {
            listeners.append(listener)

            if let value = currentValue {
                listener(value)
            }
        }

        return self
    }

    public func onNext(_ newValue: [Element]) {
        listeners.forEach { $0(newValue) }
        currentValue = newValue
    }

    @discardableResult
    public func setFetchNextPage(_ fetchNextPage: @escaping () -> Void) -> Self {
        self.fetchNextPage = fetchNextPage
        return self
    }

    public override func requestNextPage() -> Self {
        fetchNextPage?()
        return self
    }

    @discardableResult
    public func setFetchPreviousPage(_ fetchPreviousPage: @escaping () -> Void) -> Self {
        self.fetchPreviousPage = fetchPreviousPage
        return self
    }

    public override func requestPreviousPage() -> Self {
        fetchPreviousPage?()
        return self
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
