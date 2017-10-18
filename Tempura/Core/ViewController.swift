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
import Chocolate

// typealias for interaction callback
public typealias Interaction = () -> ()

/// every ViewController will:
/*
 - connect to the store on willAppear and disconnect on didDisappear
 - update the viewModel when a new state is available
 - feed the view with the updated viewModel
 */

open class ViewController<V: ViewControllerModellableView & UIView>: UIViewController {
  /// true if the viewController is connected to the store, false otherwise
  /// a connected viewController will receive all the updates from the store
  open var connected: Bool = true {
    didSet {
      guard self.connected != oldValue else { return }
      self.connectedDidChange()
    }
  }
  
  /// the store the viewController will use to receive state updates
  public var store: Store<V.VM.S>
  
  // the state of this ViewController
  public var state: V.VM.S {
    return self.store.state
  }
  
  /// closure used to unsubscribe the viewController from state updates
 var unsubscribe: StoreUnsubscribe?
  
  /// whether the view controller should disconnect itself from the store updates on `viewWillDisappear`
  public var shouldDisconnectOnViewWillDisappear = true
  
  /// the latest ViewModel received by this ViewController
  public var viewModel: V.VM? {
    willSet {
      self.willUpdate()
    }
    didSet {
      // the viewModel is changed, update the View
      self.rootView.model = viewModel
      self.didUpdate()
    }
  }
  
  /// use the rootView to access the main view managed by this viewController
  open var rootView: V {
    return self.view as! V
  }
  
  /// used internally to load the specific main view managed by this view controller
  open override func loadView() {
    let v = V(frame: .zero)
    v.viewController = self
    v.setup()
    v.style()
    self.view = v
  }
  
  /// the init of the view controller that will take the Store to perform the updates when the store changes
  public init(store: Store<V.VM.S>, connected: Bool = true) {
    self.store = store
    self.connected = connected
    super.init(nibName: nil, bundle: nil)
    self.setup()
    self.connectedDidChange()
  }
  
  /// override to setup something after init
  open func setup() {}
  
  /// shortcut to the dispatch function
  @available(*, deprecated, message: "remove `action` label")
  open func dispatch(action: Action) {
    self.store.dispatch(action)
  }
  
  open func dispatch(_ action: Action) {
    self.store.dispatch(action)
  }
  
  /// we are not using storyboards so trigger a fatalError
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// subscribe to the state updates, the method storeDidChange will be called on every state change
  /// silent = true if you don't want to trigger a state update after connecting to the store
  func connectedDidChange(silent: Bool = false) {
    if self.connected {
      self.subscribe(silent: silent)
    } else {
      if self.unsubscribe != nil {
        self.willUnsubscribe()
        self.unsubscribe?()
        self.unsubscribe = nil
      }
    }
  }
  
  /// subscribe to state updates from the store
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
  
  /// this method is called every time the store trigger a state update
  func storeDidChange() {
    mainThread {
     self.update(with: self.state)
    }
  }
  
  
  /// handle the state update, create a new updated viewModel and feed the view with that
  func update(with state: V.VM.S) {
    // update the view model using the new state available
    // note that the updated method should take into account the local state that should remain untouched
    self.viewModel = V.VM(state: state)
  }
  
  /// before the view will appear on screen, update the view and subscribe for state updates
  open override func viewWillAppear(_ animated: Bool) {
    self.warmUp()
    super.viewWillAppear(animated)
  }
  
  /// warmUp phase, this is executed in the viewWillAppear()
  /// this is needed as an override point for ViewControllerWithLocalState
 func warmUp() {
    if self.connected {
      self.subscribe()
    }
  }
  
  /// after the view disapper from screen, we stop listening for state updates
  open override func viewWillDisappear(_ animated: Bool) {
    if self.connected && self.shouldDisconnectOnViewWillDisappear {
      self.unsubscribe?()
      self.unsubscribe = nil
    }

    super.viewWillDisappear(animated)
  }
  
  /// call the setupInteraction method when the ViewController is loaded
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.setupInteraction()
  }
  
  /// called just before the update, override point for subclasses
  open func willUpdate() {}
  
  /// called right after the update, override point for subclasses
  open func didUpdate() {}
  
  /// ask to setup the interaction with the managed view, override point for subclasses
  open func setupInteraction() {}
  
  /// called just before the unsubscribe, this is used in the ViewControllerWithLocalState
  open func willUnsubscribe() {}
  
  // not necessary?
  deinit {
    self.rootView.viewController = nil
    self.unsubscribe?()
  }
}
