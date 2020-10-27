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
                     configureClosure: (() -> Void)?,
                     isViewReadyClosure: @escaping (UIView) -> Bool,
                     shouldRenderSafeArea: Bool,
                     keyboardVisibility: UITests.KeyboardVisibility,
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

    self.layoutIfNeeded()
    
    configureClosure?()
    
    self.snapshotAsyncImpl(
      viewToWaitFor: viewToWaitFor,
      isViewReadyClosure: isViewReadyClosure,
      shouldRenderSafeArea: shouldRenderSafeArea,
      keyboardVisibility: keyboardVisibility
    ) { snapshot in
      if removeFromSuperview {
        self.removeFromSuperview()
      }
      
      completionClosure(snapshot)
    }
  }
  
  func snapshotAsyncImpl(viewToWaitFor: UIView? = nil,
                         isViewReadyClosure: @escaping (UIView) -> Bool,
                         shouldRenderSafeArea: Bool,
                         keyboardVisibility: UITests.KeyboardVisibility,
                         _ completionClosure: @escaping (UIImage?) -> Void) {
    
    let viewToWaitFor = viewToWaitFor ?? self
    guard isViewReadyClosure(viewToWaitFor) else {
      DispatchQueue.main.async {
        self.snapshotAsyncImpl(
          viewToWaitFor: viewToWaitFor,
          isViewReadyClosure: isViewReadyClosure,
          shouldRenderSafeArea: shouldRenderSafeArea,
          keyboardVisibility: keyboardVisibility,
          completionClosure
        )
      }
      
      return
    }
    
    completionClosure(self.takeSnapshot(shouldRenderSafeArea: shouldRenderSafeArea, keyboardVisibility: keyboardVisibility))
  }
  
  private func takeSnapshot(shouldRenderSafeArea: Bool = false, keyboardVisibility: UITests.KeyboardVisibility = .hidden) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)

    renderSafeAreaIfNeeded(shouldRenderSafeArea: shouldRenderSafeArea)

    renderKeyboardIfNeeded(keyboardVisibility: keyboardVisibility)

    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return snapshot
  }

  private func renderKeyboardIfNeeded(keyboardVisibility: UITests.KeyboardVisibility) {
    let orientation: UIDeviceOrientation = self.frame.size.height > self.frame.size.width ? .portrait : .landscapeLeft
    let keyboardHeight = keyboardVisibility.height(for: orientation)
    if keyboardHeight > 0, UIScreen.main.bounds == self.bounds, let context = UIGraphicsGetCurrentContext() {
      let keyboardSize = CGSize(width: self.bounds.width, height: keyboardHeight)
      let keyboardOrigin = CGPoint(x: 0, y: self.bounds.height - keyboardSize.height)
      let bottomRect = CGRect(origin: keyboardOrigin, size: keyboardSize)
      context.setFillColor(UIColor.gray.cgColor)
      context.fill(bottomRect)
    }
  }

  private func renderSafeAreaIfNeeded(shouldRenderSafeArea: Bool) {
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
  }
}
