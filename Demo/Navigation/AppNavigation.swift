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
  case list
  case addItem
}

// List
extension ListViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.list.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.addItem): .presentModally({ [unowned self] _ in
        let ai = AddItemViewController(store: self.store)
        ai.modalPresentationStyle = .overCurrentContext
        return ai
    })]
  }
}

// AddItem
extension AddItemViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.addItem.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.addItem): .dismissModally(behaviour: .hard)
    ]
  }
}

// HOME
/*extension HomeViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.home.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.storyCover): .push({ [unowned self] _ in
        let sc = StoryCoverViewController(store: self.store)
        sc.hidesBottomBarWhenPushed = true

        return sc
      })
    ]
  }
}

// NAVIGATION
extension RoutableNavigationController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.navigation.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.storyCover): .pop
    ]
  }
}

// STORY COVER
extension StoryCoverViewController: Routable {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.storyCover.rawValue
  }
}

// MODAL TEST
extension ModalTestViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.modalTest.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.modalTest): .custom({ [unowned self] _, _, animated, _, completion in
        if self.presentingViewController != nil {
          self.softDismiss(animated: animated, completion: completion)
        
        } else {
          completion()
        }
      })
    ]
  }
}

// TABBAR
extension TabBarController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.tabbar.rawValue
  }
  
  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.modalTest): .presentModally({ [unowned self] _ in ModalTestViewController(store: self.store) })
    ]
  }
}
*/
