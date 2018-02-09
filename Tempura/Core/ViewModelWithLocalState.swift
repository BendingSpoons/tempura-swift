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
  // we are keeping this first associatedtype even if it's redundant
  // so that Swift 4.0 is able to infer both S and LS from the signature of the init when conforming to the protocol
  // if we remove this line, each time you conform to ViewModelWithLocalState you also need to specify the associatedtypes
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
