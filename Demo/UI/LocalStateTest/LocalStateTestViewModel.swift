//
//  StoryChatViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

// this is the part of the state that the view is interested in
struct LocalStateTestViewModel: ViewModelWithLocalState {

  // local state
  var localCounterString: String = ""
  // global state, this is updated when the global state changes
  var globalCounterString: String = ""
  
  init(state: AppState, localState: TestLocalState) {
    self.globalCounterString = "global counter is \(state.counter)"
    self.localCounterString = "local counter is \(localState.localCounter)"
  }
  
  init() {}
}
