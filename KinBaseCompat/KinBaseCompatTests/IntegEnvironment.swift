import Foundation

// NOTE: This params are changed in CI by injecting them from environemnt variables, any change should be reflected as well in CI
// and in the template file scripts/IntegEnvironmentTemplate.swift
public struct IntegEnvironment {
    static let networkUrl: String = "https://horizon-testnet.kininfrastructure.com"
    static let networkPassphrase: String = "Kin Testnet ; December 2018"
    static let friendbotUrl: String = "https://friendbot-testnet.kininfrastructure.com"
}
