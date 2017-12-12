//
//  NavigationDSL.swift
//  Tempura
//
//  Created by Mauro Bolis on 12/12/2017.
//

import Foundation

public struct NavigationSource: Hashable {
  public var hashValue: Int
  
  fileprivate enum NavigationType: Int {
    case show, hide
  }
  
  public static func show<T: RawRepresentable>(_ source: T) -> NavigationSource where T.RawValue == RouteElementIdentifier {
    return NavigationSource(source: source.rawValue, navigationType: .show)
  }
  
  public static func hide<T: RawRepresentable>(_ source: T) -> NavigationSource where T.RawValue == RouteElementIdentifier {
    return NavigationSource(source: source.rawValue, navigationType: .hide)
  }
  
  private let source: String
  private let navigationType: NavigationType
  
  private init(source: String, navigationType: NavigationType) {
    self.source = source
    self.navigationType = navigationType
    self.hashValue = "\(self.source.hashValue)\(self.navigationType)".hashValue
  }
  
  fileprivate func canHandle(_ identifier: String, type: NavigationType) -> Bool {
    return self.source == identifier && type == self.navigationType
  }
  
  public static func == (lhs: NavigationSource, rhs: NavigationSource) -> Bool {
    if lhs.navigationType != rhs.navigationType {
      return false
    }
    
    if lhs.source != rhs.source {
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

public enum NavigationOption {
  public enum ModalDismissBehaviour {
    case tempura
    case uikit
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
    behaviour: NavigationOption.ModalDismissBehaviour,
    completion: @escaping RoutingCompletion) {
    
    switch behaviour {
    case .tempura:
      sourceViewController.tempuraDismiss(animated: animated, completion: completion)
    
    case .uikit:
      sourceViewController.dismiss(animated: animated, completion: completion)
    }
  }
}

public protocol RoutableWithConfiguration: Routable {
  var navigationConfiguration: [NavigationSource: NavigationOption] { get }
}

public extension RoutableWithConfiguration where Self: UIViewController {
  
  public func show(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    
    for (source, option) in self.navigationConfiguration {
      guard source.canHandle(identifier, type: .show) else {
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
  
  func hide(
    identifier: RouteElementIdentifier,
    from: RouteElementIdentifier,
    animated: Bool,
    context: Any?,
    completion: @escaping RoutingCompletion) -> Bool {
    
    for (source, option) in self.navigationConfiguration {
      guard source.canHandle(identifier, type: .hide) else {
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
