//
//  StoryChatView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import PinLayout
import Hero
import Tempura

class StoryCoverView: UIView, ViewControllerModellableView {
  typealias VM = StoryCoverViewModel
  
  // MARK: - SUBVIEWS
  
  // background image
  lazy var backgroundImage: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "photo")
    iv.heroID = "coverBackground"
    return iv
  }()
  
  lazy var closeButton: UIButton = {
    let b = UIButton(type: .custom)
    //b.setImage(UIImage(named:"close")!, for: .normal)
    b.backgroundColor = .blue
    return b
  }()
  
  // title
  lazy var title: UILabel = {
    let l = UILabel()
    l.numberOfLines = 0
    l.heroModifiers = [.fade]
    //l.heroID = "coverTitle"
    return l
  }()
  
  // subtitle
  lazy var subtitle: UILabel = {
    let l = UILabel()
    //l.heroID = "coverSubtitle"
    l.heroModifiers = [.fade]
    return l
  }()
  
  // description
  lazy var descr: UILabel = {
    let l = UILabel()
    l.numberOfLines = 0
    l.heroModifiers = [.fade]
    return l
  }()
  
  // start reading button
  lazy var startReading: UIButton = {
    let b = UIButton(type: .custom)
    return b
  }()
  
  // MARK: - SETUP

  func setup() {
    // add subviews
    self.addSubview(self.backgroundImage)
    self.addSubview(self.closeButton)
    self.addSubview(self.title)
    self.addSubview(self.subtitle)
    self.addSubview(self.descr)
    self.addSubview(self.startReading)
    self.closeButton.on(.touchUpInside) { [weak self] button in
      self?.closeButtonDidTap?()
    }
  }
  
  // MARK: - STYLE
  func style() {
    self.title.textAlignment = .left
    self.title.font = App.Style.Font.h1
    self.title.textColor = App.Style.Palette.white
    self.subtitle.textAlignment = .left
    self.descr.textAlignment = .left
    self.descr.textColor = App.Style.Palette.dirtWhite
  }
  
  // MARK: - UPDATE
  func update(oldModel: StoryCoverViewModel?) {
    self.backgroundImage.image = self.model.cover
    self.title.attributedText = self.attributedStringForTitle(title: self.model.title)
    self.subtitle.attributedText = self.attributedStringForSubtitleComponents(components: self.model.subtitleComponents)
    self.descr.attributedText = self.attributedStringForDescription(description: self.model.description)
  }
  
  private func attributedStringForSubtitleComponents(components: StoryCoverViewModel.SubtitleComponents) -> NSAttributedString {
    let firstFont = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
    let color = App.Style.Palette.yellowish
    let secondFont = App.Style.Font.system(size: 20)
    let partOne = NSMutableAttributedString(string: components.0 + " ",
                                            attributes: [
                                              NSForegroundColorAttributeName: color,
                                              NSFontAttributeName: firstFont
                                              ])
    let partTwo = NSMutableAttributedString(string: components.1 + " ",
                                            attributes: [
                                              NSForegroundColorAttributeName: color,
                                              NSFontAttributeName: secondFont
      ])
    
    let partThree = NSMutableAttributedString(string: components.2,
                              attributes: [
                                NSForegroundColorAttributeName: color,
                                NSFontAttributeName: firstFont
      ])
    
    let attributedString = NSMutableAttributedString(attributedString: partOne)
    attributedString.append(partTwo)
    attributedString.append(partThree)
    return attributedString
  }
  
  private func attributedStringForTitle(title: String) -> NSAttributedString {
    let attrString = NSMutableAttributedString(string: title)
    let style = NSMutableParagraphStyle()
    //style.lineSpacing = 0
    style.minimumLineHeight = 34
    style.maximumLineHeight = 34
    attrString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: title.characters.count))
    return attrString
  }
  
  private func attributedStringForDescription(description: String) -> NSAttributedString {
    let attrString = NSMutableAttributedString(string: description)
    let style = NSMutableParagraphStyle()
    //style.lineSpacing = 0
    style.minimumLineHeight = 22
    style.maximumLineHeight = 22
    attrString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: description.characters.count))
    return attrString
  }
  
  // MARK: - INTERACTION
  var closeButtonDidTap: Interaction?
  
  // MARK: - LAYOUT
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.backgroundImage.pin.size(of: self)
    self.closeButton.pin.size(CGSize(width: 44.0, height: 44.0))
    self.closeButton.pin.topLeft().margin(20)
    self.descr.pin.height(66.0)
    self.descr.pin.left(20).right(20).bottom(100)
    self.subtitle.pin.height(30)
    self.subtitle.pin.bottom(to: self.descr.edge.top).margin(20)
    self.subtitle.pin.left(20).right(20)
    self.title.pin.width(240.0).height(120)
    self.title.pin.bottom(to: self.descr.edge.top).margin(20)
    self.title.pin.left(20)
  }
}
