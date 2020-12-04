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
import Hydra

/// Main class that is handling the navigation in a Tempura app.
///
/// ## Overview
/// When it comes to creating a complex app, the way you handle the navigation between
/// different screens is an important factor on the final result.
///
/// We believe that relying on the native iOS navigation system, even in a Redux-like
/// environment like Katana, is the right choice for our stack, because:
///
/// - there is no navigation code to write and maintain just to mimic the way
/// native navigation works
///
/// - native navigation gestures will come for free and will stay up to date
/// with new iOS releases
///
/// - the app will feel more "native"
///
/// For these reasons we found a way to reconcile the redux-like world of Katana
/// with the imperative world of the iOS navigation.
///
/// ## The Routable protocol
/// If a Screen (read ViewController) takes an active part on the navigation
/// (i.e. needs to present another screen) it must conform to the `RoutableWithConfiguration` protocol.
///
/// ```swift
///    protocol RoutableWithConfiguration: Routable {
///
///      var routeIdentifier: RouteElementIdentifier { get }
///
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] { get }
///    }
/// ```
///
/// ```swift
///    typealias RouteElementIdentifier = String
/// ```
///
/// Each `RoutableWithConfiguration` can be asked by the Navigator navigation to
/// perform a specific navigation task (like present another ViewController)
/// based on the navigation action (`Show`, `Hide`) you dispatch.
/// ## The route
/// A `Route` is an array that represents a navigation path to a specific screen.
/// ```swift
///    typealias Route = [RouteElementIdentifier]
/// ```
/// ## How the navigation works
/// Suppose we have a current `Route` like ["screenA", "screenB"] (being "screenB")
/// the topmost ViewController/RoutableWithConfiguration in the visible hierarchy.
///
/// Tempura will expose two main navigation actions:
/// ### Show
/// ```swift
///    Show("screenC", animated: true)
/// ```
///
/// When this action is dispatched, the `Navigator` will ask "screenB" (the topmost
/// `RoutableWithConfiguration` to handle that action, looking at its
/// `navigationConfiguration`).
///
/// In order to allow "screenB" to present "screenC", we need to add a `NavigationRequest`
/// inside the `navigationConfiguration` of "screenB" that will match the `Show("screenC")` action
/// with a `.show("screenC")` `NavigationRequest`.
///
/// ```swift
///    extension ScreenB: RoutableWithConfiguration {
///
///      // needed by the `Routable` protocol
///      // to identify this ViewController in the hierarchy
///      var routeIdentifier: RouteElementIdentifier {
///        return "screenB"
///      }
///
///      // the `NavigationRequest`s that this ViewController is handling
///      // with the `NavigationInstruction` to execute
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
///        return [
///          .show("screenC"): .presentModally({ [unowned self] _ in
///            let vc = ScreenC(store: self.store)
///            return vc
///          })
///        ]
///    }
/// ```
///
/// Inside the `.presentModally` NavigationInstruction, we create and return the ViewController
/// that is implementing the "screenC".
/// This will be used by the `Navigator` to call the appropriate UIKit navigation action (
/// a `UIViewController.present(:animated:completion:)` in this case).
///
/// If the Navigator will not find a matching NavigationRequest in the navigationConfiguration of
/// "screenB", it will ask to the next RoutableWithConfiguration in the visible hierarchy,
/// in this case "screenA". If nobody is matching that NavigationRequest, a fatalError is thrown.
/// ### Hide
/// Same will happen when a `Hide` function is dispatched.
/// ```swift
///    Hide("screenC", animated: true)
/// ```
/// Looking at the current `Route` ["screenA", "screenB", "screenC"], the Navigator will ask the
/// topmost RoutableWithConfiguration ("screenC" in this case) to match for a
/// `.hide("screenC")` `NavigationRequest`.
///
/// Again, if we want "screenC" to be responsible for dismissing itself, we just need to implement
/// the matching `NavigationRequest` in the `navigationConfiguration`:
///
/// ```swift
///    extension ScreenC: RoutableWithConfiguration {
///
///      // needed by the `Routable` protocol
///      // to identify this ViewController in the hierarchy
///      var routeIdentifier: RouteElementIdentifier {
///        return "screenC"
///      }
///
///      // the `NavigationRequest`s that this ViewController is handling
///      // with the `NavigationInstruction` to execute
///      var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
///        return [
///          .hide("screenC"): .dismissModally(behaviour: .hard)
///        ]
///    }
/// ```
/// If the Navigator will not find a matching NavigationRequest in the navigationConfiguration of
/// "screenC", it will ask to the next RoutableWithConfiguration in the visible hierarchy,
/// in this case "screenB". If nobody is matching that NavigationRequest, a fatalError is thrown.
///
/// ## Initializing the navigation
/// In order to use the navigation system you need to start the Navigator
/// (typically in your AppDelegate) using the `start(using:in:at:)` method.
/// In this method you need to specify a `RootInstaller`
/// and a starting screen.
/// The RootInstaller (typically your AppDelegate) will be responsible to handle the installation
/// of the screen you specified before.
///
/// Doing so, the Navigator will call the `RooInstaller.installRoot(identifier:context:completion:)`
/// method that will handle the setup of the screen to be shown.
///
/// ```swift
///    class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {
///
///      func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
///        ...
///        // setup the root of the navigation
///        // this is done by invoking this method (and not in the init of the navigator)
///        // because the navigator is instantiated by the Store.
///        // this in turn will invoke the `installRootMethod` of the rootInstaller (self)
///        navigator.start(using: self, in self.window, at: "screenA")
///        return true
///      }
///
///      // install the root of the app
///      // this method is called by the navigator when needed
///      // you must call the `completion` callback when the navigation has been completed
///      func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) -> Bool {
///        let vc = ScreenAViewController(store: self.store)
///        self.window.rootViewController = vc
///        completion()
///        return true
///      }
///    }

public class Navigator {
  /// Completion closure typealias, needed by the navigator to know when a navigation has been handled.
  public typealias Completion = () -> ()
  
  private let routingQueue = DispatchQueue(label: "routing queue")
  private var rootInstaller: RootInstaller!
  private var window: UIWindow!

  /// Initializes and return a Navigator.
  public init() {}
  /// Start the navigator.
  ///
  /// In order to use the navigation system, you need to start the navigator
  /// specifying a `RootInstaller` and the first screen you want to install.
  /// ```swift
  ///    class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {
  ///
  ///      func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
  ///        ...
  ///        // setup the root of the navigation
  ///        // this is done by invoking this method (and not in the init of the navigator)
  ///        // because the navigator is instantiated by the Store.
  ///        // this in turn will invoke the `installRootMethod` of the rootInstaller (self)
  ///        navigator.start(using: self, in self.window, at: "screenA")
  ///        return true
  ///      }
  ///
  ///      // install the root of the app
  ///      // this method is called by the navigator when needed
  ///      // you must call the `completion` callback when the navigation has been completed
  ///      func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) -> Bool {
  ///        let vc = ScreenAViewController(store: self.store)
  ///        self.window.rootViewController = vc
  ///        completion()
  ///        return true
  ///      }
  ///    }
  public func start(using rootInstaller: RootInstaller,
                    in window: UIWindow,
                    at rootElementIdentifier: RouteElementIdentifier) {
    self.rootInstaller = rootInstaller
    self.window = window
    self.install(identifier: rootElementIdentifier, context: nil)
  }
  /// Generic version of the same method.
  public func start<K: RawRepresentable>(using rootInstaller: RootInstaller,
                                         in window: UIWindow,
                                         at rootElementIdentifier: K) where K.RawValue == RouteElementIdentifier {
    self.start(using: rootInstaller, in: window, at: rootElementIdentifier.rawValue)
  }
  
  private func install(identifier: RouteElementIdentifier, context: Any?) {
    self.rootInstaller?.installRoot(identifier: identifier, context: context, completion: {
      self.window?.makeKeyAndVisible()
    })
  }
  
  func changeRoute(newRoute: Route, animated: Bool, context: Any?) -> Promise<Void> {
    let promise = Promise<Void>(in: .background) { resolve, reject, _ in
      let oldRoutables = UIApplication.shared.currentRoutables
      let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute)
      
      self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context) {
        resolve(())
      }
    }
    return promise
  }
  
  @discardableResult
  func show(_ elementsToShow: [RouteElementIdentifier], animated: Bool, context: Any?) -> Promise<Void> {
    let promise = Promise<Void>(in: .background) { resolve, reject, _ in
      let oldRoutables = UIApplication.shared.currentRoutables
      let oldRoute = oldRoutables.map { $0.routeIdentifier }
      let newRoute: Route = oldRoute + elementsToShow
      let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute)
      
      self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context) {
        resolve(())
      }
    }
    return promise
  }
  
  @discardableResult
  func hide(_ elementToHide: RouteElementIdentifier, animated: Bool, context: Any?, atomic: Bool = false) -> Promise<Void> {
    let promise = Promise<Void>(in: .background) { resolve, reject, _ in
      let oldRoutables = UIApplication.shared.currentRoutables
      let oldRoute = oldRoutables.map { $0.routeIdentifier }
      
      guard let start = oldRoute.indices.reversed().first(where: { oldRoute[$0] == elementToHide }) else {
        resolve(())
        return
      }
      
      let newRoute = Array(oldRoute[0..<start])
      
      let routeChanges = Navigator.routingChanges(from: oldRoutables, new: newRoute, atomic: atomic)
      
      self.routeDidChange(changes: routeChanges, isAnimated: animated, context: context) {
        resolve(())
      }
    }
    return promise
  }
  
  /// extract rounting changes to go from `old` to `new`.
  private static func routingChanges(from old: [Routable], new: Route, atomic: Bool = false) -> [RouteChange] {
    var routeChanges: [RouteChange] = []
    
    //find the common route between two routes
    let commonRouteIndex = Navigator.commonRouteIndexBetween(old: old, new: new)
    // if the common route is including all the old and the new Route there is nothing to do
    if commonRouteIndex == old.count - 1 && commonRouteIndex == new.count - 1 {
      return []
    }
    
    // if there is no route in common, ask the UIApplication to handle that
    if commonRouteIndex < 0 {
      let change = RouteChange.rootChange(from: old.first!.routeIdentifier, to: new.first!)
      return [change]
    }
    
    // case 1 we need to HIDE elements because we are in a situation like this:
    // OLD: A -> B -> C
    // NEW: A
    if commonRouteIndex == new.count - 1 {
      // hide all the elements in the old route that are no more in the new route
      // routablesToRemove = [C, B], indexes to remove = [2 , 1]
      if atomic {
        let elementToHide = old[commonRouteIndex + 1]
        let change = RouteChange.hide(routable: elementToHide)
        return [change]
      }
      
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
  
  // execute all the `changes` one at a time, asking to the routables on the hierarchy
  private func routeDidChange(changes: [RouteChange], isAnimated: Bool, context: Any? = nil, completion: (() -> ())? = nil) {
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

            guard let indexToHide = routables.firstIndex(where: {
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
              handled = self.rootInstaller.installRoot(identifier: toShow,
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
            let handled = self.rootInstaller.installRoot(identifier: to, context: context) {
              semaphore.signal()
            }
            if !handled { fatalError("installRoot of identifier: '\(to)' is not handled by the rootInstaller") }
          }
        }
        let result = semaphore.wait(timeout: .now() + .seconds(3))
        
        if case .timedOut = result {
          print("stuck waiting for routing to complete. Ensure that you called the completion handler in each Routable element")
        }
        completion?()
      }
    }
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
    let route: Route = controllers.compactMap {
      return ($0 as? Routable)?.routeIdentifier ?? String(describing: type(of: $0))
    }
    return route
  }
}

public extension UIApplication {
  /// The routables in the visible hierarchy.
  var currentRoutables: [Routable] {
    return self.currentViewControllers.compactMap {
      return $0 as? Routable
    }
  }
  /// The indentifiers of the routables in the visible hierarchy.
  var currentRoutableIdentifiers: [RouteElementIdentifier] {
    return self.currentRoutables.compactMap {
      return $0.routeIdentifier
    }
  }
}

extension UIApplication {
  /// This method returs the hierarchy of the UIViewControllers in the visible stack
  /// using the RouteInspectable protocol.
  /// If you introduce a custom UIViewController like for instance a `SideMenuViewController`
  /// you need it to conform to the RouteInspectable protocol.
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

/// Defines a way to inspect a UIViewController asking for the next visible UIViewController in the visible stack.
public protocol CustomRouteInspectables: class {
  /// Next view controllers to  be inspected by the router
  var nextRouteControllers: [UIViewController] { get }
}

public protocol RouteInspectable: class {
  /// Next view controller to  be inspected by the router
  var nextRouteController: UIViewController? { get }
}

/// Conformance of the UINavigationController to the RouteInspectable protocol.
/// In a UINavigationController the next visible controller is the `topViewController`.
extension UINavigationController: CustomRouteInspectables {
  public var nextRouteControllers: [UIViewController] {
  var controllers: [UIViewController] = self.viewControllers
   if let presentedVC = self.presentedViewController {
     controllers.append(presentedVC)
   }
   return controllers
  }
}

/// Conformance of the UITabBarController to the RouteInspectable protocol.
/// In a UITabBarController the next visible controller is the `selectedViewController`.
extension UITabBarController: CustomRouteInspectables {
  public var nextRouteControllers: [UIViewController] {
    var controllers: [UIViewController] = []
    
    if let selectedVC = self.selectedViewController {
      controllers.append(selectedVC)
    }
    
    if let presentedVC = self.presentedViewController {
      controllers.append(presentedVC)
    }

    return controllers
  }
}

/// Conformance of the UIViewController to the RouteInspectable protocol.
/// In a UIViewController the next visible controller is the `presentedViewController` if != nil
/// otherwise there is no next UIViewController in the visible stack.
extension UIViewController: RouteInspectable {
  public var nextRouteController: UIViewController? {
    return self.presentedViewController
  }
}
