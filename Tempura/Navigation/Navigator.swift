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
    self.install(identifier: rootElementIdentifier, context: nil)
  }
  
  private func install(identifier: RouteElementIdentifier, context: Any?) {
    self.rootInstaller?.installRoot(identifier: identifier, context: context, completion: {
      self.window?.makeKeyAndVisible()
    })
  }
  
  public func changeRoute(newRoute: Route, animated: Bool, context: Any?) {
    let oldRoutables = UIApplication.shared.currentRoutables
    let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context)
  }
  
  public func show(_ elementsToShow: [RouteElementIdentifier], animated: Bool, context: Any?) {
    let oldRoutables = UIApplication.shared.currentRoutables
    let oldRoute = oldRoutables.map { $0.routeIdentifier }
    let newRoute: Route = oldRoute + elementsToShow
    let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context)
  }
  
  public func hide(_ elementToHide: RouteElementIdentifier, animated: Bool, context: Any?) {
    let oldRoutables = UIApplication.shared.currentRoutables
    let oldRoute = oldRoutables.map { $0.routeIdentifier }
    
    guard let start = oldRoute.indices.reversed().first(where: { oldRoute[$0] == elementToHide }) else {
      return
    }
    
    let newRoute = Array(oldRoute[0..<start])
    
    let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute)
    
    self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context)
  }
  
  private func routeDidChange(changes: [RouteChange], isAnimated: Bool, context: Any? = nil) {
    changes.forEach { routeChange in
      let semaphore = DispatchSemaphore(value: 0)
      // Dispatch all route changes onto this dedicated queue. This will ensure that
      // only one routing action can run at any given time. This is important for using this
      // Router with UI frameworks. Whenever a navigation action is triggered, this queue will
      // block (using semaphore_wait) until it receives a callback from the Routable
      // indicating that the navigation action has completed
      self.routingQueue.async {
        switch routeChange {
        case .hide( let toHide):
          DispatchQueue.main.async {
            
            let routables = UIApplication.shared.currentRoutables
            
            guard let indexToHide = routables.index(where: {
              $0 === toHide
            }) else { semaphore.signal(); return }
            
            let askTo = Array(routables[0...indexToHide].reversed())
            let from = routables[indexToHide - 1].routeIdentifier
            
            var handled = false
            for routable in askTo where !handled {
              guard !handled else { break }
              handled = routable.hide(identifier: toHide.routeIdentifier,
                                                from: from,
                                                animated: isAnimated,
                                                context: context,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("dismissal of the '\(toHide)' is not handled by any of the Routables in the current Route: \(UIApplication.shared.currentRoute.reversed())")
            }
          }
          
        case .show(let toShow):
          DispatchQueue.main.async {
            
            let routables = UIApplication.shared.currentRoutables
            let askTo = routables.reversed()

            let from = routables.last!.routeIdentifier
            
            var handled = false
            for routable in askTo where !handled {
              handled = routable.show(identifier: toShow,
                                                from: from,
                                                animated: isAnimated,
                                                context: context,
                                                completion: {
                                                  semaphore.signal()
              })
            }
            
            if !handled {
              semaphore.signal()
              fatalError("presentation of the '\(toShow)' is not handled by any of the Routables in the current Route: \(UIApplication.shared.currentRoute)")
            }
          }
        case .change(let currentRoutable, let from, let to):
          DispatchQueue.main.async {
            let _ = currentRoutable.change(from: from,
                                           to: to,
                                           animated: isAnimated,
                                           context: context,
                                           completion: {
              semaphore.signal()
            })
          }
        case .rootChange(_, let to):
          DispatchQueue.main.async {
            self.rootInstaller.installRoot(identifier: to, context: context) {
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
  
  private static func routingChanges(from old: [Routable], new: Route) -> [RouteChange] {
    var routeChanges: [RouteChange] = []
    
    //find the common route between two routes
    let commonRouteIndex = Navigator.commonRouteIndexBetween(old: old, new: new)
    // if the common route is including all the old and the new Route there is nothing to do
    if commonRouteIndex == old.count - 1 && commonRouteIndex == new.count - 1 {
      return []
    }
    
    /// if there is no route in common, ask the UIApplication to handle that
    if commonRouteIndex < 0 {
      let change = RouteChange.rootChange(from: old.first!.routeIdentifier, to: new.first!)
      return [change]
    }
    
    // case 1 we need to HIDE elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A
    // hide all the elements in the old route that are no more in the new route
    if commonRouteIndex == new.count - 1 {
      // routablesToRemove = [C, B], indexes to remove = [2 , 1]
      let indexesToRemove = ((commonRouteIndex + 1)..<old.count).reversed()
      
      for hideIndex in indexesToRemove {
        let elementToHide = old[hideIndex]
        let change = RouteChange.hide(routable: elementToHide)
        routeChanges.append(change)
      }
    }
    // case 2 we need to SHOW elements because we are in a situation like this:
    // OLD: A
    // NEW: A -> B -> C
    // show all the elements in the new route that were not in the old route
    else if commonRouteIndex == old.count - 1 {
      let indexesToAdd = (commonRouteIndex + 1)..<new.count
      
      for showIndex in indexesToAdd {
        let elementToShow = new[showIndex]
        let change = RouteChange.show(elementToShow: elementToShow)
        routeChanges.append(change)
      }
    }
    // case 3 we need to CHANGE elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A -> D -> E
    // change B with D
    else {
      let change = RouteChange.change(routable: old[commonRouteIndex], from: old[commonRouteIndex + 1].routeIdentifier, to: new[commonRouteIndex + 1])
      routeChanges.append(change)
    }
    return routeChanges
  }
  
  private static func commonRouteIndexBetween(old: [Routable], new: Route) -> Int {
    var commonRouteIndex: Int = -1
    var checkingCommonRouteIndex: Int = 0
    while checkingCommonRouteIndex < old.count && checkingCommonRouteIndex < new.count &&
      new[checkingCommonRouteIndex] == old[checkingCommonRouteIndex].routeIdentifier {
        commonRouteIndex = checkingCommonRouteIndex
        checkingCommonRouteIndex += 1
    }
    return commonRouteIndex
  }
  
  enum RouteChange {
    // note that show cannot contain the ask array (like hide) because it needs to be computed at the momento
    // of the execution because in case of multiple show, the new routables are not in the window yet
    case show(elementToShow: RouteElementIdentifier)
    
    case hide(routable: Routable)
    
    case change(routable: Routable, from: RouteElementIdentifier, to: RouteElementIdentifier)
    
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

public extension UIApplication {
  var currentRoutables: [Routable] {
    return self.currentViewControllers.flatMap {
      return $0 as? Routable
    }
  }
  
  public var currentRoutableIdentifiers: [RouteElementIdentifier] {
    return self.currentRoutables.flatMap {
      return $0.routeIdentifier
    }
  }
}

/// this method returs the hierarchy of the UIViewControllers in the visible stack
/// using the RouteInspectable protocol
/// if you introduce a custom UIViewController like for instance a `SideMenuViewController`
/// you need it to conform to the RouteInspectable protocol
extension UIApplication {
  var currentViewControllers: [UIViewController] {
    
    let findViewControllers: () -> [UIViewController] = {
      guard let bottomViewController = UIApplication.shared.keyWindow?.rootViewController else { return [] }
      var controllers: [UIViewController] = []
      var vcs: [UIViewController] = [bottomViewController]
      while !vcs.isEmpty {
        controllers.append(contentsOf: vcs)
        if let vc = vcs.last {
          if let cri = vc as? CustomRouteInspectables {
            vcs = cri.nextRouteControllers
          } else if let nvc = vc.nextRouteController {
            vcs = [nvc]
          } else {
            vcs = []
          }
        }
      }
      return controllers
    }
    
    if !Thread.isMainThread {
      var vcs: [UIViewController] = []
      DispatchQueue.main.sync {
        vcs = findViewControllers()
      }
      return vcs
    } else {
      return findViewControllers()
    }
  }
}

/// define a way to inspect a UIViewController asking for the next visible UIViewController in the visible stack
protocol CustomRouteInspectables: class {
  var nextRouteControllers: [UIViewController] { get }
}

protocol RouteInspectable: class {
  var nextRouteController: UIViewController? { get }
}

/// conformance of the UINavigationController to the RouteInspectable protocol
/// in a UINavigationController the next visible controller is the `topViewController`
extension UINavigationController: CustomRouteInspectables {
 var nextRouteControllers: [UIViewController] {
    return self.viewControllers
  }
}

/// conformance of the UITabBarController to the RouteInspectable protocol
/// in a UITabBarController the next visible controller is the `selectedViewController`
extension UITabBarController: CustomRouteInspectables {
  var nextRouteControllers: [UIViewController] {
    return self.selectedViewController.flatMap { [$0] } ?? []
  }
}

/// conformance of the UIViewController to the RouteInspectable protocol
/// in a UIViewController the next visible controller is the `presentedViewController` if != nil
/// otherwise there is no next UIViewController in the visible stack
extension UIViewController: RouteInspectable {
  var nextRouteController: UIViewController? {
    return self.presentedViewController
  }
}
