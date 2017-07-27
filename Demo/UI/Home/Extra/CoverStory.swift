//
//  CoverStory.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit
import PinLayout
import BonMot

class CoverStory: UICollectionReusableView {
  static let identifier = String(reflecting: CoverStory.self)

  typealias SubTitlePieces = (genre: String, connector: String, author: String)
  
  var backgroundImage: UIImage?
  var title: String = ""
  var subtitle: SubTitlePieces = ("", "", "")
  var didTap: (() -> ())?
  
  var didTapGestureEnabled: Bool = false {
    didSet {
      guard oldValue != self.didTapGestureEnabled else { return }
      self.didTapGestureEnabled ? self.installDidTapGesture() : self.removeDidTapGesture()
    }
  }
  
  var isHeroEnabled: Bool = false {
    didSet {
      guard oldValue != self.isHeroEnabled else { return }
      self.isHeroEnabled ? self.installHeroIDs() : self.removeHeroIDs()
    }
  }
  
  private var tapGestureRecognizer: UITapGestureRecognizer?
  
  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.autoresizingMask = .flexibleHeight
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    
    return label
  }()
  
  private lazy var subTitleLabel: UILabel = {
    let label = UILabel()
    
    return label
  }()
  
  private lazy var overlayView: UIView = {
    let v = UIView()
    v.isUserInteractionEnabled = false
    return v
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.clipsToBounds = true
    
    self.addSubview(self.backgroundImageView)
    self.addSubview(self.overlayView)
    self.addSubview(self.titleLabel)
    self.addSubview(self.subTitleLabel)
    
    self.didTapGestureEnabled ? self.installDidTapGesture() : self.removeDidTapGesture()
    self.isHeroEnabled ? self.installHeroIDs() : self.removeHeroIDs()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func installDidTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapGestureFired))
    self.tapGestureRecognizer = tapGesture
    self.backgroundImageView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func didTapGestureFired() {
    self.didTap?()
  }
  
  private func removeDidTapGesture() {
    guard let tapGesture = self.tapGestureRecognizer else { return }
    self.backgroundImageView.removeGestureRecognizer(tapGesture)
    self.tapGestureRecognizer = nil
  }
  
  private func installHeroIDs() {
    self.backgroundImageView.heroID = "coverBackground"
    //self.titleLabel.heroID = "coverTitle"
    //self.subTitleLabel.heroID = "coverSubtitle"
    self.titleLabel.heroModifiers = [.fade]
    self.subTitleLabel.heroModifiers = [.fade]
    self.overlayView.heroModifiers = [.fade]
  }
  
  private func removeHeroIDs() {
    self.backgroundImageView.heroID = nil
    self.titleLabel.heroID = nil
    self.subTitleLabel.heroID = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }
  
  func update() {
    
    self.backgroundImageView.image = self.backgroundImage
    self.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
    
    self.titleLabel.attributedText = self.title.uppercased().styled(with: StringStyle(
      .font(App.Style.Font.AvenirNext.bold(size: 29)),
      .color(UIColor(rgbHex: "#F4EDE8"))
    ))
    
    let genrePart = self.subtitle.genre.styled(with: StringStyle(
      .font(App.Style.Font.h3.boldVersion),
      .color(UIColor(rgbHex: "#E1D8C7"))
    ))
    
    let connectorPart = self.subtitle.connector.styled(with: StringStyle(
      .font(App.Style.Font.h3),
      .color(UIColor(rgbHex: "#E1D8C7"))
    ))
    
    let authorPart = self.subtitle.author.styled(with: StringStyle(
      .font(App.Style.Font.h3.boldVersion),
      .color(UIColor(rgbHex: "#E1D8C7"))
    ))
    
    self.subTitleLabel.attributedText = NSAttributedString.composed(of: [
      genrePart, " ", connectorPart, " ", authorPart
    ])
    
    self.setNeedsLayout()
  }
  
  private func layout() {
    self.backgroundImageView.pin
      .size(max(self.frame.height, self.frame.width))
      .center()
    
    self.overlayView.pin.topLeft().bottomRight()
    
    self.subTitleLabel.sizeToFit()
    self.subTitleLabel.pin.left(17).bottom(12)
    
    self.titleLabel.sizeToFit()
    self.titleLabel.pin
      .left(17)
      .bottom(to: self.subTitleLabel.edge.top)
      .marginBottom(5)
  }
}
