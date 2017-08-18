//
//  StoryCell.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit
import BonMot
import PinLayout
import Hero
import Tempura

class StoryCell: UICollectionViewCell, LiveReloadView {
  static let identifier = String(reflecting: StoryCell.self)
  
  var story: Story?
  
  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var subTitleLabel: UILabel = {
    return UILabel()
  }()
  
  private lazy var whiteGradientView: GradientView = {
    let gradientView = GradientView()
    gradientView.isUserInteractionEnabled = false
    return gradientView
  }()
  
  private lazy var blackGradientView: GradientView = {
    let gradientView = GradientView()
    gradientView.isUserInteractionEnabled = false
    return gradientView
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
    self.contentView.addSubview(self.backgroundImageView)
    self.backgroundImageView.addSubview(self.whiteGradientView)
    self.backgroundImageView.addSubview(self.blackGradientView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.subTitleLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }
  
  func update() {
    guard let story = self.story else {
      return
    }
    
    self.contentView.backgroundColor = .black
    
    self.backgroundImageView.image = story.cover
    self.backgroundImageView.layer.cornerRadius = 7
    
    self.whiteGradientView.colors = [UIColor(white: 1, alpha: 0.2), .clear]
    self.whiteGradientView.startPoint = CGPoint(x: 0.5, y: 1.0)
    self.whiteGradientView.endPoint = CGPoint(x: 0.5, y: 0.0)
    self.whiteGradientView.locations = [0.0, 1.0]
    self.whiteGradientView.update()
    
    self.blackGradientView.colors = [UIColor(white: 0, alpha: 0.2), .clear]
    self.blackGradientView.startPoint = self.whiteGradientView.startPoint
    self.blackGradientView.endPoint = self.whiteGradientView.endPoint
    self.blackGradientView.locations = self.whiteGradientView.locations
    self.blackGradientView.update()
    
    self.titleLabel.attributedText = story.title.uppercased().styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 21, weight: UIFontWeightBold)),
      .color(.white)
    ))
    
    let genrePart = story.genre.rawValue.styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold)),
      .color(.white)
    ))
    
    let connectorPart = "by".styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 11, weight: UIFontWeightRegular)),
      .color(.white)
    ))
    
    let authorPart = story.author.styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold)),
      .color(.white)
    ))
    
    self.subTitleLabel.attributedText = NSAttributedString.composed(of: [
      genrePart, " ", connectorPart, " ", authorPart
      ])
    
    self.setNeedsLayout()
  }
  
  func viewDidLiveReload() {
    self.update()
    self.layout()
  }
  
  private func layout() {

    self.backgroundImageView.pin.topLeft().bottomRight()
  
    self.whiteGradientView.pin.left().bottom().right().height(100)
    self.blackGradientView.pin.left().bottom().right().height(100)
    
    self.subTitleLabel.sizeToFit()
    self.subTitleLabel.pin.left(13).bottom(13)
    
    let size = self.titleLabel.textRect(
      forBounds: CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: self.frame.height),
      limitedToNumberOfLines: 0
      ).size
    
    self.titleLabel.pin
      .size(size)
      .left(13)
      .bottom(to: self.subTitleLabel.edge.top)
      .marginBottom(5)
  }
}
