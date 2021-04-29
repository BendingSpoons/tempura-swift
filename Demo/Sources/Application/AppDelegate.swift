//
//  AppDelegate.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Katana
import Tempura
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {
  var window: UIWindow?
  var store: Store<AppState, DependenciesContainer>! // swiftlint:disable:this implicitly_unwrapped_optional

  func application(
    // swiftlint:disable:next discouraged_optional_collection
    _: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.store = Store<AppState, DependenciesContainer>()

    self.window = UIWindow(frame: UIScreen.main.bounds)

    /// setup the root of the navigation
    /// this is done by invoking this method (and not in the init of the navigator)
    /// because the navigator is instantiated by the Store.
    /// this in turn will invoke the `installRootMethod` of the rootInstaller (self)
    // swiftlint:disable:next implicitly_unwrapped_optional
    let navigator: Navigator! = self.store!.dependencies.navigator // swiftlint:disable:this force_unwrapping
    navigator.start(using: self, in: self.window!, at: Screen.list) // swiftlint:disable:this force_unwrapping

    return true
  }

  /// install the root of the app
  /// this method is called by the navigator when needed
  func installRoot(identifier: RouteElementIdentifier, context _: Any?, completion: () -> Void) -> Bool {
    if identifier == Screen.list.rawValue {
      let listViewController = ListViewController(store: self.store, localState: ListLocalState())
      self.window?.rootViewController = listViewController
      completion()
      return true
    }
    return false
  }

  func applicationWillResignActive(_: UIApplication) {}

  func applicationDidEnterBackground(_: UIApplication) {}

  func applicationWillEnterForeground(_: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on
    // entering the background.
  }

  func applicationDidBecomeActive(_: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was
    // previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
