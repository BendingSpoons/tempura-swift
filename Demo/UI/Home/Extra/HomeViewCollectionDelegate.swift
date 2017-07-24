//
//  HomeViewCollectionDelegate.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit
import Hero

final class HomeViewCollectionDelegate: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  var stories: [Story]
  var readingStories: [Story]
  var trendingStories: [Story]
  var newFromCommunityStories: [Story]
  var coverStory: Story?
  var userDidRequestStory: HomeView.UserDidRequestStory?
  
  override init() {
    self.stories = []
    self.readingStories = []
    self.trendingStories = []
    self.newFromCommunityStories = []
    self.coverStory = nil
  }
}

extension HomeViewCollectionDelegate {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 3
      
    } else if section == 1 {
      return self.stories.count
    }
    
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      return self.storySectionCell(for: indexPath, collectionView: collectionView)
      
    case 1:
      return self.allStoryCell(for: indexPath, collectionView: collectionView)
      
    default:
      fatalError()
    }
    
    fatalError()
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionElementKindSectionHeader else {
      fatalError()
    }
    
    switch indexPath.section {
    case 0:
      return self.storySectionHeader(for: indexPath, collectionView: collectionView)
      
    case 1:
      return self.allStoryHeader(for: indexPath, collectionView: collectionView)
      
    default:
      fatalError()
    }

    fatalError()
  }
}

extension HomeViewCollectionDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    switch section {
    case 0:
      return (self.coverStory == nil) ? .zero : CGSize(width: collectionView.frame.size.width, height: 240)
      
    case 1:
      return CGSize(width: collectionView.frame.size.width, height: 87)
      
    default:
      fatalError()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if indexPath.section == 0 {
      return CGSize(width: collectionView.frame.width, height: 253)
      
    } else if indexPath.section == 1 {
      return CGSize(width: collectionView.frame.width, height: 199)
    }
    
    return .zero
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
    switch section {
    case 0:
      return 0.0
      
    case 1:
      return 21.0
      
    default:
      fatalError()
    }
    
    fatalError()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    switch section {
    case 0:
      return .zero
      
    case 1:
      return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
      
    default:
      fatalError()
    }
    
    fatalError()
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == 1 else {
      return
    }
    
    let story = self.stories[indexPath.row]
    self.userDidRequestStory?(story.id)
  }
}

extension HomeViewCollectionDelegate {
  fileprivate func storySectionCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: StorySectionCell.identifier,
      for: indexPath
      ) as! StorySectionCell
    
    guard let section = StorySectionCell.Section(rawValue: indexPath.row) else {
      return cell
    }
    
    switch section {
    case .newFromCommunity:
      cell.stories = self.newFromCommunityStories
      
    case .reading:
      cell.stories = self.readingStories
      
    case .trending:
      cell.stories = self.trendingStories
    }
    
    cell.section = section
    cell.userDidRequestStory = self.userDidRequestStory
    cell.update()
    
    return cell
  }
  
  fileprivate func allStoryCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: StoryCell.identifier,
      for: indexPath
    ) as! StoryCell
    
    cell.story = self.stories[indexPath.row]
    
    cell.update()
    
    return cell
  }
  
  fileprivate func storySectionHeader(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionReusableView {
    let cover = collectionView.dequeueReusableSupplementaryView(
      ofKind: UICollectionElementKindSectionHeader,
      withReuseIdentifier: CoverStory.identifier,
      for: indexPath
      ) as! CoverStory
    
    if let coverStory = self.coverStory {
      cover.backgroundImage = coverStory.cover
      cover.title = coverStory.title
      cover.subtitle = (coverStory.genre.rawValue, "by", coverStory.author)
      cover.isHeroEnabled = true
      cover.didTapGestureEnabled = true
      cover.didTap = { self.userDidRequestStory?(coverStory.id) }
      cover.update()
    }
    
    return cover
  }
  
  fileprivate func allStoryHeader(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: UICollectionElementKindSectionHeader,
      withReuseIdentifier: AllStoryHeader.identifier,
      for: indexPath
    ) as! AllStoryHeader
    
    header.update()
    
    return header
  }
}
