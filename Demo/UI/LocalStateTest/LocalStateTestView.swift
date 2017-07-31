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

class LocalStateTestView: ModellableView<LocalStateTestViewModel> {
  
  // MARK: - SUBVIEWS
  
  lazy var globalCounterLabel: UILabel = {
    let l = UILabel()
    return l
  }()
  
  lazy var localCounterLabel: UILabel = {
    let l = UILabel()
    return l
  }()
  
  lazy var subButton: UIButton = {
    let b = UIButton(type: .custom)
    //b.setImage(UIImage(named:"close")!, for: .normal)
    return b
  }()
  
  lazy var addButton: UIButton = {
    let b = UIButton(type: .custom)
    //b.setImage(UIImage(named:"close")!, for: .normal)
    return b
  }()
  
  // MARK: - SETUP
  override func setup() {
    // add subviews
    self.addSubview(self.globalCounterLabel)
    self.addSubview(self.localCounterLabel)
    self.addSubview(self.subButton)
    self.addSubview(self.addButton)
    self.subButton.addTarget(self, action: #selector(self.subButtonTap), for: .touchUpInside)
    self.addButton.addTarget(self, action: #selector(self.addButtonTap), for: .touchUpInside)
  }
  
  // MARK: - STYLE
  override func style() {
    self.backgroundColor = .white
    self.subButton.backgroundColor = .red
    self.subButton.setTitle("sub local counter", for: .normal)
    self.addButton.backgroundColor = .blue
    self.addButton.setTitle("add local counter", for: .normal)
    self.globalCounterLabel.font = App.Style.Font.h2
    self.globalCounterLabel.textAlignment = .center
    self.globalCounterLabel.textColor = App.Style.Palette.black
    self.localCounterLabel.font = App.Style.Font.h2
    self.localCounterLabel.textAlignment = .center
    self.localCounterLabel.textColor = App.Style.Palette.black
  }
  
  // MARK: - UPDATE
  override func update(model: LocalStateTestViewModel, oldModel: LocalStateTestViewModel) {
    self.globalCounterLabel.text = model.globalCounterString
    self.localCounterLabel.text = model.localCounterString
  }
  
  // MARK: - INTERACTION
  var subButtonDidTap: Interaction?
  var addButtonDidTap: Interaction?
  
  @objc private func subButtonTap() {
    self.subButtonDidTap?()
  }
  
  @objc private func addButtonTap() {
    self.addButtonDidTap?()
  }
  
  // MARK: - LAYOUT
  
  override func layout(model: LocalStateTestViewModel) {
    self.globalCounterLabel.pin.size(CGSize(width: 300.0, height: 60.0))
    self.globalCounterLabel.pin.hCenter()
    self.globalCounterLabel.pin.top()
    self.localCounterLabel.pin.size(of: self.globalCounterLabel)
    self.localCounterLabel.pin.top(to: self.globalCounterLabel.edge.bottom)
    self.localCounterLabel.pin.hCenter()
    self.subButton.pin.width(150).height(80).left().top(to: self.localCounterLabel.edge.bottom)
    self.addButton.pin.width(150).height(80).right().top(to: self.localCounterLabel.edge.bottom)
  }
}
