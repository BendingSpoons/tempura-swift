//
//  NavigationActions.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Hydra
import Katana
import UIKit

/// Protocol for all the navigation-related SideEffect exposed by Tempura
public protocol NavigationSideEffect: AnySideEffect {}

/// Navigation action used to ask the `Navigator` to navigate to a specific `Route`.
public struct Navigate: NavigationSideEffect {
  /// The final `Route` after the navigation is completed
  public let route: Route
  /// Specify if the `Navigation` should be animated
  public let animated: Bool
  /// The context of this `Navigation`
  public let context: Any?

  /// Initializes and return a Navigate action.
  public init(to route: Route, animated: Bool = false, context: Any? = nil) {
    self.route = route
    self.animated = animated
    self.context = context
  }

  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func anySideEffect(_ context: AnySideEffectContext) throws -> Any {
    guard let dependencies = context.anyDependencies as? NavigationProvider
    else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try Hydra.await(dependencies.navigator.changeRoute(newRoute: self.route, animated: self.animated, context: self.context))
    return ()
  }
}

/// Implementation of the `CustomDebugStringConvertible` protocol
extension Navigate: CustomDebugStringConvertible {
  public var debugDescription: String {
    let routeToDescribe = self.route.joined(separator: ".")
    return String(reflecting: type(of: self))
      + "." + routeToDescribe
  }
}

/// Navigation action used to ask the `Navigator` to show a specific screen
/// identified by the `identifierToShow`.
///
/// The `ViewController` that is managing that screen must implement `RoutableWithConfiguration`
/// or `Routable` in order to be identified with a matching `Routable.routeIdentifier`.
public struct Show: NavigationSideEffect {
  /// The identifiers of the `Routable` to be shown
  public let identifiersToShow: [RouteElementIdentifier]
  /// Specify if the `Show` should be animated
  public let animated: Bool
  /// The context of the `Show`
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
  public func anySideEffect(_ context: AnySideEffectContext) throws -> Any {
    guard let dependencies = context.anyDependencies as? NavigationProvider
    else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try Hydra.await(dependencies.navigator.show(self.identifiersToShow, animated: self.animated, context: self.context))
    return ()
  }
}

/// Implementation of the `CustomDebugStringConvertible` protocol
extension Show: CustomDebugStringConvertible {
  public var debugDescription: String {
    let actionDebugDescription = String(reflecting: type(of: self))
    switch self.identifiersToShow.count {
    case 1:
      // most common usecase
      return actionDebugDescription + "." + self.identifiersToShow.first! // swiftlint:disable:this force_unwrapping
    default:
      let identifiersToDescribe = self.identifiersToShow.joined(separator: ", ")
      return actionDebugDescription + " [" + identifiersToDescribe + "]"
    }
  }
}

/// Navigation action used to ask the `Navigator` to hide a specific screen
/// identified by the `identifierToHide`.
///
/// The `ViewController` that is managing that screen must implement `RoutableWithConfiguration`
/// or `Routable` in order to be identified with a matching `Routable.routeIdentifier`.
public struct Hide: NavigationSideEffect {
  /// The identifier of the `Routable` to be hidden
  public let identifierToHide: RouteElementIdentifier
  /// Specify if the `Hide` should be animated
  public let animated: Bool
  /// The context of the `Hide`
  public let context: Any?
  /// Specify if the Hide should generate one single navigation request.
  /// For instance, if we have a Route like `A/B/C/D` and we ask to hide `B`, with `atomic = false`, three different Hide commands
  /// will be generated: the request to hide D, then the request to hide C and finally the request to hide B.
  /// If we use `atomic = true`, only the request to hide B will be generated.
  public let atomic: Bool

  /// Initializes and returns a Hide action.
  public init(_ identifierToHide: RouteElementIdentifier, animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    self.identifierToHide = identifierToHide
    self.animated = animated
    self.context = context
    self.atomic = atomic
  }

  /// Initializes and returns a Hide action.
  public init<K>(_ identifierToHide: K, animated: Bool = false, context: Any? = nil)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
    self.init(identifierToHide.rawValue, animated: animated, context: context)
  }

  /// Initializes and returns a Hide action.
  public init<K>(_ identifierToHide: K, animated: Bool = false, context: Any? = nil, atomic: Bool = false)
    where K: RawRepresentable, K.RawValue == RouteElementIdentifier {
    self.init(identifierToHide.rawValue, animated: animated, context: context, atomic: atomic)
  }

  /// Initializes and return a Hide action.
  public init(animated: Bool = false, context: Any? = nil, atomic: Bool = false) {
    let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last! // swiftlint:disable:this force_unwrapping
    self.init(identifierToHide, animated: animated, context: context, atomic: atomic)
  }

  /// The side effect of the action, look into [Katana](https://github.com/BendingSpoons/katana-swift)
  /// to know what a `SideEffect` is.
  public func anySideEffect(_ context: AnySideEffectContext) throws -> Any {
    guard let dependencies = context.anyDependencies as? NavigationProvider
    else { fatalError("DependenciesContainer must conform to `NavigationProvider`") }
    try Hydra
      .await(
        dependencies.navigator
          .hide(self.identifierToHide, animated: self.animated, context: self.context, atomic: self.atomic)
      )
    return ()
  }
}

/// Implementation of the `CustomDebugStringConvertible` protocol
extension Hide: CustomDebugStringConvertible {
  public var debugDescription: String {
    let actionDebugDescription = String(reflecting: type(of: self))
    return actionDebugDescription + "." + self.identifierToHide
  }
}
