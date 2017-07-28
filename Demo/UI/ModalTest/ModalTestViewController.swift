//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class ModalTestViewController: ViewController<ModalTestView, ModalTestViewModel, AppState> {
  
  var localState: Int = 0 {
    didSet {
      self.viewModel.localProperty = self.localState
    }
  }
  
  override func setupInteraction() {
    self.rootView.closeButtonDidTap = self.closeButtonDidTap
    self.rootView.presentButtonDidTap = self.presentButtonDidTap
  }
  
  func closeButtonDidTap() {
    self.dispatch(action: DismissModally(routeElementID: Screen.modalTest.rawValue, animated: true))
  }
  
  func presentButtonDidTap() {
    self.dispatch(action: PresentModally(routeElementID: Screen.modalTest.rawValue, animated: true))
  }
  
  func openButtonTap() {
    self.localState = 3
  }
}
