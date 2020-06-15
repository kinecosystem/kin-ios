//
//  BackoffStrategy.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public class BackoffStrategy {
    public struct Constants {
        public static let defaultMaxAttempt: Int = 5
        public static let defaultMaxAttemptWaitTime: TimeInterval = 15
        static let infiniteRetries: Int = -1
    }

    public enum Errors: Error {
        case retriesExceeded
    }

    public enum StrategyType {
        case never
        case fixed(after: TimeInterval)
        case exponential(initial: Double, multiplier: Double, jitter: Double, maxWaitTime: TimeInterval)
        case custom(afterClosure: (Int) -> TimeInterval)
    }

    public private(set) var currentAttempt = 0
    public let maxAttempts: Int

    public let type: StrategyType

    init(type: StrategyType,
         maxAttempts: Int) {
        self.type = type
        self.maxAttempts = maxAttempts
    }

    public static func never() -> BackoffStrategy {
        return BackoffStrategy(type: .never,
                               maxAttempts: 1)
    }

    public static func fixed(after: TimeInterval,
                             maxAttempts: Int = Constants.defaultMaxAttempt) -> BackoffStrategy {
        return BackoffStrategy(type: .fixed(after: after),
                               maxAttempts: maxAttempts)
    }

    public static func exponential(initial: Double = 1.0,
                                   multiplier: Double = 2.0,
                                   jitter: Double = 0.5,
                                   maxWaitTime: TimeInterval = Constants.defaultMaxAttemptWaitTime,
                                   maxAttempts: Int = Constants.defaultMaxAttempt) -> BackoffStrategy {
        return BackoffStrategy(type: .exponential(initial: initial,
                                                  multiplier: multiplier,
                                                  jitter: jitter,
                                                  maxWaitTime: maxWaitTime),
                               maxAttempts: maxAttempts)
    }

    public static func custom(afterClosure: @escaping (Int) -> TimeInterval,
                              maxAttempts: Int = Constants.defaultMaxAttempt) -> BackoffStrategy {
        return BackoffStrategy(type: .custom(afterClosure: afterClosure),
                               maxAttempts: maxAttempts)
    }

    public func nextDelay() throws -> TimeInterval {
        let delay = try delayForAttempt(currentAttempt)
        currentAttempt += 1
        return delay
    }

    private func delayForAttempt(_ attempt: Int) throws -> TimeInterval {
        guard attempt < maxAttempts || maxAttempts == Constants.infiniteRetries else {
            throw Errors.retriesExceeded
        }

        if attempt <= 0 {
            return 0
        }

        switch type {
        case .never:
            throw Errors.retriesExceeded
        case .fixed(let after):
            return after
        case .exponential(let initial, let multiplier, let jitter, let maxWaitTime):
            let delay = initial * pow(multiplier, Double(attempt - 1))
            let jitterAmount = delay * jitter * Double.random(in: 0...1)
            return min(maxWaitTime, max(0, delay + jitterAmount))
        case .custom(let afterClosure):
            return afterClosure(attempt)
        }
    }
}
