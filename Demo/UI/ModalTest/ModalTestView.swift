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

class ModalTestView: UIView, ViewControllerModellableView {
  typealias VM = ModalTestViewModel
  
  // MARK: - SUBVIEWS
  
  lazy var closeButton: UIButton = {
    let b = UIButton(type: .custom)
    //b.setImage(UIImage(named:"close")!, for: .normal)
    return b
  }()
  
  lazy var presentButton: UIButton = {
    let b = UIButton(type: .custom)
    //b.setImage(UIImage(named:"close")!, for: .normal)
    return b
  }()
  
  // MARK: - SETUP
  
  func setup() {
    // add subviews
    self.addSubview(self.closeButton)
    self.addSubview(self.presentButton)
    
    self.closeButton.on(.touchUpInside) { [weak self] button in
      self?.closeButtonDidTap?()
    }
    
    self.presentButton.on(.touchUpInside) { [weak self] button in
      self?.presentButtonDidTap?()
    }
  
  }
  
  // MARK: - STYLE
  func style() {
    self.backgroundColor = .white
    self.closeButton.backgroundColor = .red
    self.presentButton.backgroundColor = .blue
    self.closeButton.setTitle("dismiss modal", for: .normal)
    self.presentButton.setTitle("present modal", for: .normal)
  }
  
  // MARK: - UPDATE
  func update(oldModel: ModalTestViewModel?) {}
  
  // MARK: - INTERACTION
  var closeButtonDidTap: Interaction?
  var presentButtonDidTap: Interaction?
  
  // MARK: - LAYOUT
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.closeButton.pin.size(CGSize(width: 150, height: 60))
    self.presentButton.pin.size(of: self.closeButton)
    
    self.closeButton.pin.left().margin(20)
    self.closeButton.pin.vCenter()
    
    self.presentButton.pin.right().margin(20)
    self.presentButton.pin.vCenter()
  }
}
