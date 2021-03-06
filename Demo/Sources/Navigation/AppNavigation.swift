//
//  AppNavigation.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana
import Tempura

// MARK: - Screens identifiers

enum Screen: String {
  case list
  case addItem
}

// MARK: - List Screen navigation

extension ListViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.list.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show(Screen.addItem): .presentModally { [unowned self] context in
        if let editID = context as? String {
          let ai = AddItemViewController(store: self.store, itemIDToEdit: editID)
          ai.modalPresentationStyle = .overCurrentContext
          return ai
        } else {
          let ai = AddItemViewController(store: self.store)
          ai.modalPresentationStyle = .overCurrentContext
          return ai
        }
      },
    ]
  }
}

// MARK: - AddItem Screen navigation

extension AddItemViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier {
    return Screen.addItem.rawValue
  }

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .hide(Screen.addItem): .dismissModally(behaviour: .hard),
    ]
  }
}
