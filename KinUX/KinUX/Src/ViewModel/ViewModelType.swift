//
//  ViewModel.swift
//  KinViewModel
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public typealias StateListener<StateType> = (StateType) -> Void

public protocol ObservableViewModelType {
    associatedtype StateType: Equatable

    func addStateUpdateListener(_ listener: @escaping StateListener<StateType>)

    func removeAllListeners()
}

public protocol ViewModelType: ObservableViewModelType {
    associatedtype ArgsType
    associatedtype StateType

    func cleanup()
}

open class BaseObservableViewModel<StateType: Equatable> : ObservableViewModelType {

    public typealias StateType = StateType

    private var state: StateType? = nil
    private var listeners = [StateListener<StateType>]()

    public init() {

    }

    private func getOrInitState() -> StateType {
        if let state = state {
            return state
        }

        let defaultState = getDefaultState()
        onStateUpdated(defaultState)
        state = defaultState
        return defaultState
    }

    public func addStateUpdateListener(_ listener: @escaping StateListener<StateType>) {
        listeners.append(listener)
        listener(getOrInitState())
    }

    public func removeAllListeners() {
        listeners.removeAll()
    }

    public func updateState(updater: (_ previousState: StateType) -> StateType) {
        let currentState = getOrInitState()
        let updatedState = updater(currentState)

        state = updatedState

        if currentState != updatedState {
            listeners.forEach { $0(updatedState) }
        }

        onStateUpdated(updatedState)
    }

    open func getDefaultState() -> StateType {
        fatalError("Missing implementation in subclass.")
    }

    open func onStateUpdated(_ state: StateType) {
        // Subclass can override
    }
}

open class BaseViewModel<ArgsType, StateType: Equatable>: BaseObservableViewModel<StateType>, ViewModelType {
    public typealias ArgsType = ArgsType
    public typealias StateType = StateType

    open func cleanup() {
        // Subclass can override
    }
}

public protocol Navigator {

}
