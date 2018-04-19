//
//  UIView+snapshot.swift
//  Tempura
//
//  Created by Andrea De Angelis on 19/04/2018.
//

import UIKit

/// Create a snapshot image of self
extension UIView {
  func snapshot() -> UIImage? {
    let window: UIWindow?
    var removeFromSuperview: Bool = false
    
    if let w = self as? UIWindow {
      window = w
    } else if let w = self.window {
      window = w
    } else {
      window = UIApplication.shared.keyWindow
      window?.addSubview(self)
      removeFromSuperview = true
    }
    
    self.layoutIfNeeded()
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if removeFromSuperview {
      self.removeFromSuperview()
    }
    
    return snapshot
  }
}
