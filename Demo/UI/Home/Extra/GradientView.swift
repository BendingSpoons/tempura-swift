//
//  GradientView.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 14/07/2017.
//

import Foundation
import UIKit

final class GradientView: UIView {
  private var shouldUpdate = true
  
  override var frame: CGRect {
    didSet {
      self.gradientLayer.frame = self.bounds
    }
  }
  
  var colors: [UIColor] = [] {
    didSet {
      self.shouldUpdate = self.shouldUpdate || (self.colors != oldValue)
    }
  }
  
  var locations: [CGFloat] = [] {
    didSet {
      self.shouldUpdate = self.shouldUpdate || (self.locations != oldValue)
    }
  }
  
  var startPoint: CGPoint = .zero {
    didSet {
      self.shouldUpdate = self.shouldUpdate || (self.startPoint != oldValue)
    }
  }
  
  var endPoint: CGPoint = .zero {
    didSet {
      self.shouldUpdate = self.shouldUpdate || (self.endPoint != oldValue)
    }
  }
  
  lazy var gradientLayer: CAGradientLayer = {
    return CAGradientLayer()
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
    self.layer.addSublayer(self.gradientLayer)
  }
  
  func update() {
    guard self.shouldUpdate else {
      return
    }
    
    self.shouldUpdate = false
    
    self.gradientLayer.colors = self.colors.map { $0.cgColor }
    self.gradientLayer.locations = self.locations as [NSNumber]
    self.gradientLayer.startPoint = self.startPoint
    self.gradientLayer.endPoint = self.endPoint
  }
}
