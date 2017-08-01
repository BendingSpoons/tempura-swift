//
//  AnimationTestView.swift
//  Tempura
//
//  Created by Andrea De Angelis on 01/08/2017.
//
//

import Foundation
import Tempura
import PinLayout

class AnimationTestView: ModellableView<AnimationTestViewModel> {
  
  // MARK: - SUBVIEWS
  lazy var button: UIButton = {
    let b = UIButton(type: .custom)
    return b
  }()
  
  var expanded: Bool = false {
    didSet {
      if expanded != oldValue {
        UIView.animate(withDuration: 0.3, animations: {
          self.setNeedsLayout()
          self.layoutIfNeeded()
        })
      }
    }
  }
  
  // MARK: - SETUP
  override func setup() {
    // add the subviews to self
    self.addSubview(self.button)
    // setup handlers for buttons if needed
    self.button.addTarget(self, action: #selector(self.buttonTap), for: .touchUpInside)
  }
  
  // MARK: - STYLE
  override func style() {
    // change all the visual properties of self and the subviews
    // note that all the properties that depends on the state should go under `update` method
    self.button.backgroundColor = App.Style.Palette.red
  }
  
  // MARK: - UPDATE
  override func update(oldModel: AnimationTestViewModel) {
    self.expanded = self.model.expanded
  }
  
  // MARK: - INTERACTION
  
   var buttonDidTap: Interaction?
  
   @objc private func buttonTap() {
    self.buttonDidTap?()
   }
  
  // MARK: - LAYOUT
  override func layout() {
    if self.expanded {
      self.button.frame = self.bounds
    } else {
      self.button.pin.width(100).height(60).bottomCenter().margin(50)
    }
  }
}
