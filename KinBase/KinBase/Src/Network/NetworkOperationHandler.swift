//
//  NetworkOperationHandler.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import Promises

public enum NetworkOperationErrors: Int, Error {
    case timeout
    case internalError
}

public struct PromisedCallback<T> {
    public let onSuccess: (T) -> Void
    public let onError: ((Error) -> Void)?
}

public class NetworkOperation<ResponseType> {
    public enum State {
        case `init`
        case queued
        case scheduled(dispatchTime: DispatchTime, workItem: DispatchWorkItem)
        case running
        case completed
        case errored(_: Error)
    }

    public var state: State = .`init` {
        willSet {
            if case let .scheduled(_, item) = state {
                item.cancel()
            }
        }
    }

    public let id: String
    public let timeout: TimeInterval
    public let backoffStrategy: BackoffStrategy
    public let work: (PromisedCallback<ResponseType>) -> Void
    public let completion: PromisedCallback<ResponseType>
    public var expiryItem: DispatchWorkItem? = nil
    public var shouldRetryError: ((Error) -> Bool)? = nil
    public weak var queue: DispatchQueue? = nil

    ///
    /// - Parameters:
    ///   - id: a unique identifier for the operation
    ///   - timeout: task will timeout in milliseconds, if not completed within the timeout period, with [NetworkOperationsHandlerException.OperationTimeoutException]
    ///   - backoffStrategy: the strategy used to retry a task that fails
    ///   - work: the work performed by the operation
    ///   - completion: will be called when the operation has completed, successfully or with an error (including if it timed out, or failed fatally)
    public init(id: String = String(Date().timeIntervalSince1970),
                timeout: TimeInterval = 50.0,
                backoffStrategy: BackoffStrategy = .exponential(),
                work: @escaping (PromisedCallback<ResponseType>) -> Void,
                completion: PromisedCallback<ResponseType>) {
        self.id = id
        self.timeout = timeout
        self.backoffStrategy = backoffStrategy
        self.work = work
        self.completion = completion
    }

    public convenience init(onSuccess: @escaping (ResponseType) -> Void,
                            onError: ((Error) -> Void)? = nil,
                            work: @escaping (PromisedCallback<ResponseType>) -> Void) {
        let completion = PromisedCallback<ResponseType>(onSuccess: onSuccess,
                                                        onError: onError)
        self.init(work: work,
                  completion: completion)
    }
}

/// Handles queuing, retry, and backoff strategy of network operations.
public class NetworkOperationHandler {
    private var operations = [String: Any]()
    private let operationsQueue = DispatchQueue(label: "KinBase.NetworkOperations.operations")
    private let queue: DispatchQueue
    private let shouldRetryError: ((Error) -> Bool)?

    ///
    /// - Parameters:
    ///   - queue: the `DispatchQueue` to run network operations on
    ///   - shouldRetryError: a closure to determine what kind of error should be retried
    public init(queue: DispatchQueue = .init(label: "KinBase.NetworkOperations"),
                shouldRetryError: ((Error) -> Bool)? = nil) {
        self.queue = queue
        self.shouldRetryError = shouldRetryError
    }

    public func queueOperation<ResponseType>(op: NetworkOperation<ResponseType>) -> NetworkOperation<ResponseType> {
        let operation: NetworkOperation<ResponseType> = op
        operation.queue = queue
        operation.state = .queued
        operation.shouldRetryError = shouldRetryError

        let expiryItem = DispatchWorkItem { [weak self] in
            self?.expireOperation(operation)
        }

        queue.asyncAfter(deadline: .now() + operation.timeout, execute: expiryItem)
        operation.expiryItem = expiryItem

        operationsQueue.sync {
            operations[operation.id] = operation
        }

        scheduleOperation(operation)

        return operation
    }

    private func expireOperation<ResponseType>(_ op: NetworkOperation<ResponseType>) {
        let error = NetworkOperationErrors.timeout
        op.state = .errored(error)
        op.completion.onError?(error)
        cleanup(op)
    }

    private func scheduleOperation<ResponseType>(_ op: NetworkOperation<ResponseType>,
                                                 prevError: Error? = nil) {
        do {
            let delay = try op.backoffStrategy.nextDelay()
            let dispatchTime: DispatchTime = .now() + delay

            let work = DispatchWorkItem { [weak self] in
                self?.runOperation(op)
            }

            queue.asyncAfter(deadline: dispatchTime, execute: work)
            op.state = .scheduled(dispatchTime: dispatchTime, workItem: work)

        } catch {
            fatalError(prevError ?? error, for: op)
        }
    }

    private func runOperation<ResponseType>(_ op: NetworkOperation<ResponseType>) {
        op.state = .running

        let onSuccess = { [weak self] (response: ResponseType) -> Void in
            self?.completeOperation(op)
            op.completion.onSuccess(response)
        }

        let onError = { [weak self] (error: Error) -> Void in
            self?.handleError(error, for: op)
        }

        let callback = PromisedCallback<ResponseType>(onSuccess: onSuccess,
                                                      onError: onError)

        op.work(callback)
    }

    private func completeOperation<ResponseType>(_ op: NetworkOperation<ResponseType>) {
        op.state = .completed
        cleanup(op)
    }

    private func handleError<ResponseType>(_ error: Error, for op: NetworkOperation<ResponseType>) {
        if op.shouldRetryError?(error) == true {
            op.state = .errored(error)
            scheduleOperation(op, prevError: error)
        } else {
            fatalError(error, for: op)
        }
    }

    private func fatalError<ResponseType>(_ error: Error, for op: NetworkOperation<ResponseType>) {
        op.state = .errored(error)
        op.completion.onError?(error)
    }

    private func cleanup<ResponseType>(_ op: NetworkOperation<ResponseType>) {
        op.expiryItem?.cancel()
        operationsQueue.sync {
            _ = operations.removeValue(forKey: op.id)
        }
    }
}

public extension NetworkOperationHandler {
    func queueWork<T>(_ work: @escaping (PromisedCallback<T>) -> Void) -> Promise<T> {
        let promise = Promise<T>.init { (resolve, reject) in
            let operation = NetworkOperation<T>(onSuccess: resolve,
                                                onError: reject,
                                                work: work)
            _ = self.queueOperation(op: operation)
        }

        return promise
    }
    
    func queueWorkWithPromise<T>(_ workBuilder: @escaping () -> Promise<T>) -> Promise<T> {
        let promise = Promise<T>.init { (resolve, reject) in
            let operation = NetworkOperation<T>(onSuccess: resolve, onError: reject) { (callback) in
                workBuilder().then { it in
                    callback.onSuccess(it)
                }.catch { it in
                    guard let onError = callback.onError else {
                        return
                    }
                    onError(it)
                }
            }
            _ = self.queueOperation(op: operation)
        }
        return promise
    }
}
