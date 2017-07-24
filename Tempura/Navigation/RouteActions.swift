//
//  RouteActions.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 04/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

struct Navigate: Action, ActionWithSideEffect {
  var route: Route
  var animated: Bool
  
  func updatedState(currentState: State) -> State {
    return currentState
  }
  
  init(to route: Route, animated: Bool = false) {
    self.route = route
    self.animated = animated
  }
  
  func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.routeDidChange(newRoute: self.route, isAnimated: self.animated)
    }
  }
  
}
