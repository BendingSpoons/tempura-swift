//
//  RouteActions.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 04/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

/// Navigation action used to ask the `Navigator` to navigate to a specific `Route`.
public struct NavigateNew: AnySideEffect {
  public let route: Route
  public let animated: Bool
  public let context: Any?
  
  /// Initializes and return a Navigate action.
  public init(to route: Route, animated: Bool = false, context: Any? = nil) {
    self.route = route
    self.animated = animated
    self.context = context
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(_ context: AnySideEffectContext) throws {
    guard let dependencies = context.anyDependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try await(dependencies.navigator.changeRoute(newRoute: self.route, animated: self.animated, context: self.context))
  }
}
@available(*, deprecated: 2.2.0, message: "With the new Katana 3.0 you can use the `NavigateNew` SideEffect")
public struct Navigate: Action, ActionWithSideEffect {
  var route: Route
  var animated: Bool
  var context: Any?
  
  /// Returns the new state after the action is dispatched.
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  /// Initializes and return a Navigate action.
  public init(to route: Route, animated: Bool = false, context: Any? = nil) {
    self.route = route
    self.animated = animated
    self.context = context
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.changeRoute(newRoute: self.route, animated: self.animated, context: self.context).void
  }
}

/// Navigation action used to ask the `Navigator` to show a specific screen
/// identified by the `identifierToShow`.
///
/// The `ViewController` that is managing that screen must implement `RoutableWithConfiguration`
/// or `Routable` in order to be identified with a matching `Routable.routeIdentifier`.
public struct ShowNew: AnySideEffect {
  public let identifiersToShow: [RouteElementIdentifier]
  public let animated: Bool
  public let context: Any?
  
  /// Initializes and return a Show action.
  public init(_ identifiersToShow: [RouteElementIdentifier], animated: Bool = false, context: Any? = nil) {
    self.identifiersToShow = identifiersToShow
    self.animated = animated
    self.context = context
  }
  
  /// Initializes and returns a Show action.
  public init(_ identifierToShow: RouteElementIdentifier, animated: Bool = false, context: Any? = nil) {
    self.init([identifierToShow], animated: animated, context: context)
  }
  
  /// Initializes and returns a Show action.
  public init<K>(_ identifiersToShow: [K], animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifiersToShow.map { $0.rawValue }, animated: animated, context: context)
  }
  
  /// Initializes and returns a Show action.
  public init<K>(_ identifierToShow: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToShow.rawValue, animated: animated, context: context)
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(_ context: AnySideEffectContext) throws {
    guard let dependencies = context.anyDependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try await(dependencies.navigator.show(self.identifiersToShow, animated: self.animated, context: self.context))
  }
}

@available(*, deprecated: 2.2.0, message: "With the new Katana 3.0 you can use the `ShowNew` SideEffect")
public struct Show: Action, ActionWithSideEffect {
  var identifiersToShow: [RouteElementIdentifier]
  var animated: Bool
  var context: Any?
  
  /// Returns the new state after the action is dispatched.
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  /// Initializes and returns a Show action.
  public init(_ identifiersToShow: [RouteElementIdentifier], animated: Bool = false, context: Any? = nil) {
    self.identifiersToShow = identifiersToShow
    self.animated = animated
    self.context = context
  }
  
  /// Initializes and returns a Show action.
  public init(_ identifierToShow: RouteElementIdentifier, animated: Bool = false, context: Any? = nil) {
    self.init([identifierToShow], animated: animated, context: context)
  }
  
  /// Initializes and returns a Show action.
  public init<K>(_ identifiersToShow: [K], animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifiersToShow.map { $0.rawValue }, animated: animated, context: context)
  }
  
  /// Initializes and returns a Show action.
  public init<K>(_ identifierToShow: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToShow.rawValue, animated: animated, context: context)
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.show(self.identifiersToShow, animated: self.animated, context: self.context).void
  }
}

/// Navigation action used to ask the `Navigator` to hide a specific screen
/// identified by the `identifierToHide`.
///
/// The `ViewController` that is managing that screen must implement `RoutableWithConfiguration`
/// or `Routable` in order to be identified with a matching `Routable.routeIdentifier`.
public struct HideNew: AnySideEffect {
  public let identifierToHide: RouteElementIdentifier
  public let animated: Bool
  public let context: Any?
  public let atomic: Bool
  
  /// Initializes and return a Hide action.
  public init(_ identifierToHide: RouteElementIdentifier, animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    self.identifierToHide = identifierToHide
    self.animated = animated
    self.context = context
    self.atomic = atomic
  }
  
  /// Initializes and return a Hide action.
  public init<K>(_ identifierToHide: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToHide.rawValue, animated: animated, context: context)
  }
  
  /// Initializes and return a Hide action.
  public init(animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last!
    self.init(identifierToHide, animated: animated, context: context, atomic: atomic)
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(_ context: AnySideEffectContext) throws {
    guard let dependencies = context.anyDependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try await(dependencies.navigator.hide(self.identifierToHide, animated: self.animated, context: self.context, atomic: self.atomic))
  }
}

@available(*, deprecated: 2.2.0, message: "With the new Katana 3.0 you can use the `HideNew` SideEffect")
public struct Hide: Action, ActionWithSideEffect {
  var identifierToHide: RouteElementIdentifier
  var animated: Bool
  var context: Any?
  var atomic: Bool
  
  /// Returns the new state after the action is dispatched.
  public func updatedState(currentState: State) -> State {
    return currentState
  }
  
  /// Initializes and return a Hide action.
  public init(_ identifierToHide: RouteElementIdentifier, animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    self.identifierToHide = identifierToHide
    self.animated = animated
    self.context = context
    self.animated = animated
    self.atomic = atomic
  }
  
  /// Initializes and return a Hide action.
  public init<K>(_ identifierToHide: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
      self.init(identifierToHide.rawValue, animated: animated, context: context)
  }
  
  /// Initializes and return a Hide action.
  public init(animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last!
    self.init(identifierToHide, animated: animated, context: context, atomic: atomic)
  }
  
  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func sideEffect(currentState: State, previousState: State, dispatch: @escaping StoreDispatch, dependencies: SideEffectDependencyContainer) {
    guard let dependencies = dependencies as? NavigationProvider else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    dependencies.navigator.hide(self.identifierToHide, animated: self.animated, context: self.context, atomic: self.atomic).void
  }
  
}
