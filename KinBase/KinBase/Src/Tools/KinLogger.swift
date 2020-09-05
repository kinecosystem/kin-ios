//
//  KinLogger.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public protocol KinLogger {
    func debug(msg: String)
    func info(msg: String)
    func warning(msg: String)
    func error(msg: String, error: Error?)
}

public protocol KinLoggerFactory {
    var isLoggingEnabled: Bool { get set }

    func getLogger(name: String) -> KinLogger
}

protocol KinLoggerImplDelegate {
    var isLoggingEnabled: Bool { get }
}

public class Logger {
       
       private let tag: String
       
       init(tag: String) {
           self.tag = tag
       }
       
       func debug(msg: String) {
           NSLog("\(tag)::debug::\(msg)")
       }

       func info(msg: String) {
           NSLog("\(tag)::info::\(msg)")
       }
       
       func warning(msg: String) {
           NSLog("\(tag)::warning::\(msg)")
       }
       
       func error(msg: String) {
           NSLog("\(tag)::error::\(msg)")
       }
   }

public class KinLoggerImpl : KinLogger {
    
    private let log: Logger
    private let delegate: KinLoggerImplDelegate

    init(logger: Logger, delegate: KinLoggerImplDelegate) {
        self.log = logger
        self.delegate = delegate
    }

    public func debug(msg: String) {
        logCheck()?.debug(msg: msg)
    }

    public func info(msg: String) {
        logCheck()?.info(msg: msg)
    }

    public func warning(msg: String) {
        logCheck()?.warning(msg: msg)
    }

    public func error(msg: String, error: Error? = nil) {
        if (error != nil) {
            logCheck()?.error(msg: msg)
        } else {
            logCheck()?.error(msg:"\(msg)::\(String(describing: error))")
        }
    }

    private func logCheck() -> Logger? {
        if (delegate.isLoggingEnabled){
            return log
        }
        else {
            return nil
        }
    }
}

public class KinLoggerFactoryImpl : KinLoggerFactory, KinLoggerImplDelegate {
    
    public var isLoggingEnabled: Bool
    
    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }
    
    public func getLogger(name: String) -> KinLogger {
        return KinLoggerImpl(logger: Logger(tag: name), delegate: self)
    }
}
