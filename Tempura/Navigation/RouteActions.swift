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

public struct Show: Action, ActionWithSideEffect {
  var identifiersToShow: [RouteElementIdentifier]
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(_ identifiersToShow: [RouteElementIdentifier], animated: Bool = false) {
    self.identifiersToShow = identifiersToShow
    self.animated = animated
  }
  
  public init(_ identifierToShow: RouteElementIdentifier, animated: Bool = false) {
    self.init([identifierToShow], animated: animated)
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.show(self.identifiersToShow, animated: self.animated)
    }
  }
  
}

public struct Hide: Action, ActionWithSideEffect {
  var identifierToHide: RouteElementIdentifier
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(_ identifierToHide: RouteElementIdentifier, animated: Bool = false) {
    self.identifierToHide = identifierToHide
    self.animated = animated
  }
  
  public init(animated: Bool = false) {
    let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last!
    self.init(identifierToHide, animated: animated)
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.hide(self.identifierToHide, animated: self.animated)
    }
  }
  
}

/*public struct PresentModally: Action, ActionWithSideEffect {
  // the route of the modal viewControllers to show on top of the current route
  var routeElementID: RouteElementIdentifier
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(routeElementID: RouteElementIdentifier, animated: Bool = false) {
    self.routeElementID = routeElementID
    self.animated = animated
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.presentModally(routeElementID: self.routeElementID, animated: self.animated)
    }
  }
}

public struct DismissModally: Action, ActionWithSideEffect {
  // the route of the modal viewControllers to show on top of the current route
  var routeElementID: RouteElementIdentifier
  var animated: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(routeElementID: RouteElementIdentifier, animated: Bool = false) {
    self.routeElementID = routeElementID
    self.animated = animated
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    if let dependencies = dependencies as? NavigationProvider {
      dependencies.navigator.dismissModally(routeElementID: self.routeElementID, animated: self.animated)
    }
  }
}*/
