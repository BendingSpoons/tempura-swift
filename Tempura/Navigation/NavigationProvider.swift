//
//  NavigationProvider.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana

public protocol NavigationProvider: SideEffectDependencyContainer {
  var navigator: Navigator { get }
}

public extension NavigationProvider {
  var navigator: Navigator {
    return Navigator.sharedInstance
  }
}
