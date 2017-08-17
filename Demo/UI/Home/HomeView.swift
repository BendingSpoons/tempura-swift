//
//  StoryChatView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura

class HomeView: UIView, ModellableView {
  typealias UserDidRequestStory = (Story.ID) -> Void
  typealias VM = HomeViewModel
  
  public var userDidRequestStory: UserDidRequestStory? {
    get { return self.collectionDelegate.userDidRequestStory }
    set { self.collectionDelegate.userDidRequestStory = newValue }
  }
  
  private let collectionDelegate: HomeViewCollectionDelegate
  
  // subviews
  lazy var collectionView: UICollectionView = {
    let layout = HomeCollectionLayout()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.delegate = self.collectionDelegate
    collectionView.dataSource = self.collectionDelegate
    
    // TODO: fixme
    collectionView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 20, right: 0)
    
    collectionView.register(CoverStory.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CoverStory.identifier)
    
    collectionView.register(AllStoryHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AllStoryHeader.identifier)
    
    collectionView.register(StorySectionCell.self, forCellWithReuseIdentifier: StorySectionCell.identifier)
    collectionView.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
    
    collectionView.alwaysBounceVertical = true
    
    return collectionView
  }()
  
  // init
  required override init(frame: CGRect) {
    self.collectionDelegate = HomeViewCollectionDelegate()
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // SETUP
  func setup() {
    self.addSubview(self.collectionView)
  }
  
  func style() {
    self.backgroundColor = .black
    self.collectionView.backgroundColor = .black
  }
  
  // UPDATE
  func update(oldModel: HomeViewModel) {
    let model = self.model
    self.collectionDelegate.coverStory = model.coverStory
    self.collectionDelegate.stories = Array(model.stories.values)
    self.collectionDelegate.newFromCommunityStories = model.newStoriesFromCommunity
    self.collectionDelegate.readingStories = model.pendingStories
    self.collectionDelegate.trendingStories = model.trendingStories

    self.collectionView.reloadData()
  }
  
  // LAYOUT
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }

  func layout() {
    self.collectionView.frame = self.bounds
  }
}

extension HomeView {
  func storyIDForViewLocation(_ location: CGPoint) -> Story.ID? {
    
    let collectionLocation = self.collectionView.convert(location, from: self)
    
    guard let idxPath = self.collectionView.indexPathForItem(at: collectionLocation) else {
      return nil
    }
    
    if idxPath.section == 0 {
      guard let cell = self.collectionView.cellForItem(at: idxPath) as? StorySectionCell else {
        return nil
      }
      
      let subViewLocation = cell.convert(location, from: self)
      return cell.storyIDForViewLocation(subViewLocation)
    
    } else if idxPath.section == 1 {
      // all stories
      return Array(self.model.stories.keys)[idxPath.row]
    }
    
    return nil
  }
}
