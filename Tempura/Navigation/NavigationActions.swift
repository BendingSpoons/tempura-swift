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
  var context: Any?
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(to route: Route, animated: Bool = false, context: Any? = nil) {
    self.route = route
    self.animated = animated
    self.context = context
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.changeRoute(newRoute: self.route, animated: self.animated, context: self.context)
  }
  
}

public struct Show: Action, ActionWithSideEffect {
  var identifiersToShow: [RouteElementIdentifier]
  var animated: Bool
  var context: Any?
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(_ identifiersToShow: [RouteElementIdentifier], animated: Bool = false, context: Any? = nil) {
    self.identifiersToShow = identifiersToShow
    self.animated = animated
    self.context = context
  }
  
  public init(_ identifierToShow: RouteElementIdentifier, animated: Bool = false, context: Any? = nil) {
    self.init([identifierToShow], animated: animated, context: context)
  }
  
  public init<K>(_ identifiersToShow: [K], animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifiersToShow.map { $0.rawValue }, animated: animated, context: context)
  }
  
  public init<K>(_ identifierToShow: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToShow.rawValue, animated: animated, context: context)
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.show(self.identifiersToShow, animated: self.animated, context: self.context)
  }
  
}

public struct Hide: Action, ActionWithSideEffect {
  var identifierToHide: RouteElementIdentifier
  var animated: Bool
  var context: Any?
  var atomic: Bool
  
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  public init(_ identifierToHide: RouteElementIdentifier, animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    self.identifierToHide = identifierToHide
    self.animated = animated
    self.context = context
    self.animated = animated
    self.atomic = false
  }
  
  public init<K>(_ identifierToHide: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToHide.rawValue, animated: animated, context: context)
  }
  
  public init(animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last!
    self.init(identifierToHide, animated: animated, context: context, atomic: atomic)
  }
  
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.hide(self.identifierToHide, animated: self.animated, context: self.context, atomic: self.atomic)
  }
  
}
