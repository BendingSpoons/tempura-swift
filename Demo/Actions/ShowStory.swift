//
//  ShowStory.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana
import Tempura

struct ShowStory: AppAction {
  var storyID: Story.ID
  var performNavigation: Bool
  
  func updatedState(currentState: inout AppState) {
    currentState.selectedStoryID = self.storyID
  }
  
  init(storyID: Story.ID, performNavigation: Bool) {
    self.storyID = storyID
    self.performNavigation = performNavigation
  }
}

extension ShowStory: AppActionWithSideEffect {
  func sideEffect(currentState: AppState, previousState: AppState, dispatch: @escaping StoreDispatch, dependencies: DependenciesContainer) {
    if self.performNavigation {
      dispatch(Show([Screen.storyCover.rawValue], animated: true))
    }
  }
}
