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
  
  /*public func presentModally(routeElementID: RouteElementIdentifier, animated: Bool) {
    let change = RouteChange.presentModally(routeElementToPresentModally: routeElementID)
    self.routeDidChange(changes: [change], isAnimated: animated)
    
  }
  
  public func dismissModally(routeElementID: RouteElementIdentifier, animated: Bool) {
    let change = RouteChange.dismissModally(routeElementToDismissModally: routeElementID)
    self.routeDidChange(changes: [change], isAnimated: animated)
  }*/
  
  public func show(_ elementsToShow: [RouteElementIdentifier], animated: Bool) {
    var oldRoute: Route = []
    DispatchQueue.main.sync {
      oldRoute = UIApplication.shared.currentRoute
    }
    let newRoute: Route = oldRoute + elementsToShow
    let routeChanges = Navigator.routingChanges(from: oldRoute, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated)
  }
  
  public func hide(_ elementToHide: RouteElementIdentifier, animated: Bool) {
    var oldRoute: Route = []
    DispatchQueue.main.sync {
      oldRoute = UIApplication.shared.currentRoute
    }
    var newRoute: Route = oldRoute
    
    let i = newRoute.index { element -> Bool in
      return element == elementToHide
    }
    guard let index = i else { return }
    newRoute.removeSubrange(index..<newRoute.count)
    
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
        case .hide( let toHide, let from):
          DispatchQueue.main.async {
            var routables = Array(UIApplication.shared.currentRoutables.reversed())
            
            //start from the toHide, going backward
            let toHideIndex: Int = routables.index(where: { routable -> Bool in
              return routable.routeIdentifier == toHide
            })!

            routables = Array(routables.dropFirst(toHideIndex))
            
            var handled = false
            for routable in routables where !handled {
              handled = routable.hide(identifier: toHide,
                                                from: from,
                                                animated: isAnimated,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("dismissal of the '\(toHide)' is not handled by one of the Routables in the current Route: \(UIApplication.shared.currentRoute.reversed())")
            }
          }
          
        case .show(let toShow, let from):
          DispatchQueue.main.async {
            let routables = UIApplication.shared.currentRoutables.reversed()
            let topViewController = UIApplication.shared.currentViewControllers.last!
            var handled = false
            
            for routable in routables where !handled {
              handled = routable.show(identifier: toShow,
                                                from: from,
                                                animated: isAnimated,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("presentation of the '\(toShow)' is not handled by one of the Routables in the current Route: \(UIApplication.shared.currentRoute)")
            }
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
    
    // case 1 we need to HIDE elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A
    // hide all the elements in the old route that are no more in the new route
    if commonRouteIndex == new.count - 1 {
      for hideIndex in ((commonRouteIndex + 1)..<old.count).reversed() {
        let elementToHide = old[hideIndex]
        let change = RouteChange.hide(elementToHide: elementToHide, from: old[hideIndex - 1])
        routeChanges.append(change)
      }
    }
    // case 2 we need to SHOW elements because we are in a situation like this:
    // OLD: A
    // NEW: A -> B -> C
    // show all the elements in the new route that were not in the old route
    else if commonRouteIndex == old.count - 1 {
      for showIndex in (commonRouteIndex + 1)..<new.count {
        let elementToShow = new[showIndex]
        let change = RouteChange.show(elementToShow: elementToShow, from: old[showIndex - 1])
        routeChanges.append(change)
      }
    }
    // case 3 we need to CHANGE elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A -> D -> E
    // change B with D
    else {
      let change = RouteChange.change(currentElementIdentifier: old[commonRouteIndex], from: old[commonRouteIndex + 1], to: new[commonRouteIndex + 1])
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
    case show(elementToShow: RouteElementIdentifier, from: RouteElementIdentifier)
    
    case hide(elementToHide: RouteElementIdentifier, from: RouteElementIdentifier)
    
    case change(currentElementIdentifier: RouteElementIdentifier, from: RouteElementIdentifier, to: RouteElementIdentifier)
    
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
  
  var currentRoutableIdentifiers: [RouteElementIdentifier] {
    return self.currentRoutables.flatMap {
      return $0.routeIdentifier
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
