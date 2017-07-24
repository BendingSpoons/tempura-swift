//
//  StoryChatViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import Tempura

// this is the part of the state that the view is interested in
struct HomeViewModel: ViewModel {
  let coverStory: Story?
  let stories: [Story.ID: Story]
  let trendingStories: [Story]
  let pendingStories: [Story]
  let newStoriesFromCommunity: [Story]
  
  init(state: AppState) {
    let stories = state.stories
    
    self.coverStory = stories.allStories[stories.homeCoverStory]

    self.trendingStories = stories.trendingStoryIDs.flatMap { stories.allStories[$0] }
    self.pendingStories = stories.pendingStoryIDs.flatMap { stories.allStories[$0] }
    self.newStoriesFromCommunity = stories.newFromCommunity.flatMap { stories.allStories[$0] }

    self.stories = stories.allStories
  }
  
  init() {
    self.stories = [:]
    self.trendingStories = []
    self.pendingStories = []
    self.newStoriesFromCommunity = []
    self.coverStory = nil
  }
}
