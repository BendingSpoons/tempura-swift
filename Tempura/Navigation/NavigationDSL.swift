//
//  NavigationDSL.swift
//  Tempura
//
//  Created by Mauro Bolis on 12/12/2017.
//

import Foundation

/// Used by a `RoutableWithConfiguration` inside its `RoutableWithConfiguration.navigationConfiguration`
/// to describe the kind of navigation action (`Show`, `Hide`) to handle.
///
/// ```swift
///    extension ListViewController: RoutableWithConfiguration {
///
///      // needed by the `Routable` protocol
///      // to identify this ViewController in the hierarchy
///      var routeIdentifier: RouteElementIdentifier {
///        return "listScreen"
///      }
///
///      // the `NavigationRequest`s that this ViewController is handling
///      // with the `NavigationInstruction` to execute
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
///        return [
///          .show("addItemScreen"): .presentModally({ [unowned self] _ in
///            let vc = AddItemViewController(store: self.store)
///            return vc
///          })
///        ]
///    }
/// ```
///
public struct NavigationRequest: Hashable {
  
  fileprivate enum NavigationKind: Int {
    case show, hide
  }
  /// Represents a NavigationRequest to match a `Show` action dispatched.
  public static func show<T: RawRepresentable>(_ source: T) -> NavigationRequest where T.RawValue == RouteElementIdentifier {
    return NavigationRequest(source: source.rawValue, kind: .show)
  }
  /// Represents a NavigationRequest to match a `Hide` action dispatched.
  public static func hide<T: RawRepresentable>(_ source: T) -> NavigationRequest where T.RawValue == RouteElementIdentifier {
    return NavigationRequest(source: source.rawValue, kind: .hide)
  }
  
  private let source: String
  private let kind: NavigationKind
  
  private init(source: String, kind: NavigationKind) {
    self.source = source
    self.kind = kind
  }
  
  // Conformance to Hashable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.source)
    hasher.combine(self.kind)
  }
  
  fileprivate func canHandle(_ identifier: String, kind: NavigationKind) -> Bool {
    return self.source == identifier && kind == self.kind
  }
  /// Implementation of the equality between two NavigationRequest.
  public static func == (l: NavigationRequest, r: NavigationRequest) -> Bool {
    if l.kind != r.kind {
      return false
    }
    
    if l.source != r.source {
      return false
    }
    
    return true
  }
}

/// Closure used by a `NavigationInstruction` of type `.custom`.
public typealias CustomNavigationOptionClosure = (
  _ identifier: RouteElementIdentifier,
  _ from: RouteElementIdentifier,
  _ animated: Bool,
  _ context: Any?,
  _ completion: @escaping RoutingCompletion
) -> Void

/// Closure used by a `NavigationInstruction` of type `.optionalCustom`.
public typealias OptionalCustomNavigationOptionClosure = (
  _ identifier: RouteElementIdentifier,
  _ from: RouteElementIdentifier,
  _ animated: Bool,
  _ context: Any?,
  _ completion: @escaping RoutingCompletion
) -> Bool

/// Used by a `RoutableWithConfiguration` inside its `RoutableWithConfiguration.navigationConfiguration`
/// to describe the kind of navigation to perform when handling a `NavigationRequest`.
///
/// ```swift
///    extension ListViewController: RoutableWithConfiguration {
///
///      // needed by the `Routable` protocol
///      // to identify this ViewController in the hierarchy
///      var routeIdentifier: RouteElementIdentifier {
///        return "listScreen"
///      }
///
///      // the `NavigationRequest`s that this ViewController is handling
///      // with the `NavigationInstruction` to execute
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
///        return [
///          .show("addItemScreen"): .presentModally({ [unowned self] _ in
///            let vc = AddItemViewController(store: self.store)
///            return vc
///          })
///        ]
///    }
/// ```
///
public enum NavigationInstruction {
  /// Define one of the two possible behaviours when dismissing a modal ViewController:
  ///
  /// `.soft`: dismiss the ViewController but keep all the presented ViewControllers
  ///
  /// `.hard`: the usual UIKit behaviour, dismiss the ViewController and all the ViewControllers that is presenting
  public enum ModalDismissBehaviour {
    /// If the targeted modal is presenting other modals, keep them alive.
    case soft
    /// While removing the targeted modal, remove also all the modals that it is presenting.
    case hard
  }
  /// Push the ViewController using `UINavigationController.pushViewController(:animated:)`.
  case push((_ context: Any?) -> UIViewController)
  /// Pop the ViewController using `UINavigationController.popViewController(animated:)`.
  case pop
  
  /// Pops up to the root ViewController using `UINavigationcontroller.popToRootViewController(animated:)
  case popToRootViewController
  
  /// Pops up to a ViewController using `UINavigationcontroller.popToViewController(:animated:)
  case popToViewController(identifier: RouteElementIdentifier)

  /// Present the ViewController modally using `UIViewController.present(:animated:completion:)`.
  case presentModally((_ context: Any?) -> UIViewController)

  /// Dismiss the ViewController presented modally using `UIViewController.dismiss(animated:completion:)`.
  case dismissModally(behaviour: ModalDismissBehaviour)

  /// Define your custom implementation of the navigation.
  case custom(CustomNavigationOptionClosure)

  /// Define your custom implementation of the navigation.
  case optionalCustom(OptionalCustomNavigationOptionClosure)

  func handle(
    sourceViewController: UIViewController,
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    let handled: Bool
    switch self {
    case let .push(vcClosure):
      let vc = vcClosure(context)
      self.handlePush(sourceViewController: sourceViewController, childVC: vc, animated: animated, completion: completion)
      handled = true

    case .pop:
      self.handlePop(sourceViewController: sourceViewController, animated: animated, completion: completion)
      handled = true

    case .popToRootViewController:
      self.handlePopToRootViewController(sourceViewController: sourceViewController, animated: animated, completion: completion)
      handled = true

    case let .popToViewController(destinationIdentifier):
      guard let destinationViewController = UIApplication.shared.currentViewControllers.first(where: { ($0 as? Routable)?.routeIdentifier == destinationIdentifier }) else {
        fatalError("PopToViewController requested to an unknown destination view controller")
      }

      self.handlePopToViewController(sourceViewController: sourceViewController, destinationViewController: destinationViewController, animated: animated, completion: completion)
      handled = true

    case let .presentModally(vcClosure):
      let vc = vcClosure(context)
      self.handlePresentModally(sourceViewController: sourceViewController, childVC: vc, animated: animated, completion: completion)
      handled = true

    case let .dismissModally(behaviour):
      self.handleDismissModally(sourceViewController: sourceViewController, animated: animated, behaviour: behaviour, completion: completion)
      handled = true

    case let .custom(closure):
      closure(identifier, from, animated, context, completion)
      handled = true

    case let .optionalCustom(closure):
      handled = closure(identifier, from, animated, context, completion)
    }

    return handled
  }
  
  private func handlePush(
    sourceViewController: UIViewController,
    childVC: UIViewController,
    animated: Bool,
    completion: @escaping RoutingCompletion) {
    
    if let navVC = sourceViewController as? UINavigationController {
      navVC.pushViewController(childVC, animated: animated)
      completion()
      return
    }
    
    if let navVC = sourceViewController.navigationController {
      navVC.pushViewController(childVC, animated: animated)
      completion()
      return
    }
    
    fatalError("Push requested on a source view controller that is neither a UINavigationController instance nor part of a UINavigationController's stack")
  }
  
  private func handlePopToRootViewController(
    sourceViewController: UIViewController,
    animated: Bool,
    completion: @escaping RoutingCompletion) {
    
    if let navVC = sourceViewController as? UINavigationController {
      navVC.popToRootViewController(animated: animated)
      completion()
      return
    }
    
    if let navVC = sourceViewController.navigationController {
      navVC.popToRootViewController(animated: animated)
      completion()
      return
    }
    
    fatalError("PopToRootViewController requested on a source view controller that is neither a UINavigationController instance nor part of a UINavigationController's stack")
  }
  
  private func handlePopToViewController(
    sourceViewController: UIViewController,
    destinationViewController: UIViewController,
    animated: Bool,
    completion: @escaping RoutingCompletion) {
    
    if let navVC = sourceViewController as? UINavigationController {
      navVC.popToViewController(destinationViewController, animated: animated)
      completion()
      return
    }
    
    if let navVC = sourceViewController.navigationController {
      navVC.popToViewController(destinationViewController,animated: animated)
      completion()
      return
    }
    
    fatalError("PopToViewController requested on a source view controller that is neither a UINavigationController instance nor part of a UINavigationController's stack")
  }
  
  private func handlePop(
    sourceViewController: UIViewController,
    animated: Bool,
    completion: @escaping RoutingCompletion) {
    
    if let navVC = sourceViewController as? UINavigationController {
      navVC.popViewController(animated: animated)
      completion()
      return
    }
    
    if let navVC = sourceViewController.navigationController {
      navVC.popViewController(animated: animated)
      completion()
      return
    }
    
    fatalError("Pop requested on a source view controller that is neither a UINavigationController instance nor part of a UINavigationController's stack")
  }
  
  private func handlePresentModally(
      sourceViewController: UIViewController,
      childVC: UIViewController,
      animated: Bool,
      completion: @escaping RoutingCompletion) {
    
    sourceViewController.recursivePresent(childVC, animated: animated, completion: completion)
  }
  
  private func handleDismissModally(
    sourceViewController: UIViewController,
    animated: Bool,
    behaviour: NavigationInstruction.ModalDismissBehaviour,
    completion: @escaping RoutingCompletion) {
    
    switch behaviour {
    case .soft:
      sourceViewController.softDismiss(animated: animated, completion: completion)
    
    case .hard:
      sourceViewController.dismiss(animated: animated, completion: completion)
    }
  }
}

/// A RoutableWithConfiguration is a `ViewController` that takes active part to the execution of a navigation action.
///
/// If a screen `listScreen` needs to present `addItemScreen`, the ViewController that is handling `listScreen` must
/// conform to the `RoutableWithConfiguration` protocol.
///
/// When a `Show("addItemScreen")` action is dispatched, the `Navigator` will capture the action and will start
/// finding a RoutableWithConfiguration in the active hierarchy that can handle the action.
/// If the `navigationConfiguration` of `listScreen` will match the `NavigationRequest` of `.show(addItemScreen)`
/// than the Navigator will execute the relative `NavigationInstruction` where you can
/// configure the ViewController to present.
///
/// There are others `NavigationRequest`s and `NavigationInstruction`s that can be used to define the navigation
/// structure of the app.
///
/// In case you need more control, you can always implement the `Routable` protocol yourself and have
/// fine grained control of the implementation of the navigation.
/// In fact, a `RoutableWithConfiguration` and its `navigationConfiguration` are used behind the scenes
/// to implement the `Routable` protocol for you.
///
/// ```swift
///    extension ListViewController: RoutableWithConfiguration {
///
///      // needed by the `Routable` protocol
///      // to identify this ViewController in the hierarchy
///      var routeIdentifier: RouteElementIdentifier {
///        return "listScreen"
///      }
///
///      // the `NavigationRequest`s that this ViewController is handling
///      // with the `NavigationInstruction` to execute
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
///        return [
///          .show("addItemScreen"): .presentModally({ [unowned self] _ in
///            let vc = AddItemViewController(store: self.store)
///            return vc
///          })
///        ]
///    }
/// ```
///
public protocol RoutableWithConfiguration: Routable {
  /// The `NavigationRequest`s this RoutableWithConfiguration will handle
  /// and the `NavigationInstruction`s that will be executed by the `Navigator`.
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] { get }
}

public extension RoutableWithConfiguration where Self: UIViewController {
  
  /// Method of the `Routable` protocol that the `RoutableWithConfiguration` is
  /// implementing automatically looking at the `navigationConfiguration`.
  func show(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    
    for (source, instruction) in self.navigationConfiguration {
      guard source.canHandle(identifier, kind: .show) else {
        continue
      }
      
      let handled = instruction.handle(
        sourceViewController: self,
        identifier: identifier,
        from: from,
        animated: animated,
        context: context,
        completion: completion
      )

      if handled {
        return true
      }
    }
   
    return false
  }
  
  /// Method of the `Routable` protocol that the `RoutableWithConfiguration` is
  /// implementing automatically looking at the `navigationConfiguration`.
  func hide(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    for (source, option) in self.navigationConfiguration {
      guard source.canHandle(identifier, kind: .hide) else {
        continue
      }
      
      let handled = option.handle(
        sourceViewController: self,
        identifier: identifier,
        from: from,
        animated: animated,
        context: context,
        completion: completion
      )

      if handled {
        return true
      }
    }
    
    return false
  }
}
