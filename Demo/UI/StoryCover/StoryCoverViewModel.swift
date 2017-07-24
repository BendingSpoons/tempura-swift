//
//  StoryChatViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

// this is the part of the state that the view is interested in
struct StoryCoverViewModel: ViewModel {
  typealias SubtitleComponents = (String, String, String)
  
  var storyID: Story.ID
  var title: String
  var subtitleComponents: SubtitleComponents
  var description: String
  var cover: UIImage?
  
  init(state: AppState) {
    let selectedStory = state.selectedStory
    
    self.storyID = selectedStory?.id ?? ""
    self.title = selectedStory?.title.uppercased() ?? ""
    self.subtitleComponents = (selectedStory?.genre.rawValue.uppercased() ?? "", "by", selectedStory?.author ?? "")
    self.description = selectedStory?.description ?? ""
    self.cover = selectedStory?.cover
  }
  
  init(story: Story) {
    self.storyID = story.id
    self.title = story.title
    self.subtitleComponents = (story.genre.rawValue.uppercased(), "by", story.author)
    self.description = story.description
    self.cover = story.cover
  }
  
  init() {
    self.storyID = ""
    self.title = "empty title"
    self.subtitleComponents = ("genre", "by", "nobody")
    self.description = "an empty description"
  }
}
