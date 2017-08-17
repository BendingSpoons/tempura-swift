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

class DependenciesTestView: UIView, ModellableView {
  
  typealias VM = DependenciesTestViewModel
  
  var model: DependenciesTestViewModel = DependenciesTestViewModel() {
    didSet {
      self.update(oldModel: oldValue)
    }
  }
  
  // MARK: - SUBVIEWS
  
  lazy var label: UILabel = {
    let b = UILabel()
    return b
  }()
  
  // MARK: - SETUP
  func setup() {
    // add subviews
    self.addSubview(self.label)
  }
  
  // MARK: - STYLE
  func style() {
    self.backgroundColor = App.Style.Palette.white
    self.label.text = "this viewController\nhas dependencies"
    self.label.numberOfLines = 0
    self.label.textAlignment = .center
    self.label.textColor = App.Style.Palette.black
    self.label.font = App.Style.Font.h2
  }
  
  // MARK: - UPDATE
  func update(oldModel: DependenciesTestViewModel) {
  }
  
  // MARK: - INTERACTION
  
  // MARK: - LAYOUT
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }
  
  func layout() {
    self.label.pin.size(CGSize(width: 250, height: 100))
    self.label.pin.center()
  }
}
