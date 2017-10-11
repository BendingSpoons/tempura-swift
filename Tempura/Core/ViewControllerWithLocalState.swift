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


open class ViewControllerWithLocalState<V: ViewControllerModellableView, S, LS>: ViewController<V, S> where V.VM.S == S, V.VM.LS == LS, V.VM: ViewModelWithLocalState {
  
  /// the local state of this ViewController
  public var localState: LS = LS() {
    didSet {
      self.localStateDidChange()
    }
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.localStateDidChange()
  }
 
  /// handle the state update, create a new updated viewModel and feed the view with that
  override func update(with state: S) {
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
  private func updateLocalState(with localState: LS) {
    guard let state = self.store.anyState as? S else { fatalError("wrong state type") }
    self.viewModel = V.VM(state: state, localState: localState)
  }
}
