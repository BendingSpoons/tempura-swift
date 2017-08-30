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

// MODAL TEST
extension ModalTestViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.modalTest.rawValue
  }
  
  func presentModally(modal: RouteElementIdentifier,
                      animated: Bool,
                      completion: @escaping RoutingCompletion) -> Bool {
    if modal == Screen.modalTest.rawValue {
      let vc = ModalTestViewController(store: self.store)
      self.present(vc, animated: animated, completion: completion)
      return true
    }
    return false
  }
}

// TABBAR
extension TabBarController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.tabbar.rawValue
  }
  
  func presentModally(modal: RouteElementIdentifier,
                      animated: Bool,
                      completion: @escaping RoutingCompletion) -> Bool {
    if modal == Screen.modalTest.rawValue {
      let vc = ModalTestViewController(store: self.store)
      self.present(vc, animated: animated, completion: completion)
      return true
    }
    return false
  }
  
  func dismissModally(identifier: RouteElementIdentifier,
                      vcToDismiss: UIViewController,
                      animated: Bool,
                      completion: @escaping RoutingCompletion) -> Bool {
    // check if the vcToDismiss has been presented modally
    // this is because the same ModalTestViewController is also present in the navigation stack as a child of the TabBarController
    if vcToDismiss.presentingViewController != nil {
      vcToDismiss.dismiss(animated: animated) {
        completion()
      }
      return true
    }
    completion()
    return true
  }
}
