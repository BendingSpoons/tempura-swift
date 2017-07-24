//
//  AppActions.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Katana

// MARK: - App Sync Action

protocol AppAction: Action {
  func updatedState(currentState: inout AppState)
}

extension AppAction {
  public func updatedState(currentState: State) -> State {
    guard var state = currentState as? AppState else {
      fatalError()
    }
    self.updatedState(currentState: &state)
    return state
  }
}

extension AppAction {
  func updatedState(currentState: inout AppState) {}
}

// MARK: - App Async Action

protocol AppAsyncAction: AsyncAction {
  func updatedStateForFailed(currentState: inout AppState)
  func updatedStateForLoading(currentState: inout AppState)
  func updatedStateForCompleted(currentState: inout AppState)
  func updatedStateForProgress(currentState: inout AppState)
}

extension AppAsyncAction {
  func updatedStateForFailed(currentState: State) -> State {
    guard var state = currentState as? AppState else {
      fatalError()
    }
    self.updatedStateForFailed(currentState: &state)
    return state
  }
  
  func updatedStateForLoading(currentState: State) -> State {
    guard var state = currentState as? AppState else {
      fatalError()
    }
    self.updatedStateForLoading(currentState: &state)
    return state
  }
  
  func updatedStateForCompleted(currentState: State) -> State {
    guard var state = currentState as? AppState else {
      fatalError()
    }
    self.updatedStateForCompleted(currentState: &state)
    return state
  }
  
  func updatedStateForProgress(currentState: State) -> State {
    guard var state = currentState as? AppState else {
      fatalError()
    }
    self.updatedStateForProgress(currentState: &state)
    return state
  }
}

/// MARK: Default empty implementations
extension AppAsyncAction {
  func updatedStateForFailed(currentState: inout AppState) {}
  func updatedStateForLoading(currentState: inout AppState) {}
  func updatedStateForCompleted(currentState: inout AppState) {}
  func updatedStateForProgress(currentState: inout AppState) {}
}

// MARK: - App Action With Side Effect

protocol AppActionWithSideEffect: ActionWithSideEffect {
  func sideEffect(
    currentState: AppState,
    previousState: AppState,
    dispatch: @escaping StoreDispatch,
    dependencies: DependenciesContainer
  )
}

extension AppActionWithSideEffect {
  func sideEffect(
    currentState: State,
    previousState: State,
    dispatch: @escaping StoreDispatch,
    dependencies: SideEffectDependencyContainer
    ) {
    guard let currentState = currentState as? AppState,
      let previousState = previousState as? AppState,
      let dependencies = dependencies as? DependenciesContainer else {
        fatalError()
    }
    
    self.sideEffect(currentState: currentState, previousState: previousState, dispatch: dispatch, dependencies: dependencies)
  }
}
