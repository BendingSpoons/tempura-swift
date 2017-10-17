//
//  ViewModelWithLocalState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 31/07/2017.
//
//

import Foundation
import Katana

public protocol ViewModelWithLocalState: ViewModelWithState {
  associatedtype S: State
  associatedtype LS: LocalState
  
  // the state can be nil if we never connected to the state and we receive a local update
  init(state: S?, localState: LS)
  
}

public extension ViewModelWithLocalState {
  
  init(state: S) {
    fatalError("use `init(state: S, localState: LS)` instead")
  }
}
