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
  let promisableDispatch: PromisableStoreDispatch
  
  var getAppState: () -> AppState
    
  var navigator: Navigator = Navigator()
  
  var getState: () -> State {
    return self.getAppState
  }
  
  init(dispatch: @escaping PromisableStoreDispatch, getAppState: @escaping () -> AppState) {
    self.promisableDispatch = dispatch
    self.getAppState = getAppState
  }
}

extension DependenciesContainer {
  convenience init(dispatch: @escaping PromisableStoreDispatch, getState: @escaping GetState) {
    let getAppState: () -> AppState = {
      guard let state = getState() as? AppState else {
        fatalError("Wrong State Type")
      }
      return state
    }
    
    self.init(dispatch: dispatch, getAppState: getAppState)
  }
}
