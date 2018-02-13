//
//  NavigationDSL.swift
//  Tempura
//
//  Created by Mauro Bolis on 12/12/2017.
//

import Foundation

public struct NavigationRequest: Hashable {
  public var hashValue: Int
  
  fileprivate enum NavigationKind: Int {
    case show, hide
  }
  
  public static func show<T: RawRepresentable>(_ source: T) -> NavigationRequest where T.RawValue == RouteElementIdentifier {
    return NavigationRequest(source: source.rawValue, kind: .show)
  }
  
  public static func hide<T: RawRepresentable>(_ source: T) -> NavigationRequest where T.RawValue == RouteElementIdentifier {
    return NavigationRequest(source: source.rawValue, kind: .hide)
  }
  
  private let source: String
  private let kind: NavigationKind
  
  private init(source: String, kind: NavigationKind) {
    self.source = source
    self.kind = kind
    self.hashValue = "\(self.source.hashValue)\(self.kind)".hashValue
  }
  
  fileprivate func canHandle(_ identifier: String, kind: NavigationKind) -> Bool {
    return self.source == identifier && kind == self.kind
  }
  
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

public typealias CustomNavigationOptionClosure = (
  _ identifier: RouteElementIdentifier,
  _ from: RouteElementIdentifier,
  _ animated: Bool,
  _ context: Any?,
  _ completion: @escaping RoutingCompletion
) -> Void

public enum NavigationInstruction {
  public enum ModalDismissBehaviour {
    // if the targeted modal is presenting other modals, keep them alive
    case soft
    // while removing the targeted modal, remove also all the modals that it is presenting
    case hard
  }
  // stack navigation
  case push((_ context: Any?) -> UIViewController)
  case pop
  
  // modal navigation
  case presentModally((_ context: Any?) -> UIViewController)
  case dismissModally(behaviour: ModalDismissBehaviour)
  
  // custom
  case custom(CustomNavigationOptionClosure)
  
  func handle(
    sourceViewController: UIViewController,
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) {
    
    
    switch self {
    case let .push(vcClosure):
      let vc = vcClosure(context)
      self.handlePush(sourceViewController: sourceViewController, childVC: vc, animated: animated, completion: completion)
      
    case .pop:
      self.handlePop(sourceViewController: sourceViewController, animated: animated, completion: completion)
      
    case let .presentModally(vcClosure):
      let vc = vcClosure(context)
      self.handlePresentModally(sourceViewController: sourceViewController, childVC: vc, animated: animated, completion: completion)
      
    case let .dismissModally(behaviour):
      self.handleDismissModally(sourceViewController: sourceViewController, animated: animated, behaviour: behaviour, completion: completion)
      
    case let .custom(closure):
      closure(identifier, from, animated, context, completion)
    }
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
    
    sourceViewController.tempuraPresent(childVC, animated: animated, completion: completion)
  }
  
  private func handleDismissModally(
    sourceViewController: UIViewController,
    animated: Bool,
    behaviour: NavigationInstruction.ModalDismissBehaviour,
    completion: @escaping RoutingCompletion) {
    
    switch behaviour {
    case .soft:
      sourceViewController.tempuraDismiss(animated: animated, completion: completion)
    
    case .hard:
      sourceViewController.dismiss(animated: animated, completion: completion)
    }
  }
}

public protocol RoutableWithConfiguration: Routable {
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] { get }
}

public extension RoutableWithConfiguration where Self: UIViewController {
  
  public func show(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    
    for (source, instruction) in self.navigationConfiguration {
      guard source.canHandle(identifier, kind: .show) else {
        continue
      }
      
      instruction.handle(
        sourceViewController: self,
        identifier: identifier,
        from: from,
        animated: animated,
        context: context,
        completion: completion
      )
      
      return true
    }
   
    return false
  }
  
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
      
      option.handle(
        sourceViewController: self,
        identifier: identifier,
        from: from,
        animated: animated,
        context: context,
        completion: completion
      )
      
      return true
    }
    
    return false
  }
}
