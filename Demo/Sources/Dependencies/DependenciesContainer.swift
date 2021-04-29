//
//  DependenciesContainer.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

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
