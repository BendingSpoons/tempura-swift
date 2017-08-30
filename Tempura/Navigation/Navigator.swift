//
//  Router.swift
//  WeightLoss
//
//  Created by Andrea De Angelis on 30/06/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit
import Katana

public class Navigator {
  public typealias Completion = () -> ()
  //typealias RootInstaller = (UIWindow, Store<S>, RouteElementIdentifier, Completion?) -> ()
  
  private let routingQueue = DispatchQueue(label: "routing queue")
  private var rootInstaller: RootInstaller!
  private var window: UIWindow!
  
  public init() {}
  
  public func setupWith(rootInstaller: RootInstaller, window: UIWindow, rootElementIdentifier: RouteElementIdentifier) {
    self.rootInstaller = rootInstaller
    self.window = window
    self.install(identifier: rootElementIdentifier)
  }
  
  private func install(identifier: RouteElementIdentifier) {
    self.rootInstaller?.installRoot(identifier: identifier, completion: {
      self.window?.makeKeyAndVisible()
    })
  }
  
  public func changeRoute(newRoute: Route, animated: Bool) {
    var oldRoute: Route = []
    DispatchQueue.main.sync {
      oldRoute = UIApplication.shared.currentRoute
    }
    let routeChanges = Navigator.routingChanges(from: oldRoute, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated)
  }
  
  public func presentModally(routeElementID: RouteElementIdentifier, animated: Bool) {
    let change = RouteChange.presentModally(routeElementToPresentModally: routeElementID)
    self.routeDidChange(changes: [change], isAnimated: animated)
    
  }
  
  public func dismissModally(routeElementID: RouteElementIdentifier, animated: Bool) {
    let change = RouteChange.dismissModally(routeElementToDismissModally: routeElementID)
    self.routeDidChange(changes: [change], isAnimated: animated)
  }
  
  public func push(to route: Route, animated: Bool) {
    var oldRoute: Route = []
    DispatchQueue.main.sync {
      oldRoute = UIApplication.shared.currentRoute
    }
    let newRoute: Route = oldRoute + route
    let routeChanges = Navigator.routingChanges(from: oldRoute, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated)
  }
  
  public func pop(animated: Bool) {
    var oldRoute: Route = []
    DispatchQueue.main.sync {
      oldRoute = UIApplication.shared.currentRoute
    }
    var newRoute: Route = oldRoute
    newRoute.removeLast()
    let routeChanges = Navigator.routingChanges(from: oldRoute, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated)
  }
  
  private func routeDidChange(changes: [RouteChange], isAnimated: Bool) {
    
    changes.forEach { routeChange in
      let semaphore = DispatchSemaphore(value: 0)
      // Dispatch all route changes onto this dedicated queue. This will ensure that
      // only one routing action can run at any given time. This is important for using this
      // Router with UI frameworks. Whenever a navigation action is triggered, this queue will
      // block (using semaphore_wait) until it receives a callback from the Routable
      // indicating that the navigation action has completed
      self.routingQueue.async {
        switch routeChange {
        case .pop( let currentRouteElementIdentifier, let toPop):
          DispatchQueue.main.async {
            guard let currentRoutable = UIApplication.shared.routable(for: currentRouteElementIdentifier) else {
              semaphore.signal()
              fatalError("\(currentRouteElementIdentifier) is not a routable and is asked to pop '\(toPop)'")
            }
            guard let viewControllerToPop = UIApplication.shared.routable(for: toPop) as? UIViewController else {
              fatalError("there is no Routable element with identifier '\(toPop)' or the Routable element is not a UIViewController subclass")
            }
            currentRoutable.pop(identifier: toPop, vcToPop: viewControllerToPop, animated: isAnimated, completion: { 
              semaphore.signal()
            })
          }
        case .push(let currentRouteElementIdentifier, let routeElementToPush):
          DispatchQueue.main.async {
            guard let currentRoutable = UIApplication.shared.routable(for: currentRouteElementIdentifier) else {
              semaphore.signal()
              fatalError("\(currentRouteElementIdentifier) is not a routable and is asked to push '\(routeElementToPush)'")
            }
            let _ = currentRoutable.push(identifier: routeElementToPush, animated: isAnimated, completion: {
              semaphore.signal()
            })
          }
        case .change(let currentRouteElementIdentifier, let from, let to):
          DispatchQueue.main.async {
            guard let currentRoutable = UIApplication.shared.routable(for: currentRouteElementIdentifier) else {
              semaphore.signal()
              fatalError("\(currentRouteElementIdentifier) is not a routable and is asked to change to '\(to)'")
            }
            let _ = currentRoutable.change(from: from, to: to, animated: isAnimated, completion: {
              semaphore.signal()
            })
          }
        case .presentModally(routeElementToPresentModally: let identifier):
          DispatchQueue.main.async {
            let routables = UIApplication.shared.currentRoutables.reversed()
            var handled = false
            
            for routable in routables where !handled {
              handled = routable.presentModally(modal: identifier,
                                                animated: isAnimated,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("modal presentation of the '\(identifier)' is not handled by one of the Routables in the current Route: \(UIApplication.shared.currentRoute)")
            }
          }
        case .dismissModally(routeElementToDismissModally: let identifier):
          DispatchQueue.main.async {
            let routables = UIApplication.shared.currentRoutables.reversed()
            guard let viewControllerToDismiss = UIApplication.shared.routable(for: identifier) as? UIViewController else {
              fatalError("there is no Routable element with identifier '\(identifier)' or the Routable element is not a UIViewController subclass")
            }
            var handled = false
            
            for routable in routables where !handled {
              handled = routable.dismissModally(identifier: identifier,
                                                vcToDismiss: viewControllerToDismiss,
                                                animated: isAnimated,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("modal dismissal of the '\(identifier)' is not handled by one of the Routables in the current Route: \(UIApplication.shared.currentRoute)")
            }
          }
        case .rootChange(_, let to):
          DispatchQueue.main.async {
            self.rootInstaller.installRoot(identifier: to) {
              semaphore.signal()
            }
          }
        }
        let waitUntil = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        let result = semaphore.wait(timeout: waitUntil)
        
        if case .timedOut = result {
          print("stuck waiting for routing to complete. Ensure that you called the completion handler in each Routable element")
        }
      }
    }
  }
  
  private static func routingChanges(from old: Route, new: Route) -> [RouteChange] {
    var routeChanges: [RouteChange] = []
    
    //find the common route between two routes
    let commonRouteIndex = Navigator.commonRouteIndexBetween(old: old, new: new)
    // if the common route is including all the old and the new Route there is nothing to do
    if commonRouteIndex == old.count - 1 && commonRouteIndex == new.count - 1 {
      return []
    }
    
    /// if there is no route in common, ask the UIApplication to handle that
    if commonRouteIndex < 0 {
      let change = RouteChange.rootChange(from: old.first!, to: new.first!)
      return [change]
    }
    
    // case 1 we need to POP elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A
    // pop all the elements in the old route that are no more in the new route
    if commonRouteIndex == new.count - 1 {
      for popIndex in ((commonRouteIndex + 1)..<old.count).reversed() {
        let elementToPop = old[popIndex]
        let change = RouteChange.pop(currentRouteElementIdentifier: old[popIndex - 1], routeElementToPop: elementToPop)
        routeChanges.append(change)
      }
    }
      // case 2 we need to PUSH element because we are in a situation like this:
      // OLD: A
      // NEW: A -> B -> C
      // push all the elements in the new route that were not in the old route
    else if commonRouteIndex == old.count - 1 {
      for pushIndex in (commonRouteIndex + 1)..<new.count {
        let elementToPush = new[pushIndex]
        let change = RouteChange.push(currentRouteElementIdentifier: old[pushIndex - 1], routeElementToPush: elementToPush)
        routeChanges.append(change)
      }
    }
      // case 3 we need to CHANGE elements because we are in a situation like this:
      // OLD: A -> B -> C
      // NEW: A -> D -> E
      // change B with D
    else {
      let change = RouteChange.change(currentRouteElementIdentifier: old[commonRouteIndex], from: old[commonRouteIndex + 1], to: new[commonRouteIndex + 1])
      routeChanges.append(change)
    }
    return routeChanges
  }
  
  private static func commonRouteIndexBetween(old: Route, new: Route) -> Int {
    var commonRouteIndex: Int = -1
    var checkingCommonRouteIndex: Int = 0
    while checkingCommonRouteIndex < old.count && checkingCommonRouteIndex < new.count &&
      new[checkingCommonRouteIndex] == old[checkingCommonRouteIndex] {
        commonRouteIndex = checkingCommonRouteIndex
        checkingCommonRouteIndex += 1
    }
    return commonRouteIndex
  }
  
  enum RouteChange {
    case push(currentRouteElementIdentifier: RouteElementIdentifier, routeElementToPush: RouteElementIdentifier)
    
    case pop(currentRouteElementIdentifier: RouteElementIdentifier, routeElementToPop: RouteElementIdentifier)
    
    case change(currentRouteElementIdentifier: RouteElementIdentifier, from: RouteElementIdentifier, to: RouteElementIdentifier)
    
    case presentModally(routeElementToPresentModally: RouteElementIdentifier)
    
    case dismissModally(routeElementToDismissModally: RouteElementIdentifier)
    
    case rootChange(from: RouteElementIdentifier, to: RouteElementIdentifier)
  }
}

extension UIApplication {
  var currentRoute: Route {
    let controllers = self.currentViewControllers
    let route: Route = controllers.flatMap {
      return ($0 as? Routable)?.routeIdentifier ?? String(describing: type(of:$0))
    }
    return route
  }
}

extension UIApplication {
  var currentRoutables: [Routable] {
    return self.currentViewControllers.flatMap {
      return $0 as? Routable
    }
  }
}

extension UIApplication {
  func routable(for identifier: RouteElementIdentifier) -> Routable? {
    let routables = self.currentRoutables.reversed()
    return routables.first(where: { routable -> Bool in
      routable.routeIdentifier == identifier
    })
  }
}

/// this method returs the hierarchy of the UIViewControllers in the visible stack
/// using the RouteInspectable protocol
/// if you introduce a custom UIViewController like for instance a `SideMenuViewController`
/// you need it to conform to the RouteInspectable protocol
extension UIApplication {
  var currentViewControllers: [UIViewController] {
    guard let bottomViewController = UIApplication.shared.keyWindow?.rootViewController else { return [] }
    var controllers: [UIViewController] = []
    var vcs: [UIViewController] = [bottomViewController]
    while !vcs.isEmpty {
      controllers.append(contentsOf: vcs)
      vcs = vcs.last?.nextRouteControllers ?? []
    }
    return controllers
  }
}

/// define a way to inspect a UIViewController asking for the next visible UIViewController in the visible stack
protocol RouteInspectable: class {
  var nextRouteControllers: [UIViewController] { get }
}

/// conformance of the UINavigationController to the RouteInspectable protocol
/// in a UINavigationController the next visible controller is the `topViewController`
extension UINavigationController {
  override var nextRouteControllers: [UIViewController] {
    return self.viewControllers
  }
}

/// conformance of the UITabBarController to the RouteInspectable protocol
/// in a UITabBarController the next visible controller is the `selectedViewController`
extension UITabBarController {
  override var nextRouteControllers: [UIViewController] {
    guard let selected = self.selectedViewController else { return [] }
    return [selected]
  }
}

/// conformance of the UIViewController to the RouteInspectable protocol
/// in a UIViewController the next visible controller is the `presentedViewController` if != nil
/// otherwise there is no next UIViewController in the visible stack
extension UIViewController: RouteInspectable {
  var nextRouteControllers: [UIViewController] {
    guard let presented = self.presentedViewController else { return [] }
    return [presented]
  }
}
