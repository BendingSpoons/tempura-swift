//
//  ViewControllerWithLocalState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 31/07/2017.
//
//

import Foundation
import UIKit
import Katana

/// Special case of a `ViewController` that contains a `LocalState`.

/// ## Overview
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
/// The ViewControllerWithLocalState will be listening for changes of both global and local states, updating
/// the UI using the appropriate `ViewModelWithLocalState`.
///
/// You can change the global state dispatching Katana actions like in every `ViewController`. You can change
/// the `LocalState` manipulating directly the `localState` variable.
///
/// The lifecycle of a ViewControllerWithLocalState is the same as a normal `ViewController`, please refer to that
/// for more details.

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
///    struct RemoveTodo: AppAction {
///      var index: Int
///
///      func updatedState(inout currentState: GlobalState) {
///        currentState.todos.remove(at: index)
///      }
///    }
/// ```

/// ```swift
///    struct ListLocalState: LocalState {
///      var selectedIndex: Int
///    }
/// ```

/// ```swift
///    struct TodolistViewModel: ViewModelWithLocalState {
///      var todos: [String]
///      var selectedIndex: Int
///
///      init?(state: GlobalState?, localState: ListLocalState) {
///        guard let state = state else { return nil }
///        self.todos = state.todos
///        self.selectedIndex = localState.selectedIndex
///      }
///    }
/// ```

/// ```swift
///    class TodoListView: UIView, ViewControllerModellableView {
///
///      // subviews
///      var todoListView = ListView()
///
///      // interactions
///      var didTapToRemoveItem: ((Int) -> ())?
///      var didSelectItem: ((Int) -> ())?
///
///      // setup
///      func setup() {
///        self.todoListView.on(.selection) { [unowned self] indexPath in
///          self.didSelectItem?(indexPath.item)
///        }
///        self.todoListView.on(.deleteItem) { [unowned self] indexPath in
///          seld.didTapRemoveItem?(indexPath.item)
///        }
///        self.addSubview(self.todoListView)
///      }
///
///      // style
///      func style() {
///        self.backgroundColor = .white
///        self.todoListView.backgroundColor = .white
///      }
///
///      // update
///      func update(oldModel: CounterViewModel?) {
///        self.todoListView.source = model?.todos ?? []
///        self.todoListView.selectedIndex = model?.todos
///      }
///
///      // layout
///      override func layoutSubviews() {
///        self.todoListView.frame = self.bounds
///      }
///    }
/// ```

/// ```swift
///    class TodoListViewController: ViewControllerWithLocalState<TodoListView> {
///
///    override func setupInteraction() {
///      self.rootView.didTapRemoveItem = { [unowned self] index in
///        self.dispatch(RemoveTodo(index: index))
///      }
///      self.rootView.didSelectItem = { [unowned self] index in
///        self.localState.selectedIndex = index
///      }
///    }
/// ```

open class ViewControllerWithLocalState<V: ViewControllerModellableView & UIView>: ViewController<V> where V.VM: ViewModelWithLocalState {
  
  /// The `LocalState` of this ViewController.
  public var localState: V.VM.LS {
    didSet {
      self.localStateDidChange()
      self.didUpdateLocalState()
    }
  }
  
  /// This is the last value for global state we observed, we are saving this to be able to update the `ViewModelWithLocalState`
  /// when the local state changes and we are disconnected from the global state.
  public var lastKnownState: V.VM.S?
  
  public init(store: PartialStore<V.VM.S>, localState: V.VM.LS, connected: Bool = false) {
    self.localState = localState
    super.init(store: store, connected: connected)
    // if the ViewControllerWithLocalState is not connected to the state when created, we still need to retrieve the local state
    if !self.connected {
      self.localStateDidChange()
    }
  }
  
  /// Returns a newly initialized ViewControllerWithLocalState object.
  private override init(store: PartialStore<V.VM.S>, connected: Bool = false) {
    fatalError("you should use `init(store:localState:)` instead.")
  }
  
  /// Required init.
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }
    
  /// Called after the local state is updated, override point for subclasses.
  open func didUpdateLocalState() {}

  /// Called just before the unsubscribe, override point for subclasses.
  open override func willUnsubscribe() {
    self.lastKnownState = self.state
  }
  
  /// WarmUp phase, check if we should connect to the state.
  override func warmUp() {
    // we are using silent = true because we don't want to trigger two updates
    // one after the subscribing and one after the localStateDidChange()
    if self.shouldConnectWhenVisible {
      // we want to connect with silent = true
      self.updateConnect(to: true, silent: true)
    }
    self.localStateDidChange()
  }
 
  /// Handle the state update, create a new updated viewModel and feed the view with that.
  override func update(with state: V.VM.S) {
    // update the view model using the new state available
    // note that the updated method should take into account the local state that should remain untouched
     self.viewModel = V.VM(state: state, localState: self.localState)
 }
  
  /// This method is called every time the local state changes.
  private func localStateDidChange() {
    mainThread {
      self.updateLocalState(with: self.localState)
    }
  }
  
  /// Handle the local state update.
  private func updateLocalState(with localState: V.VM.LS) {
    let state = self.connected ? self.state : self.lastKnownState
    self.viewModel = V.VM(state: state, localState: localState)
  }
}
