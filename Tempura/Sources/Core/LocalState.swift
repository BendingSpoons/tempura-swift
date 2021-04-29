//
//  LocalState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 31/07/2017.
//

/// The LocalState of a `ViewControllerWithLocalState`.
///
/// A `ViewController` is managing the UI of a screen, listening for Katana global state changes, keeping the UI updated
/// and dispatching actions in response to user interactions in order to change the global state.
///
/// There are times when you have some kind of state information that is only specific to the screen managed
/// by a ViewController, like for instance the item selected in a list.
/// In this case, in order to avoid polluting the global state, you can represent that information inside
/// a `LocalState` and promote that ViewController to be a `ViewControllerWithLocalState`.
///
/// A ViewControllerWithLocalState contains a `localState` variable that you can change directly in order
/// to represent local state changes.
///
/// ```swift
///    struct GlobalState: State {
///      var todos: [String] = [
///        "buy milk",
///        "find a unicorn",
///        "visit Rome"
///      ]
///    }
/// ```

/// ```swift
///    struct ListLocalState: LocalState {
///      var selectedIndex: Int
///    }
/// ```
public protocol LocalState {}
