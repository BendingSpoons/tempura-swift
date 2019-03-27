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
  /// The type of the LocalState for this ViewModel
  //associatedtype S: State
  associatedtype SS: State where S == SS
  associatedtype LS: LocalState
  
  /// Instantiate a ViewModelWithLocalState given the Katana app state and the `LocalState`.
  init?(state: SS?, localState: LS)
}

public extension ViewModelWithLocalState {
  /// Do not use this, use the `ViewModelWithLocalState.init(state:localState:)` instead.
  init?(state: SS) {
    fatalError("use `init(state: S, localState: LS)` instead")
  }
}
