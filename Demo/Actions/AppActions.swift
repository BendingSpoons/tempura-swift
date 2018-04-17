//
//  AppActions.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Katana

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
