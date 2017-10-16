//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class ModalTestViewController: ViewController<ModalTestView> {
  
  override func setupInteraction() {
    self.rootView.closeButtonDidTap = self.closeButtonDidTap
    self.rootView.presentButtonDidTap = self.presentButtonDidTap
  }
  
  func closeButtonDidTap() {
    self.dispatch(Hide(animated: true))
  }
  
  func presentButtonDidTap() {
    self.dispatch(Show([Screen.modalTest.rawValue], animated: true))
  }
}
