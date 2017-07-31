//
//  StorySectionCell.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit
import BonMot

final class StorySectionCell: UICollectionViewCell {
  static let identifier = String(reflecting: StorySectionCell.self)

  enum Section: Int {
    case reading = 0
    case trending = 1
    case newFromCommunity = 2
    
    fileprivate var title: String {
      switch self {
      case .reading:
        return "You're Reading"
        
      case .trending:
        return "Trending Stories"
        
      case .newFromCommunity:
        return "New from the community"
      }
    }
  }
  
  var stories: [Story] = []
  var section: Section = .reading
  
  var userDidRequestStory: HomeView.UserDidRequestStory? {
    get { return self.sectionCollection.userDidRequestStory }
    set { self.sectionCollection.userDidRequestStory = newValue }
  }
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  private lazy var sectionCollection: SectionCollectionView = {
    return SectionCollectionView()
  }()
  
  private lazy var gradientView: GradientView = {
    let view = GradientView()
    view.isUserInteractionEnabled = false
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  private func setup() {
    self.contentView.addSubview(self.sectionCollection)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.gradientView)
  }
  
  func update() {
    self.setNeedsLayout()
    
    self.contentView.backgroundColor = .black
    
    self.gradientView.colors = [.clear, .black]
    self.gradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
    self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
    self.gradientView.locations = [0.0, 1.0]
    self.gradientView.update()
    
    self.titleLabel.attributedText = self.section.title.styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)),
      .color(.white)
    ))
    
    self.sectionCollection.stories = self.stories
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }
  
  private func layout() {
    self.gradientView.pin.bottom().right().top().width(100)
    
    self.titleLabel.sizeToFit()
    self.titleLabel.pin.left(15).top(20)
    
    self.sectionCollection.pin
      .bottomLeft()
      .right()
      .top(to: self.titleLabel.edge.bottom)
      .marginTop(12)
  }
  
  func storyIDForViewLocation(_ location: CGPoint) -> Story.ID? {
    let collectionLocation = self.sectionCollection.convert(location, from: self)
    
    guard let indexPath = self.sectionCollection.indexPathForItem(at: collectionLocation) else {
      return nil
    }
    
    return self.stories[indexPath.row % self.stories.count].id
  }
}

// MARK: - Internal Collection

private final class SectionCollectionView: UICollectionView {
  private let customDelegate: SectionCollectionDelegate
  
  var userDidRequestStory: HomeView.UserDidRequestStory? {
    get { return self.customDelegate.userDidRequestStory }
    set { self.customDelegate.userDidRequestStory = newValue }
  }
  
  var stories: [Story] {
    get {
      return self.customDelegate.stories
    }
    
    set {
      self.customDelegate.stories = newValue
      self.reloadData()
    }
  }
  
  fileprivate init() {
    self.customDelegate = SectionCollectionDelegate()
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    layout.minimumLineSpacing = 19
    layout.minimumInteritemSpacing = 0
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 200, height: 200)
    
    super.init(frame: .zero, collectionViewLayout: layout)
    
    self.setup()
  }
  
  private func setup() {
    self.delegate = self.customDelegate
    self.dataSource = self.customDelegate
    
    self.showsVerticalScrollIndicator = false
    self.showsHorizontalScrollIndicator = false
    
    self.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}

private final class SectionCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
  var stories: [Story]
  var userDidRequestStory: HomeView.UserDidRequestStory?
  
  override init() {
    self.stories = []
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 100000//Int.max//self.stories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: StoryCell.identifier,
      for: indexPath
    ) as! StoryCell
    
    cell.story = self.stories[indexPath.row % self.stories.count]
    cell.update()
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let story = self.stories[indexPath.row % self.stories.count]
    self.userDidRequestStory?(story.id)
  }
}
