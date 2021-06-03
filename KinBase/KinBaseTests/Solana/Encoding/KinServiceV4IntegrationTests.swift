//
//  KinServiceTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation
import XCTest
import Promises
@testable import KinBase

class KinServiceV4IntegrationTests: XCTestCase {
    
//    let airdropAccount = PublicKey(base58: "DemXVWQ9DXYsGFpmjFXxki3PE1i3VoHQtqxXQFx38pmU")! // testnet
    let airdropAccount = PublicKey(base58: "Gd1wVb3ioFZgWGadq5sEoLPQnRNFcpcprNeazY3QsTRf")! // localnet

    var mockKinAccountApi: KinAccountApiV4!
    var mockKinAccountCreationApi: KinAccountCreationApiV4!
    var mockKinTransactionApi: KinTransactionApiV4!
    var mockKinStreamingApi: KinStreamingApiV4!
    var airdropApi: KinAirdropApi!
    var sut: KinServiceType!
    var context: KinAccountContext!

    override func setUp() {
        
        DispatchQueue.promises = DispatchQueue(label: "KinBase.default")
        let logger = KinLoggerFactoryImpl(isLoggingEnabled: true)
//        let networkHandler = NetworkOperationHandler()

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storage = KinFileStorage(directory: documentDirectory,
                                     network: .testNet)
        
        let appInfoProvider: AppInfoProvider = DummyAppInfoProvider()
        let grpcProxy = AgoraGrpcProxy(network: .testNet,
                                       appInfoProvider: appInfoProvider,
                                       storage: storage,
                                       logger: logger, interceptorFactories: [GRPCInterceptorFactory]())

        
        
        mockKinAccountApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
        mockKinAccountCreationApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
        mockKinTransactionApi = AgoraKinTransactionsApi(agoraGrpc: grpcProxy)
        mockKinStreamingApi = AgoraKinAccountsApi(agoraGrpc: grpcProxy)
        airdropApi = AgoraKinAirdropApi(agoraGrpc: grpcProxy)

        sut = KinServiceV4(network: .testNet,
                         networkOperationHandler: NetworkOperationHandler(),
                         dispatchQueue: .main,
                         accountApi: mockKinAccountApi,
                         accountCreationApi: mockKinAccountCreationApi,
                         transactionApi: mockKinTransactionApi,
                         streamingApi: mockKinStreamingApi,
                         logger: KinLoggerFactoryImpl(isLoggingEnabled: true))
        
        context = try! KinAccountContext.Builder.init(env: KinEnvironment.Agora.testNet(minApiVersion: 4))
            .createNewAccount()
            .build()
    }

    func testSpeed() {

//        Testing with KinService directly
//        let signer = try! KeyPair.generateRandomKeyPair()
//
//        sut.createAccount(accountId: signer.accountId, signer: signer).test(15, self) { (value, error) in
//
//        }
//
//        airdropApi.airdrop(accountId: signer.accountId, kin: 1).test(150, self) { (value, error) in
//            print("AIRDROP COMPLETE")
//        }
//
//        sut.getAccount(accountId: signer.accountId).test(150, self) { (value, error) in
//            print("GET ACCOUNT COMPLETE")
//        }
//
//        mockKinAccountApi.resolveTokenAccounts(request: ResolveTokenAccountsRequestV4(accountId: signer.accountId)) { (response) in
//            print("resolveTokenAccounts COMPLETE")
//        }
//
//
//        var transaction: KinTransaction? = nil
//        sut.buildAndSignTransaction(sourceKinAccount: KinAccount(key: signer),
//                                    paymentItems: [KinPaymentItem](arrayLiteral: KinPaymentItem(amount: Kin(1), destAccountId: airdropAccount.accountId)),
//                                    memo: KinMemo(text: "123"),
//                                    fee: 0
//        ).test(150, self) { (value, error) in
//            transaction = value
//            print("BUILDING COMPLETE")
//        }
//
//        sut.submitTransaction(transaction: transaction!).test(150, self) { (value, error) in
//           print("SUBMIT COMPLETE")
//        }
//
////        wait(35)
//
//        sut.getLatestTransactions(accountId: signer.asPublicKey().accountId).test(150, self) { (value, error) in
//            print("GET HISTORY COMPLETE")
//        }
//
//        sut.resolveTokenAccounts(accountId: airdropAccount.accountId).test(150, self) { (value, error) in
//            print("resolveTokenAccountsCOMPLETE")
//        }
//

        // KinAccountContext

        context.getAccount().test(150, self) // To force creation of the account
        context.env.testService?.fundAccount(context.accountPublicKey, amount: 10).test(150, self) // airdrop in 1 Kin

//        let testPayment: () -> Void = { self.context.sendKinPayment(KinPaymentItem(amount: Quark(Int.random(in: 0..<100)).kin, destAccountId: airdropAccount.accountId), memo: KinMemo.none)
//            .test(150, self) { (value, error) in
//                print("sendKinPayment - COMPLETE")
//            }
//        }
//
//        for _ in 0..<10 {
//            testPayment()
//        }

        let payments = [
            KinPaymentItem(amount: self.randomQuarkAmount(100).kin, destAccount: self.airdropAccount)
        ]
        runTest(times: 1, testCase: self, test: { onCompleted in
            self.context.sendKinPayments(payments, memo: KinMemo.none, destinationAccountSpec: .exact)
                .then { onCompleted($0) }
                .catch { onCompleted($0) }
        })
    }
    
    func randomQuarkAmount(_ lessThan: Int64 = 100) -> Quark {
        return Quark(Int64.random(in: 0...lessThan))
    }
    
    private func wait(_ timeout: Int) {
        print("Waiting \(timeout) Seconds...")
         Thread.sleep(until: Date().addingTimeInterval(TimeInterval(timeout)))
    }
    
    private func runTest(
        times: Int,
        testCase: XCTestCase,
        timeout: Int = 150, /* seconds */
        test: @escaping (_ onCompleted: @escaping (_ value: Any?) -> Void) -> Void
    ){
        var runs = [Double]()

        for i in 0..<times {
            let expect = testCase.expectation(description: "callback")
            let startTime = Date().timeIntervalSince1970
            _ = test { it in
                expect.fulfill()

                if (it != nil) {
                    let endTime = Date().timeIntervalSince1970
                    let totalTime: Double = endTime - startTime

                    runs.append(totalTime)

                    print("Test[\(i)] \(String(describing: runs.last))")
                } else {
                    print("Test[\(i)] failed! \(String(describing: it))")
                }
                
            }
            testCase.waitForExpectations(timeout: TimeInterval(timeout))
        }

        let p50 = runs.sorted().reversed()[Int(floor(Double(0.50) * Double(runs.count)))]
        let p95 = runs.sorted().reversed()[Int(floor(Double(0.95) * Double(runs.count)))]
        let p99 = runs.sorted().reversed()[Int(floor(Double(0.99) * Double(runs.count)))]

        print(runs)
        print(TestTimes(p50, p95, p99))
    }
}

public class TestTimes: CustomStringConvertible {
    public var description: String  {
        return "TestTimes(p50:\(p50), p95:\(p95), p99:\(p99)"
    }
    
    var p50: Double
    var p95: Double
    var p99: Double
    
    init(_ p50: Double, _ p95: Double, _ p99: Double) {
        self.p50 = p50
        self.p95 = p95
        self.p99 = p99
    }
    
}

extension Promise{
    func test(_ timeout: Int = 5,_ test: XCTestCase, completion: @escaping (_ value: Value?,_ error: Error?) -> Void = { _,_ in }) {
        let expect = test.expectation(description: "callback")
        self.then { it in
            NSLog("TEST RESULT: \(it)")
            completion(it, nil)
            expect.fulfill()
        }.catch { error in
            NSLog("TEST FAILED: \(error)")
            completion(nil,error)
            expect.fulfill()
        }
        test.waitForExpectations(timeout: TimeInterval(timeout))
    }
}
