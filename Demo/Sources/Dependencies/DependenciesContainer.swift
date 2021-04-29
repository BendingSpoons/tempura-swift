//
//  DependenciesContainer.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Katana
import Tempura

final class DependenciesContainer: NavigationProvider {
  var dispatch: AnyDispatch
  var getState: GetState
  var navigator = Navigator()

  required init(
    dispatch: @escaping AnyDispatch,
    getState: @escaping GetState
  ) {
    self.dispatch = dispatch
    self.getState = getState
  }
}
