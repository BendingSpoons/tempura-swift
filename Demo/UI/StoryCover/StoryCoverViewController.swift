//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class StoryCoverViewController: ViewController<StoryCoverView> {
  var forcedViewModel: StoryCoverViewModel? {
    didSet {
      self.manageForcedViewModelChange()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.rootView.backgroundImage.heroID = "coverBackground"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // handle this better...
    self.manageForcedViewModelChange()
  }
  
  override func setupInteraction() {
    self.rootView.closeButtonDidTap = self.closeButtonDidTap
  }
  
  func closeButtonDidTap() {
    self.dispatch(Hide(animated: true))
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
    let share = UIPreviewAction(title: "Share", style: .default, handler: { _, _  in })
    let upvote = UIPreviewAction(title: "Upvote", style: .default, handler: { _, _  in })
    
    return [ share, upvote ]
  }()
}
