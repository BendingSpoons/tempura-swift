//
//  ViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit
import Katana
import Hydra

/// Typealias for simple interaction callback.
/// For more complex interactions (that contains parameters) define your own closure.
public typealias Interaction = () -> ()
public typealias CustomInteraction<T> = (T) -> ()

/// Partial Type Erasure for the ViewController
/// Each `ViewController` is an `AnyViewController`
public protocol AnyViewController {
  /// The type of the View managed by the ViewController
  associatedtype V: ViewControllerModellableView & UIView
  /// The View managed by the ViewController
  var rootView: V { get }
}

/// Manages a screen of your app, it keeps the UI updated and listens for user interactions.

/// ## Overview
/// In Tempura, a Screen is composed by three different elements that interoperate in order to get the actual
/// pixels on the screen and to keep them updated when the state changes.
/// These are ViewController, `ViewModelWithState` and `ViewControllerModellableView`.
/// The ViewController is a subclass of `UIViewController` that is responsible to manage the set of views that are shown in each screen of your UI.

/// ```swift
///    struct CounterState: State {
///      var counter: Int = 0
///    }
/// ```

/// ```swift
///    struct IncrementCounter: Action {
///      func updatedState(inout currentState: CounterState) {
///        currentState.counter += 1
///      }
///    }
/// ```

/// ```swift
///    struct DecrementCounter: Action {
///      func updatedState(inout currentState: CounterState) {
///        currentState.counter -= 1
///      }
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

/// ```swift
///    class CounterView: UIView, ViewControllerModellableView {
///
///      // subviews
///      var counterLabel = UILabel()
///      var addButton = UIButton(type: .custom)
///      var subButton = UIButton(type: .custom)
///
///      // interactions
///      var didTapAdd: Interaction?
///      var didTapSub: Interaction?
///
///      // setup
///      func setup() {
///        self.addButton.on(.touchUpInside) { [unowned self] button in
///          self.didTapAdd?()
///        }
///        self.subButton.on(.touchUpInside) { [unowned self] button in
///          self.didTapSub?()
///        }
///        self.addSubview(self.counterLabel)
///        self.addSubview(self.subButton)
///        self.addSubview(self.addButton)
///      }
///
///      // style
///      func style() {
///        self.backgroundColor = .white
///        self.addButton.setTitle("Add", for: .normal)
///        self.subButton.setTitle("Sub", for: .normal)
///      }
///
///      // update
///      func update(oldModel: CounterViewModel?) {
///        self.counterLabel.text = self.model?.countDescription
///        self.setNeedsLayout()
///      }
///
///      // layout
///      override func layoutSubviews() {
///        self.counterLabel.sizeToFit()
///        self.addButton.frame = CGRect(x: 0, y: 100, width: 100, height: 44)
///        self.subButton.frame = CGRect(x: 100, y: 100, width: 100, height: 44)
///      }
///    }
/// ```

/// ```swift
///    class CounterViewController: ViewController<CounterView> {
///
///    override func setupInteraction() {
///      self.rootView.didTapAdd = { [unowned self] in
///        self.dispatch(IncrementCounter())
///      }
///      self.rootView.didTapSub = { [unowned self] in
///        self.dispatch(DecrementCounter())
///      }
///    }
///    ```

/// ## Lifecycle of a ViewController
/// In order to instantiate a ViewController's subclass you need to provide a Katana `Store` instance.
/// This instance will be used by the ViewController to listen for state updates.
/// ```swift
///    let vc = CounterViewController(store: appStore)
/// ```
///
/// When a ViewController is created it will start receiving state updates as soon as the `connected` property
/// will become `true`.
///
/// When the ViewController becomes visible, the UIKit `UIViewController.viewWillAppear()` will be called and
/// Tempura will set `connected` to `true` and the ViewController will start receiving the updates
/// from the state.
/// If you don't want this to happen automatically every time the ViewController will become visible, set
/// `shouldConnectWhenVisible` to `false`.
///
/// As soon a new state is available from the Katana store, the ViewController will instantiate a new ViewModel
/// out of that state and feed the `rootView` with that, calling `ModellableView.update(oldModel:)`
///
/// When something happens inside the `ViewControllerModellableView` (or its subviews)
/// the ViewController is responsible to listen for these `Interaction` callbacks and react accordingly
/// dispatching actions in order to change the state.
///
/// When a ViewController is removed from the hierarchy or hidden by some other ViewController, UIKit will call
/// `UIViewController.viewWillDisappear()` and Tempura will set `connected` to `false`, detaching the
/// ViewController from the state updates.
/// If you don't want this to happen automatically every time the ViewControllet will become invisible,
/// set `sholdDisconnectWhenInvisible` to `false`

open class ViewController<V: ViewControllerModellableView & UIView>: UIViewController, AnyViewController {
  /// `true` if the ViewController is connected to the store, false otherwise.
  /// A connected ViewController will receive all the updates from the store.
  /// Tempura will set this property to true when the ViewController is about to be displayed on screen,
  /// if you want to change this behaviour look at the `shouldConnectWhenVisible` property.
  /// Tempura will set this property to false when the ViewController is about to be hidden,
  /// if you want to change this behaviour look at the `shouldDisconnectWhenVisible` property.
  open var connected: Bool {
    get {
      return self.unsubscribe != nil
    }
    set {
      self.updateConnect(to: newValue)
    }
  }
  
  /// The store the ViewController will use to receive state updates.
  public var store: PartialStore<V.VM.S>
  
  /// The state of this ViewController
  public var state: V.VM.S {
    return self.store.state
  }
  
  /// Closure used to unsubscribe the viewController from state updates.
  var unsubscribe: StoreUnsubscribe?
  
  /// When `true`, the ViewController will be set to `connected` = `true` as soon as it becomes visible.
  public var shouldConnectWhenVisible = true
  
  /// When `true` the ViewController will be set to `connected` = `false` as soon as it becomes invisible.
  public var shouldDisconnectWhenInvisible = true
  
  /// The latest ViewModel received by this ViewController from the state.
  public var viewModel: V.VM? {
    willSet {
      self.willUpdate(new: newValue)
    }
    didSet {
      // the viewModel is changed: update the View (if loaded)
      if self.isViewLoaded {
        self.rootView.model = viewModel
      }
      self.didUpdate(old: oldValue)
    }
  }
  
  /// Use the rootView to access the main view managed by this viewController.
  open var rootView: V {
    return self.view as! V
  }
  
  /// Used internally to load the specific main view managed by this view controller.
  open override func loadView() {
    let v = V(frame: .zero)
    v.viewController = self
    v.setup()
    v.style()
    self.view = v
  }
  
  /// Returns a newly initialized ViewController object.
  public init(store: PartialStore<V.VM.S>, connected: Bool = false) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
    self.setup()
    self.connected = connected
  }
  
  /// Override to setup something after init.
  open func setup() {}
  
  open func dispatch(_ dispatchable: Dispatchable) {
    self.store.dispatch(dispatchable)
  }
  
  /// Shortcut to the dispatch function.
  open func dispatch<T: Dispatchable>(_ dispatchable: T) {
    _ = self.store.dispatch(dispatchable)
  }
  
  /// Shortcut to the dispatch function. This will return a Promise<Void> when called with a Dispatchable.
  @discardableResult
  open func __unsafeDispatch<T: Dispatchable>(_ dispatchable: T) -> Promise<Void> {
    return self.store.dispatch(dispatchable)
  }
  
  /// Shortcut to the dispatch function. This will return a Promise<T.ReturnValue> when called on a SideEffect `T`.
  @discardableResult
  open func __unsafeDispatch<T: SideEffect>(_ dispatchable: T) -> Promise<T.ReturnValue> {
    return self.store.dispatch(dispatchable)
  }
  
  /// Required init.
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Subscribe/unsubsribe to the state updates, the method storeDidChange will be called on every state change.
  /// Specify `silent` = `true` if you don't want to trigger a state update after connecting to the store.
  func updateConnect(to connected: Bool, silent: Bool = false) {
    if connected {
      self.subscribe(silent: silent)
    } else {
      if self.unsubscribe != nil {
        self.willUnsubscribe()
        self.unsubscribe?()
        self.unsubscribe = nil
      }
    }
  }
  
  /// Subscribe to state updates from the store.
  func subscribe(silent: Bool = false) {
    // check if we are already subscribed
    guard self.unsubscribe == nil else { return }
    
    // subscribe
    let unsubscribe = self.store.addListener { [unowned self] in
      self.storeDidChange()
    }
    // save the unsubscribe closure
    self.unsubscribe = unsubscribe
    
    if !silent {
      self.storeDidChange()
    }
  }
  
  /// Called every time the store triggers a state update.
  func storeDidChange() {
    mainThread {
     self.update(with: self.state)
    }
  }
  
  
  /// Handle the state update, create a new updated viewModel and feed the view with that.
  func update(with state: V.VM.S) {
    // update the view model using the new state available
    // note that the updated method should take into account the local state that should remain untouched
    self.viewModel = V.VM(state: state)
  }
  
  /// The ViewController is about to be displayed.
  open override func viewWillAppear(_ animated: Bool) {
    self.warmUp()
    super.viewWillAppear(animated)
  }
  
 /// WarmUp phase, check if we should connect to the state.
 func warmUp() {
    if self.shouldConnectWhenVisible {
      self.connected = true
    }
  }
  
  /// TearDown phase, check if we should disconnect from the state.
  func tearDown() {
    if self.shouldDisconnectWhenInvisible {
      self.connected = false
    }
  }
  
  /// The ViewController is about to be removed from the view hierarchy.
  open override func viewWillDisappear(_ animated: Bool) {
    self.tearDown()
    super.viewWillDisappear(animated)
  }
  
  /// Called after the controller's view is loaded into memory.
  open override func viewDidLoad() {
    super.viewDidLoad()
    if let vm = self.viewModel {
      self.rootView.model = vm
      self.didUpdate(old: nil)
    }
    self.setupInteraction()
  }
  
  /// Called just before the update, override point for subclasses.
  open func willUpdate(new: V.VM?) {}
  
  /// Called right after the update, override point for subclasses.
  open func didUpdate(old: V.VM?) {}
  
  /// Asks to setup the interaction with the managed view, override point for subclasses.
  open func setupInteraction() {}
  
  /// Called just before the unsubscribe, override point for subclasses.
  open func willUnsubscribe() {}
  
  // not needed?
  deinit {
    self.unsubscribe?()
  }
}
