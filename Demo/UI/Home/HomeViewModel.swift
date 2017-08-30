//
//  StoryChatViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import Tempura

// this is the part of the state that the view is interested in
struct HomeViewModel: ViewModelWithState {

  var coverStory: Story?
  var stories: [Story.ID: Story]
  var trendingStories: [Story]
  var pendingStories: [Story]
  var newStoriesFromCommunity: [Story]

  
  init(state: AppState) {
    coverStory = state.stories.allStories[state.stories.homeCoverStory]
    
    trendingStories = state.stories.trendingStoryIDs.flatMap { state.stories.allStories[$0] }
    pendingStories = state.stories.pendingStoryIDs.flatMap { state.stories.allStories[$0] }
    newStoriesFromCommunity = state.stories.newFromCommunity.flatMap { state.stories.allStories[$0] }
    
    stories = state.stories.allStories
  }
  
  
  init() {
    self.stories = [:]
    self.trendingStories = []
    self.pendingStories = []
    self.newStoriesFromCommunity = []
    self.coverStory = nil
  }
}
