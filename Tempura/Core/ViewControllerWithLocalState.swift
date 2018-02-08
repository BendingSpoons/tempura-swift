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
import Chocolate


open class ViewControllerWithLocalState<V: ViewControllerModellableView & UIView>: ViewController<V> where V.VM: ViewModelWithLocalState {
  
  /// the local state of this ViewController
  public var localState: V.VM.LS = V.VM.LS() {
    didSet {
      self.localStateDidChange()
    }
  }
  
  /// this is the last value for state we observed, we are saving this to be able to update the ViewModel
  /// when the local state changes and we are disconnected from the global state, we use this value as the global state
  public var lastKnownState: V.VM.S?
  
  /// we are about to unsubscribe from the global state, save it locally in the lastKnownState
  /// while we are disconnected we will look at the lastKnownState
  open override func willUnsubscribe() {
    self.lastKnownState = self.state
  }
  
  /// executed during the viewWillAppear()
  open override func warmUp() {
    // we are using silent = true because we don't want to trigger two updates
    // one after the subscribing and one after the localStateDidChange()
    if self.shouldConnectWhenVisible {
      self.subscribe(silent: true)
    }
    self.localStateDidChange()
  }
 
  /// handle the state update, create a new updated viewModel and feed the view with that
  override func update(with state: V.VM.S) {
    // update the view model using the new state available
    // note that the updated method should take into account the local state that should remain untouched
     self.viewModel = V.VM(state: state, localState: self.localState)
 }
  
  /// this method is called every time the local state changes
  private func localStateDidChange() {
    mainThread {
      self.updateLocalState(with: self.localState)
    }
  }
  
  // handle the local state update
  private func updateLocalState(with localState: V.VM.LS) {
    let state = self.connected ? self.state : self.lastKnownState
    self.viewModel = V.VM(state: state, localState: localState)
  }
}
