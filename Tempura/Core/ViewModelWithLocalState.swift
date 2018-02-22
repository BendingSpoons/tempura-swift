//
//  ViewModelWithLocalState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 31/07/2017.
//
//

import Foundation
import Katana

/// A special case of `ViewModel` used to select part of the Katana app state and `ViewControllerWithLocalState`'s `LocalState`
/// that is of interest for the View.

/// ```swift
///    struct CounterState: State {
///      var counter: Int = 0
///    }
/// ```

/// ```swift
///    struct ScreenLocalState: LocalState {
///      var isCounting: Bool = false
///    }
/// ```

/// ```swift
///    struct CounterViewModel: ViewModelWithState {
///      var countDescription: String
///
///      init(state: CounterState?, localState: ScreenLocalState) {
///        if let state = state, localState.isCounting {
///          self.countDescription = "the counter is at \(state.counter)"
///        } else {
///          self.countDescription = "we are not counting yet"
///        }
///      }
///    }
/// ```

public protocol ViewModelWithLocalState: ViewModelWithState {
  // we are keeping this first associatedtype even if it's redundant
  // so that Swift 4.0 is able to infer both S and LS from the signature of the init when conforming to the protocol
  // if we remove this line, each time you conform to ViewModelWithLocalState you also need to specify the associatedtypes
  associatedtype S: State
  associatedtype LS: LocalState
  
  /// Instantiate a ViewModelWithState given the Katana app state and the `LocalState`.
  init?(state: S?, localState: LS)
  
}

public extension ViewModelWithLocalState {
  /// Do not use this, use the `ViewModelWithLocalState.init(state:localState:)` instead.
  init?(state: S) {
    fatalError("use `init(state: S, localState: LS)` instead")
  }
}
