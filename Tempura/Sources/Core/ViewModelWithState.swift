//
//  ViewModelWithState.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

/// A special case of `ViewModel` used to select part of the Katana app state
/// that is of interest for the View.

/// ```swift
///    struct CounterState: State {
///      var counter: Int = 0
///    }
/// ```

/// ```swift
///    struct CounterViewModel: ViewModelWithState {
///      var countDescription: String
///
///      init(state: CounterState) {
///        self.countDescription = "the counter is at \(state.counter)"
///      }
///    }
/// ```
public protocol ViewModelWithState: ViewModel {
  /// The type of the State for this ViewModel
  associatedtype S: State
  /// Instantiate a ViewModelWithState given the Katana app state.
  init?(state: S)
}
