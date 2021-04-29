//
//  NavigationProvider.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

/// Protocol that the `SideEffectDependencyContainer` of the app must conform in order to
/// use `Navigator` and the navigation mechanism provided by Tempura.
public protocol NavigationProvider: SideEffectDependencyContainer {
  /// The instance of the `Navigator` that Tempura will use in order to handle the navigation.
  var navigator: Navigator { get }
}
