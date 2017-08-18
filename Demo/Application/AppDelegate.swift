//
//  AppDelegate.swift
//  Test
//
//  Created by Andrea De Angelis on 23/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import UIKit
import Katana
import Tempura

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {

  var window: UIWindow?
  var store: Store<AppState>?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.store = Store<AppState>(middleware: [], dependencies: DependenciesContainer.self)
    // set this store as the default for the Tempura ViewControllers
    Tempura.store = self.store
    // set this helper to access dependencies globally in the app
    App.dependencies = self.store!.dependencies as? DependenciesContainer
    // Override point for customization after application launch.
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.installRoot(identifier: Screen.tabbar.rawValue) {
      self.window?.makeKeyAndVisible()
    }

    LiveReloadManager.shared.liveReloadViews(in: self.window!)
    
    return true
  }

  func installRoot(identifier: RouteElementIdentifier, completion: () -> ()) {
    if identifier == Screen.tabbar.rawValue {
      let mainViewController = TabBarController(store: self.store!)
      self.window?.rootViewController = mainViewController
      completion()
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {}

  func applicationDidEnterBackground(_ application: UIApplication) {}

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}
