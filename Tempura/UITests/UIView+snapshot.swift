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
    
    let snapshot = self.takeSnapshot()
    
    if removeFromSuperview {
      self.removeFromSuperview()
    }
    
    return snapshot
  }
  
  func snapshotAsync(viewToWaitFor: UIView? = nil, isViewReadyClosure: @escaping (UIView) -> Bool, _ completionClosure: @escaping (UIImage?) -> Void) {
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
    
    self.snapshotAsyncImpl(viewToWaitFor: viewToWaitFor, isViewReadyClosure: isViewReadyClosure) { snapshot in
      if removeFromSuperview {
        self.removeFromSuperview()
      }
      
      completionClosure(snapshot)
    }
  }
  
  func snapshotAsyncImpl(viewToWaitFor: UIView? = nil,
                         isViewReadyClosure: @escaping (UIView) -> Bool,
                         _ completionClosure: @escaping (UIImage?) -> Void) {
    
    let viewToWaitFor = viewToWaitFor ?? self
    guard isViewReadyClosure(viewToWaitFor) else {
      DispatchQueue.main.async {
        self.snapshotAsyncImpl(viewToWaitFor: viewToWaitFor, isViewReadyClosure: isViewReadyClosure, completionClosure)
      }
      
      return
    }
    
    completionClosure(self.takeSnapshot())
  }
  
  private func takeSnapshot() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return snapshot
  }
}
