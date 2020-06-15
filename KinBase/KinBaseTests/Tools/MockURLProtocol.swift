//
//  MockURLProtocol.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit

class MockURLProtocol: URLProtocol {
    enum Errors: String, Error {
        case notFound = "Not Found"
    }

    static var stubUrlData = [URL: Data]()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url,
            let data = MockURLProtocol.stubUrlData[url] {
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        client?.urlProtocol(self, didFailWithError: Errors.notFound)
    }

    override func stopLoading() { }
}
