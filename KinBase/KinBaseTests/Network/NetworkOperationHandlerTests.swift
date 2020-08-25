//
//  NetworkOperationHandlerTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import XCTest
import Promises
@testable import KinBase

class NetworkOperationHandlerTests: XCTestCase {

    var sut: NetworkOperationHandler!

    override func setUp() {
        sut = NetworkOperationHandler(shouldRetryError: { _ in
            return true
        })
    }

    func testNoRetryComplete() {
        var results = [Int]()
        let onSuccess = { results.append($0) }
        let expect = expectation(description: "completions")
        expect.expectedFulfillmentCount = 3

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(1)
                                    expect.fulfill()
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(2)
                                    expect.fulfill()
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(3)
                                    expect.fulfill()
            })
        )

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [1, 2, 3])
    }

    func testRetry() {
        let expect = expectation(description: "completions")
        expect.expectedFulfillmentCount = 3
        var results = [Int]()
        let onSuccess = { (value: Int) -> Void in
            results.append(value)
            expect.fulfill()
        }

        var i = 0
        _ = sut.queueOperation(op:
            NetworkOperation<Int>(backoffStrategy: testBackoffStrategy(),
                                  work: { callback in
                                    i += 1
                                    if i % 3 != 0 {
                                        callback.onError?(KinService.Errors.unknown)
                                    } else {
                                        callback.onSuccess(1)
                                    }
                                  },
                                  completion: PromisedCallback<Int>(onSuccess: onSuccess,
                                                                    onError: nil))
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(2)
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(3)
            })
        )

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [2, 3, 1])
    }

    func testRetryNever() {
        let expect = expectation(description: "completions")
        expect.expectedFulfillmentCount = 3
        var results = [Int]()
        let onSuccess = { (value: Int) -> Void in
            results.append(value)
            expect.fulfill()
        }

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(backoffStrategy: .never(),
                                  work: { callback in
                                    callback.onError?(KinService.Errors.unknown)
                                    expect.fulfill()
                                  },
                                  completion: PromisedCallback<Int>(onSuccess: onSuccess,
                                                                    onError: nil))
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(2)
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(3)
            })
        )

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [2, 3])
    }

    func testRetryFixed() {
        let expect = expectation(description: "completions")
        expect.expectedFulfillmentCount = 3
        var results = [Int]()
        let onSuccess = { (value: Int) -> Void in
            results.append(value)
            expect.fulfill()
        }

        var i = 0
        _ = sut.queueOperation(op:
            NetworkOperation<Int>(backoffStrategy: .fixed(after: 0.001),
                                  work: { callback in
                                    i += 1
                                    if i % 3 != 0 {
                                        callback.onError?(KinService.Errors.unknown)
                                    } else {
                                        callback.onSuccess(1)
                                    }
                                  },
                                  completion: PromisedCallback<Int>(onSuccess: onSuccess,
                                                                    onError: nil))
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(2)
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(3)
            })
        )

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [2, 3, 1])
    }

    func testRetryCustom() {
        let expect = expectation(description: "completions")
        expect.expectedFulfillmentCount = 3
        var results = [Int]()
        let onSuccess = { (value: Int) -> Void in
            results.append(value)
            expect.fulfill()
        }

        var i = 0
        _ = sut.queueOperation(op:
            NetworkOperation<Int>(backoffStrategy: .custom(afterClosure: { _ in return 0.01 }),
                                  work: { callback in
                                    i += 1
                                    if i % 3 != 0 {
                                        callback.onError?(KinService.Errors.unknown)
                                    } else {
                                        callback.onSuccess(1)
                                    }
                                  },
                                  completion: PromisedCallback<Int>(onSuccess: onSuccess,
                                                                    onError: nil))
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(2)
            })
        )

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(onSuccess: onSuccess,
                                  work: { callback in
                                    callback.onSuccess(3)
            })
        )

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [2, 3, 1])
    }

    func testTimeout() {
        let expect = expectation(description: "completions")
        var results = [Int]()
        let onSuccess = { (value: Int) -> Void in
            results.append(value)
        }

        let onError = { (error: Error) -> Void in
            XCTAssertEqual(error as! NetworkOperationErrors, NetworkOperationErrors.timeout)
            expect.fulfill()
        }

        _ = sut.queueOperation(op:
            NetworkOperation<Int>(timeout: 0.1,
                                  backoffStrategy: .custom(afterClosure: { _ in return 0.01 }),
                                  work: {_ in },
                                  completion: PromisedCallback<Int>(onSuccess: onSuccess,
                                                                    onError: onError))
        )

        waitForExpectations(timeout: 1)
    }

    func testQueueWork() {
        var results = [Int]()
        let expect = expectation(description: "completions")

        sut.queueWork { (callback: PromisedCallback<Int>) -> Void in
            callback.onSuccess(1)
        }
        .then { value in
            results.append(value)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [1])
    }

    private func testBackoffStrategy() -> BackoffStrategy {
        return .exponential(initial: 0.01, multiplier: 2, jitter: 0.5, maxWaitTime: 5, maxAttempts: 3)
    }
}
