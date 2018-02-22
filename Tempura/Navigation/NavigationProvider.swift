//
//  NavigationProvider.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana

/// Protocol that the `SideEffectDependencyContainer` of the app must conform in order to
/// use `Navigator` and the navigation mechanism provided by Tempura
public protocol NavigationProvider: SideEffectDependencyContainer {
  /// The instance of the `Navigator` that Tempura will use in order to handle the navigation
  var navigator: Navigator { get }
}
