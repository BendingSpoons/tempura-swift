//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class StoryCoverViewController: ViewController<StoryCoverView, AppState, StoryCoverViewModel> {
  var forcedViewModel: StoryCoverViewModel? {
    didSet {
      self.manageForcedViewModelChange()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // TODO: handle this better..
    self.manageForcedViewModelChange()
  }
  
  override func setupInteraction() {
    self.rootView.closeButtonDidTap = self.closeButtonDidTap
  }
  
  func closeButtonDidTap() {
    self.dispatch(action: Pop(animated: true))
  }
    
  func manageForcedViewModelChange() {
    
    guard let forcedModel = self.forcedViewModel else {
      self.connected = true
      return
    }
    
    self.connected = false
    self.rootView.model = forcedModel
  }
  
  lazy var previewActions: [UIPreviewActionItem] = {
    let share = UIPreviewAction(title: "Share", style: .default, handler: { _ in } )
    let upvote = UIPreviewAction(title: "Upvote", style: .default, handler: { _ in } )
    
    return [ share, upvote ]
  }()
}

