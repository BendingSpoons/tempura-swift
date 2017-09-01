//
//  AppNavigation.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Tempura

enum Screen: String {
  case tabbar
  case navigation
  case home
  case storyCover
  case storyChat
  case modalTest
}

// HOME
extension HomeViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.home.rawValue
  }
  
  func show(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    // HOME -> STORY COVER
    if identifier == Screen.storyCover.rawValue {
      let sc = StoryCoverViewController(store: self.store)
      sc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(sc, animated: animated)
      completion()
    }
    return true
  }
}

// NAVIGATION
extension RoutableNavigationController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.navigation.rawValue
  }
  
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    self.popViewController(animated: animated)
    completion()
    return true
  }
}

// STORY COVER
extension StoryCoverViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.storyCover.rawValue
  }
}

// MODAL TEST
extension ModalTestViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.modalTest.rawValue
  }
  
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    
    if self.presentingViewController != nil {
      self.tempuraDismiss(animated: true) {
        completion()
      }
      return true
    } else {
      completion()
      return true
    }
  }
}

// TABBAR
extension TabBarController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.tabbar.rawValue
  }
  
  func show(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    
    if identifier == Screen.modalTest.rawValue {
      let vc = ModalTestViewController(store: self.store)
      self.tempuraPresent(vc, animated: animated, completion: { 
        completion()
      })
      return true
    }
    return false
  }
}
