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

public protocol ViewModelWithLocalState: ViewModelWithState, LocalStateableViewModel {}

public extension ViewModelWithLocalState {
  /// Do not use this, use the `ViewModelWithLocalState.init(state:localState:)` instead.
  init?(state: S) {
    fatalError("use `init(state: S, localState: LS)` instead")
  }
}

// The requirement for a ViewModelWithLocalState, it needs to have both a State and a LocalState
public protocol LocalStateableViewModel: ViewModel {
  associatedtype S: State
  associatedtype LS: LocalState
  
  /// Instantiate a ViewModelWithState given the Katana app state and the `LocalState`.
  init?(state: S?, localState: LS)
  
}
