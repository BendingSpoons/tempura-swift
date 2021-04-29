//
//  Routable.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import UIKit

/// Identifier to be used for a `Routable`.
public typealias RouteElementIdentifier = String
/// A path to identify a specific navigation state.
public typealias Route = [RouteElementIdentifier]
/// Closure called when a navigation action is completed.
public typealias RoutingCompletion = () -> Void

/// A Routable is a `ViewController` that takes active part to the execution of a navigation action.
/// This is intended to be used in the few cases the `RoutableWithConfiguration` is not enough.
///
/// For instance, if we want a screen `A` to present `B`, the ViewController that
/// is handling A, must conform to the Routable protocol.
///
/// Each Routable can be asked by the `Navigator` to perform a specific navigation task
/// (like present another ViewController) based on the NavigationAction you dispatch
/// (see `Show` or `Hide`).
///
///
/// ```swift
///    extension TodoListViewController: Routable {
///
///      var routeIdentifier: RouteElementIdentifier: {
///        return "todoList"
///      }
///
///      func show(indentifier: RouteElementIdentifier,
///        from: RouteElementIdentifier,
///        animated: Bool,
///        context: Any?,
///        completion: @escaping RoutingCompletion) -> Bool {
///
///          let vc = NextViewController(store: self.store)
///          self.present(vc, animated: animated, completion: completion)
///          return true
///      }
///    }
/// ```
///
/// ```swift
///    extension TodoListViewController: Routable {
///
///      func hide(indentifier: RouteElementIdentifier,
///        from: RouteElementIdentifier,
///        animated: Bool,
///        context: Any?,
///        completion: @escaping RoutingCompletion) -> Bool {
///
///          if identifier == self.routeIdentifier {
///            self.dismiss(animated: animated, completion: completion)
///            return true
///          }
///          return false
///      }
///    }
/// ```
public protocol Routable: AnyObject {
  /// The identifier associated to this Routable.
  /// ```swift
  ///    extension TodoListViewController: Routable {
  ///
  ///      var routeIdentifier: RouteElementIdentifier: {
  ///        return "todoList"
  ///      }
  ///    }
  /// ```
  var routeIdentifier: RouteElementIdentifier { get }

  /// When a `Show` action is dispatched, the `Navigator` can ask this Routable
  /// to show another Routable identified by `identifier` calling this method.
  /// You must call the completion callback as soon as the navigation is completed.
  /// Return `true` if this Routable is handling the action, `false` otherwise.

  /// ```swift
  ///    extension TodoListViewController: Routable {
  ///
  ///      func show(indentifier: RouteElementIdentifier,
  ///        from: RouteElementIdentifier,
  ///        animated: Bool,
  ///        context: Any?,
  ///        completion: @escaping RoutingCompletion) -> Bool {
  ///
  ///          let vc = NextViewController(store: self.store)
  ///          self.present(vc, animated: animated, completion: completion)
  ///          return true
  ///      }
  ///    }
  /// ```
  func show(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion
  ) -> Bool

  /// When a `Hide` action is dispatched, the `Navigator` can ask this Routable
  /// to hide itself or another Routable identified by `identifier` calling this method.
  /// Return `true` if this Routable is handling the action, `false` otherwise.

  /// ```swift
  ///    extension TodoListViewController: Routable {
  ///
  ///      func hide(indentifier: RouteElementIdentifier,
  ///        from: RouteElementIdentifier,
  ///        animated: Bool,
  ///        context: Any?,
  ///        completion: @escaping RoutingCompletion) -> Bool {
  ///
  ///          if identifier == self.routeIdentifier {
  ///            self.dismiss(animated: animated, completion: completion)
  ///            return true
  ///          }
  ///          return false
  ///      }
  ///    }
  /// ```
  func hide(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion
  ) -> Bool

  /// When a `Navigate` action is dispatched, the `Navigator` can ask this Routable
  /// to hide/show itself or another Routable identified by `identifier` calling this method.
  /// Return `true` if this Routable is handling the action, `false` otherwise.
  func change(
    from: RouteElementIdentifier,
    to: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion
  )
}

extension Routable {
  /// Change a route element
  public func change(
    from: RouteElementIdentifier,
    to: RouteElementIdentifier,
    animated _: Bool,
    context _: Any?,
    completion _: @escaping RoutingCompletion
  ) {
    fatalError(
      // swiftlint:disable:next line_length
      "This Routable element cannot change the navigation from \"\(from)\" to \"\(to)\", the implementation of \(#function) is missing"
    )
  }

  /// Show a route element
  public func show(
    identifier _: RouteElementIdentifier,
    from _: RouteElementIdentifier,
    animated _: Bool,
    context _: Any?,
    completion _: @escaping RoutingCompletion
  ) -> Bool {
    return false
  }

  /// Hide a route element
  public func hide(
    identifier _: RouteElementIdentifier,
    from _: RouteElementIdentifier,
    animated _: Bool,
    context _: Any?,
    completion _: @escaping RoutingCompletion
  ) -> Bool {
    return false
  }
}
