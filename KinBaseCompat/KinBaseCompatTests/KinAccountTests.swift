//
//  KinAccountTests.swift
//  KinTestHostTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class KinAccountTests: XCTestCase {
    var kinClient: KinClient!
    let passphrase = UUID().uuidString

    var account0: KinAccount!
    var account1: KinAccount!
    var issuer: StellarAccount?

    let endpoint = "https://horizon-testnet.kininfrastructure.com"
    let sNetwork: Network = .testNet
    lazy var kNetwork: Network = .testNet

    let requestTimeout: TimeInterval = 30

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        guard let appId = try? AppId("test") else {
            XCTAssertTrue(false, "Unable to create app id")
            return
        }

        kinClient = KinClient(with: URL(string: endpoint)!, network: kNetwork, appId: appId)

        KeyStore.removeAll()

        if KeyStore.count() > 0 {
            XCTAssertTrue(false, "Unable to clear existing accounts!")
        }

        guard let account0 = try? kinClient.addAccount(), let account1 = try? kinClient.addAccount() else {
            XCTAssertTrue(false, "Unable to create account(s)!")
            return
        }

        self.account0 = account0
        self.account1 = account1

        createAccountAndFund(kinAccount: account0, amount: 100)
        createAccountAndFund(kinAccount: account1, amount: 100)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

//    // MARK: - Extra Data
//
//    func test_extra_data() {
//        account0.extra = Data([1, 2, 3])
//
//        XCTAssertEqual(Data([1, 2, 3]), account0.extra)
//    }

    // MARK: - Balance

    func test_balance_sync() {
        do {
            var balance = try getBalance(account0)

            if balance == 0 {
                balance = try waitForNonZeroBalance(account: account0)
            }

            XCTAssertNotEqual(balance, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_balance_async() {
        do {
            let expectation = XCTestExpectation()

            var balanceChecked: Kin? = nil

            _ = try waitForNonZeroBalance(account: account0)

            account0.balance { balance, _ in
                balanceChecked = balance
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_balance_promise() {
        do {
            let expectation = XCTestExpectation()

            var balanceChecked: Kin? = nil

            _ = try waitForNonZeroBalance(account: account0)

            account0.balance()
                .then { balance in
                    balanceChecked = balance
                }
                .finally {
                    expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    // MARK: - Build Transaction

    func test_build_transaction_of_zero_kin() {
        let expectation = XCTestExpectation()

        account0.generateTransaction(to: account1.publicAddress, kin: 0, memo: nil, fee: 0) { (envelope, error) in
            if let _ = envelope {
                XCTAssertTrue(false, "Envelope should be nil")
            }

            guard let error = error else {
                XCTAssertTrue(false, "Error should not be nil")
                return
            }

            guard let kinError = error as? KinError, case KinError.invalidAmount = kinError else {
                XCTAssertTrue(false, "Received unexpected error: \(error.localizedDescription)")
                return
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: requestTimeout)
    }

    // MARK: - Send Transaction

    func test_send_transaction_with_nil_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            buildTransaction(kin: sendAmount, memo: nil, fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            buildTransaction(kin: sendAmount, memo: "memo", fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_empty_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            buildTransaction(kin: sendAmount, memo: "", fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_insufficient_funds() {
        do {
            let expectation = XCTestExpectation()

            let balance = try getBalance(account0)
            let amount = balance * Kin(AssetUnitDivisor) + 1

            buildTransaction(kin: amount, memo: nil, fee: 0) { envelope in
                do {
                    _ = try self.sendTransaction(envelope)

                    XCTAssertTrue(false, "Tried to send kin with insufficient funds, but didn't get an error")
                }
                catch {
                    if case KinError.insufficientFunds = error {
                        expectation.fulfill()
                    }
                    else {
                        XCTAssertTrue(false, "Tried to send kin, and got error, but not .insufficientFunds: \(error)")
                    }
                }
            }

            wait(for: [expectation], timeout: requestTimeout)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    // MARK: - Deleting Account

    func test_balance_after_delete() {
        do {
            guard let account = kinClient.accounts[0] else {
                XCTAssert(false, "Failed to get an account")
                return
            }

            try kinClient.deleteAccount(at: 0)
            _ = try getBalance(account)

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            guard let kinError = error as? KinError, case KinError.accountDeleted = kinError else {
                XCTAssertTrue(false, "Received unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    func test_transaction_after_delete() {
        do {
            let expectation = XCTestExpectation()

            guard let account = kinClient.accounts[0] else {
                XCTAssert(false, "Failed to get an account")
                return
            }

            try kinClient.deleteAccount(at: 0)

            account.generateTransaction(to: "", kin: 1, memo: nil, fee: 0) { (envelope, error) in
                guard let error = error else {
                    XCTAssertTrue(false, "Error should not be nil")
                    return
                }

                guard let kinError = error as? KinError, case KinError.accountDeleted = kinError else {
                    XCTAssertTrue(false, "Received unexpected error: \(error)")
                    return
                }

                expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    // MARK: - Export

    func test_export() {
        do {
            let data = try account0.export(passphrase: passphrase)

            XCTAssertNotNil(data, "Unable to retrieve keyStore account: \(String(describing: account0))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}

extension KinAccountTests {
    func createAccountAndFund(kinAccount: KinAccount, amount: Kin) {
        let group = DispatchGroup()
        group.enter()

        let url = URL(string: "https://friendbot-testnet.kininfrastructure.com?addr=\(kinAccount.publicAddress)&amount\(amount)")!
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard
                let data = data,
                let jsonOpt = try? JSONSerialization.jsonObject(with: data, options: []),
                let _ = jsonOpt as? [String: Any]
                else {
                    print("Unable to parse json for createAccount().")

                    group.leave()
                    return
            }
            group.leave()
        }).resume()
        group.wait()
    }

    func getBalance(_ account: KinAccount) throws -> Kin {
        if let balance: Decimal = try serialize(account.balance) {
            return balance
        }

        throw KinError.unknown
    }

    func buildTransaction(kin: Kin, memo: String?, fee: Stroop, completion: @escaping (TransactionEnvelope) -> Void) {
        account0.generateTransaction(to: account1.publicAddress, kin: kin, memo: memo, fee: fee) { (envelope, error) in
            DispatchQueue.main.async {
                self.fail(on: error)

                XCTAssertNotNil(envelope, "The envelope should not be nil")

                guard let envelope = envelope else {
                    return
                }

                completion(envelope)
            }
        }
    }

    func sendTransaction(_ envelope: TransactionEnvelope) throws -> TransactionId {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            self.account0.sendTransaction(envelope, completion: txComp)
        }

        if let txHash = try serialize(txClosure) {
            return txHash
        }

        throw KinError.unknown
    }

    func waitForNonZeroBalance(account: KinAccount) throws -> Kin {
        var balance = try getBalance(account)

        let predicate = NSPredicate(block: { _, _ in
            do {
                balance = try self.getBalance(account)
            }
            catch {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            return balance > 0
        })

        let exp = expectation(for: predicate, evaluatedWith: balance)

        wait(for: [exp], timeout: requestTimeout)

        return balance
    }

    func prepareCompareBalance() throws -> (sendAmount: Decimal, startBalance0: Decimal, startBalance1: Decimal) {
        let sendAmount: Decimal = 5
        var startBalance0 = try getBalance(account0)
        var startBalance1 = try getBalance(account1)

        if startBalance0 == 0 {
            startBalance0 = try waitForNonZeroBalance(account: account0)
        }

        if startBalance1 == 0 {
            startBalance1 = try waitForNonZeroBalance(account: account1)
        }

        return (sendAmount, startBalance0, startBalance1)
    }

    func compareBalance(sendAmount: Decimal, startBalance0: Decimal, startBalance1: Decimal, completion: @escaping () -> ()) {
        do {
            let balance0 = try self.getBalance(self.account0)
            let balance1 = try self.getBalance(self.account1)

            kinClient.minFee().then { quark in
                let fee = (Kin(quark) / Kin(AssetUnitDivisor))

                XCTAssertEqual(balance0, startBalance0 - sendAmount - fee)
                XCTAssertEqual(balance1, startBalance1 + sendAmount)

                completion()
            }
        }
        catch {
            self.fail(on: error)
        }
    }

    func fail(on error: Error?) {
        if let error = error {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
