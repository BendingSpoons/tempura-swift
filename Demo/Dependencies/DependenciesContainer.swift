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
  var dispatch: Dispatch
  var getState: GetState
  var navigator: Navigator = Navigator()
  
  required init(
    dispatch: @escaping SideEffectDependencyContainer.Dispatch,
    getState: @escaping GetState
  ) {
    self.dispatch = { dispatchable in dispatch(dispatchable).void }
    self.getState = getState
  }
}
