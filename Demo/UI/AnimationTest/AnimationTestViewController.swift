//
//  AnimationTestViewController.swift
//  Tempura
//
//  Created by Andrea De Angelis on 01/08/2017.
//
//

import Foundation
import Tempura

class AnimationTestViewController: ViewControllerWithLocalState<AnimationTestView, AnimationTestLocalState> {
  
  override func setupInteraction() {
    self.rootView.buttonDidTap = self.buttonDidTap
  }
  
  func buttonDidTap() {
    self.localState.expanded = !self.localState.expanded
  }
}
