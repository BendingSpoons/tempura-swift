//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class LocalStateTestViewController: ViewControllerWithLocalState<LocalStateTestView, AppState, TestLocalState> {
  
  override func setupInteraction() {
    self.rootView.subButtonDidTap = self.decrementButtonDidTap
    self.rootView.addButtonDidTap = self.incrementButtonDidTap
  }
  
  func decrementButtonDidTap() {
    // decrement local state
    self.localState.localCounter = self.localState.localCounter - 1
  }
  
  func incrementButtonDidTap() {
    // increment local state
    self.localState.localCounter = self.localState.localCounter + 1
  }
}
