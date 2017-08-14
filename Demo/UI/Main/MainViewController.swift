//
//  MainViewController.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Tempura

class MainViewController: ViewController<MainView, AppState> {
  
  // MARK: - Interaction
  override func setupInteraction() {
    self.rootView.addButtonDidTap = self.addButtonDidTap
    self.rootView.subtractButtonDidTap = self.subtractButtonDidTap
  }
  
  func addButtonDidTap() {
    self.dispatch(action: Add())
  }
  
  func subtractButtonDidTap() {
    self.dispatch(action: Subtract())
  }
  
}
