//
//  AllStoryHeader.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit
import PinLayout
import BonMot

class AllStoryHeader: UICollectionReusableView {
  static let identifier = String(reflecting: AllStoryHeader.self)
  
  var title: String = "Discover All The Stories"
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    return label
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
    self.clipsToBounds = true
    self.addSubview(self.titleLabel)
  }
  
  func update() {
    
    self.backgroundColor = .black
    
    self.titleLabel.attributedText = self.title.styled(with: StringStyle(
      .font(UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)),
      .color(UIColor(rgbHex: "#6D6976"))
    ))
    
    self.setNeedsLayout()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.titleLabel.sizeToFit()
    self.titleLabel.pin.center()
  }
}
