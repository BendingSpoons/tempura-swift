//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class HomeViewController: ViewController<HomeView, HomeViewModel, AppState>, UIViewControllerPreviewingDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if traitCollection.forceTouchCapability == .available {
      self.registerForPreviewing(with: self, sourceView: self.view)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func setupInteraction() {
    self.rootView.userDidRequestStory = self.userDidRequestStory
  }
  
  // MARK: - Interaction
  func userDidRequestStory(with id: Story.ID) {
    self.dispatch(action: ShowStory(storyID: id, performNavigation: true))
  }
  
  // MARK: - UIViewControllerPreviewingDelegate
  
  func previewingContext(
    _ previewingContext: UIViewControllerPreviewing,
    viewControllerForLocation location: CGPoint) -> UIViewController? {
    
    guard
      let id = self.rootView.storyIDForViewLocation(location),
      let story = self.rootView.model.stories[id]
    else {
      return nil
    }
    
    let vc = StoryCoverViewController(store: self.store, connected: false)
    vc.forcedViewModel = StoryCoverViewModel(story: story)
    return vc
  }
  
  public func previewingContext(
    _ previewingContext: UIViewControllerPreviewing,
    commit viewControllerToCommit: UIViewController) {
    
    guard
      let vc = viewControllerToCommit as? StoryCoverViewController,
      let model = vc.forcedViewModel
      
    else {
      fatalError("Something is wrong")
    }
    
    self.navigationController?.pushViewController(vc, animated: false)
    self.dispatch(action: ShowStory(storyID: model.storyID, performNavigation: false))
    vc.forcedViewModel = nil
  }
}
