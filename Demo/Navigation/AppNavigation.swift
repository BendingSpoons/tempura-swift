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
}

// HOME
extension HomeViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.home.rawValue
  }
  
  func push(identifier: RouteElementIdentifier, animated: Bool, completion: @escaping RoutingCompletion) {
    // HOME -> STORY COVER
    if identifier == Screen.storyCover.rawValue {
      let sc = StoryCoverViewController(store: self.store)
      sc.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(sc, animated: animated)
      completion()
    }
  }
}

// NAVIGATION
extension RoutableNavigationController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.navigation.rawValue
  }
  
  func pop(identifier: RouteElementIdentifier, animated: Bool, completion: @escaping RoutingCompletion) {
    self.popViewController(animated: animated)
    completion()
  }
}

// STORY COVER
extension StoryCoverViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.storyCover.rawValue
  }
}
