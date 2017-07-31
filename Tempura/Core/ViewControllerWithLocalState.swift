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

open class ViewControllerWithLocalState<V: ModellableView<LVM>, LVM: ViewModelWithLocalState, S: State, LS>: ViewController<V, LVM, S> where LVM.S == S, LVM.LS == LS {
  public var localState: LS = LS() {
    didSet {
      self.localStateDidChange()
    }
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.localStateDidChange()
  }
  
  private func localStateDidChange() {
    self.updateLocalState(with: self.localState)
  }
  
  private func updateLocalState(with localState: LS) {
    self.viewModel.updateLocalState(with: localState)
  }
}
