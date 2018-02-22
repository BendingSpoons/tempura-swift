//
//  RootInstaller.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation

/// The object responsible to handle the installation of the first screen
/// of the navigation.
///
/// The `Navigator` will call the `RooInstaller.installRoot(identifier:context:completion:)`
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
///      func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) {
///        let vc = ScreenAViewController(store: self.store)
///        self.window.rootViewController = vc
///        completion()
///      }
///    }
public protocol RootInstaller {
  /// Called by the `Navigator` when it's time to install the root of the navigation
  ///
  /// ```swift
  ///      // install the root of the app
  ///      // this method is called by the navigator when needed
  ///      // you must call the `completion` callback when the navigation has been completed
  ///      func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) {
  ///        let vc = ScreenAViewController(store: self.store)
  ///        self.window.rootViewController = vc
  ///        completion()
  ///      }
  /// ```
  func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: Navigator.Completion)
}
