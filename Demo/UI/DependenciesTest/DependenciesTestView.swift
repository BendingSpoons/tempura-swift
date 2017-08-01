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

class DependenciesTestView: ModellableView<DependenciesTestViewModel> {
  
  // MARK: - SUBVIEWS
  
  lazy var label: UILabel = {
    let b = UILabel()
    return b
  }()
  
  // MARK: - SETUP
  override func setup() {
    // add subviews
    self.addSubview(self.label)
  }
  
  // MARK: - STYLE
  override func style() {
    self.backgroundColor = App.Style.Palette.white
    self.label.text = "this viewController\nhas dependencies"
    self.label.numberOfLines = 0
    self.label.textAlignment = .center
    self.label.textColor = App.Style.Palette.black
    self.label.font = App.Style.Font.h2
  }
  
  // MARK: - UPDATE
  override func update(oldModel: DependenciesTestViewModel) {
  }
  
  // MARK: - INTERACTION
  
  // MARK: - LAYOUT
  
  override func layout() {
    self.label.pin.size(CGSize(width: 250, height: 100))
    self.label.pin.center()
  }
}
