//
//  RouteActions.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 04/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

public struct Navigate: Action, ActionWithSideEffect {
  var route: Route
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(to route: Route, animated: Bool = false) {
    self.route = route
    self.animated = animated
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.changeRoute(newRoute: self.route, animated: self.animated)
    }
  }
  
}

public struct Push: Action, ActionWithSideEffect {
  var route: Route
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(to route: Route, animated: Bool = false) {
    self.route = route
    self.animated = animated
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.push(to: self.route, animated: self.animated)
    }
  }
  
}

public struct Pop: Action, ActionWithSideEffect {
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(animated: Bool = false) {
    self.animated = animated
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.pop(animated: self.animated)
    }
  }
  
}
