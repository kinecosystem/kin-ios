//
//  UserAgentInterceptor.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

struct SDKConfig {
    static let sharedInstance = SDKConfig()
    private init() {}
    
    let platform = "iOS"
    let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    //eg. Darwin/16.3.0
    func DarwinVersion() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    //eg. CFNetwork/808.3
    func CFNetworkVersion() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }

    //eg. iOS/10_1
    func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    //eg. iPhone5,2
    func deviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func systemUserAgent() -> String{
        "\(deviceVersion()) (\(deviceName())) \(CFNetworkVersion()) \(DarwinVersion())"
    }
}

private struct UserAgent {
    let systemUserAgent: String = SDKConfig.sharedInstance.systemUserAgent()
    let platform: String = SDKConfig.sharedInstance.platform
    let versionString: String = SDKConfig.sharedInstance.versionString
    let cid: String
    
    func toString() -> String {
        return "\(systemUserAgent) KinSDK/\(versionString) (\(platform); CID/\(cid)"
    }
}

public class UserAgentContext: NSObject, GRPCInterceptorFactory {
    private let storage: KinStorageType

    public init(storage: KinStorageType) {
        self.storage = storage
        super.init()
    }

    public func createInterceptor(with interceptorManager: GRPCInterceptorManager) -> GRPCInterceptor {
        return UserAgentInterceptor(interceptorManager: interceptorManager,
                                      storage: storage)
    }
}

public class UserAgentInterceptor: GRPCInterceptor {

    private let manager: GRPCInterceptorManager
    private let storage: KinStorageType
    
    private lazy var userAgentString: String = {
        let cid = storage.getOrCreateCID()
        return UserAgent(cid: cid).toString()
    }()

    init(interceptorManager: GRPCInterceptorManager,
         storage: KinStorageType) {
        self.manager = interceptorManager
        self.storage = storage
        super.init(interceptorManager: interceptorManager,
                   dispatchQueue: .promises)!
    }

    public override func start(with requestOptions: GRPCRequestOptions, callOptions: GRPCCallOptions) {
        let newCallOptions = callOptions.mutableCopy() as! GRPCMutableCallOptions
        
        let headersCopy = NSMutableDictionary.init(dictionary: ["kin-user-agent": userAgentString])
               
        if (newCallOptions.initialMetadata != nil) {
            headersCopy.addEntries(from: newCallOptions.initialMetadata!)
        }
       
        newCallOptions.initialMetadata = headersCopy as Dictionary
        
        manager.startNextInterceptor(withRequest: requestOptions,
                                     callOptions: newCallOptions)
    }
}
