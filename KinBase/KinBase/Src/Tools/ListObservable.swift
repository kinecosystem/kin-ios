//
//  ListObservable.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol ListObserverType {
    associatedtype Element

    func onNext(_ newValue: [Element])
}

public class ListObservable<Element>: Disposable {
    public typealias ValueListener = ([Element]) -> Void

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

    public func requestNextPage() -> Self {
        fatalError("Missing Implementation")
    }

    public func requestPreviousPage() -> Self {
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
