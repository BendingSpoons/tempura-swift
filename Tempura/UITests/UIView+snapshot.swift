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
  
  func snapshotAsync(viewToWaitFor: UIView? = nil,
                     configureClosure: ((UIViewController) -> Void)?,
                     isViewReadyClosure: @escaping (UIView) -> Bool,
                     shouldRenderSafeArea: Bool,
                     _ completionClosure: @escaping (UIImage?) -> Void) {
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

    if let vc = viewToWaitFor?.next as? UIViewController {
      configureClosure?(vc)
    }
    
    self.layoutIfNeeded()
    
    self.snapshotAsyncImpl(viewToWaitFor: viewToWaitFor, isViewReadyClosure: isViewReadyClosure, shouldRenderSafeArea: shouldRenderSafeArea) { snapshot in
      if removeFromSuperview {
        self.removeFromSuperview()
      }
      
      completionClosure(snapshot)
    }
  }
  
  func snapshotAsyncImpl(viewToWaitFor: UIView? = nil,
                         isViewReadyClosure: @escaping (UIView) -> Bool,
                         shouldRenderSafeArea: Bool,
                         _ completionClosure: @escaping (UIImage?) -> Void) {
    
    let viewToWaitFor = viewToWaitFor ?? self
    guard isViewReadyClosure(viewToWaitFor) else {
      DispatchQueue.main.async {
        self.snapshotAsyncImpl(viewToWaitFor: viewToWaitFor, isViewReadyClosure: isViewReadyClosure, shouldRenderSafeArea: shouldRenderSafeArea, completionClosure)
      }
      
      return
    }
    
    completionClosure(self.takeSnapshot(shouldRenderSafeArea: shouldRenderSafeArea))
  }
  
  private func takeSnapshot(shouldRenderSafeArea: Bool = false) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)

    if shouldRenderSafeArea, UIScreen.main.bounds == self.bounds, let context = UIGraphicsGetCurrentContext() {
      let topRect = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: self.universalSafeAreaInsets.top))

      let bottomSize = CGSize(width: self.bounds.width, height: self.universalSafeAreaInsets.bottom)
      let bottomOrigin = CGPoint(x: 0, y: self.bounds.height - bottomSize.height)
      let bottomRect = CGRect(origin: bottomOrigin, size: bottomSize)

      let leftSize = CGSize(width: self.universalSafeAreaInsets.left, height: self.bounds.height)
      let leftOrigin = CGPoint(x: self.bounds.width - leftSize.width, y: 0)
      let leftRect = CGRect(origin: leftOrigin, size: leftSize)

      let rightRect = CGRect(origin: .zero, size: CGSize(width: self.universalSafeAreaInsets.right, height: self.bounds.height))

      context.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)

      context.fill(topRect)
      context.fill(bottomRect)
      context.fill(leftRect)
      context.fill(rightRect)
    }
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return snapshot
  }
}
