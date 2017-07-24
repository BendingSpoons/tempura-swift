//
//  AppState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana

struct AppState: State {
  var counter: Int = 0
  
  // all stories
  var stories = Stories()
  
  // selected story
  var selectedStoryID: Story.ID?
  
}

extension AppState {
  var selectedStory: Story? {
    guard let id = selectedStoryID else { return nil }
    return stories.allStories[id]
  }
}

extension AppState {
  struct Stories {
    let allStories: [Story.ID: Story]
    
    let homeCoverStory: Story.ID
    let pendingStoryIDs: [Story.ID]
    let trendingStoryIDs: [Story.ID]
    let newFromCommunity: [Story.ID]
    
    init() {
      self.allStories = testStories
      self.homeCoverStory = "00001"
      self.pendingStoryIDs = [ "00001", "00002", "00003", "00004", "00005", "00006", "00007" ]
      self.trendingStoryIDs = [ "00002", "00005", "00004", "00003", "00007", "00001", "00006" ]
      self.newFromCommunity = [ "00001", "00004", "00002", "00003", "00006", "00005", "00007" ]
    }
  }
}

let testStories: [Story.ID: Story] = {
  return [
    "00001": Story(
      id: "00001",
      title: "A Horror Tale",
      genre: .horror,
      author: "John. O.J.",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    ),
    
    "00002": Story(
      id: "00002",
      title: "Parking Monster",
      genre: .horror,
      author: "jey_rr_talkeeAnn",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she starts hearing weird sounds...",
      chat: [:]
    ),
    
    "00003": Story(
      id: "00003",
      title: "Stereotypical House",
      genre: .horror,
      author: "avrilLavigne",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    ),
    
    "00004": Story(
      id: "00004",
      title: "Da Pool King",
      genre: .romance,
      author: "juseppeena",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    ),
    
    "00005": Story(
      id: "00005",
      title: "Random Sign on the floor",
      genre: .horror,
      author: "superDude",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    ),
    
    "00006": Story(
      id: "00006",
      title: "She Was Upside Down",
      genre: .horror,
      author: "mediocre_writer",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    ),
    
    "00007": Story(
      id: "00007",
      title: "Die Brücke",
      genre: .horror,
      author: "reallyBadEnglish",
      cover: UIImage(named: "photo")!,
      description: "A girl is coming back from work, and as soon as she enters the parking lot, she stats hearing weird sounds...",
      chat: [:]
    )
  ]
}()
