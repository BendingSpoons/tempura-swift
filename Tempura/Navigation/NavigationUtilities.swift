//
//  ModalViewController.swift
//  Tempura
//
//  Created by Andrea De Angelis on 25/08/2017.
//
//

import UIKit


fileprivate var toBeDismissedKey = "view_controller_to_be_dismissed"

public extension UIViewController {
  /// make possible to present C from A even when A is already presenting something
  public func recursivePresent(_ viewController: UIViewController, animated: Bool = false, completion: (() -> Void)?) {
    // check if we are already presenting something, if so, ask the presented to present the viewController
    if let vc = self.presentedViewController {
      vc.recursivePresent(viewController, animated: animated, completion: completion)
    } else {
      viewController.toBeDismissed = false
      self.present(viewController, animated: animated, completion: completion)
    }
    
  }
  /// dismiss self but keep the children in the hierarchy
  public func softDismiss(animated: Bool = false, completion: (() -> Void)?) {
    // check if the viewController to dismiss is actually a modal
    guard let presentingViewController = self.presentingViewController else { return }
    // check if the viewController is presenting something (not marked as toBeDismissed)
    // if so, we cannot dismiss it (otherwise it will dismiss all the segues)
    // but we mark it as `toBeDismissed`
    if let presentedViewController = self.presentedViewController, !presentedViewController.toBeDismissed {
      self.toBeDismissed = true
    } else {
      // this viewController can be dismissed now, let's check if the parent is marked as `toBeDismissed`
      // in that case invoke `tempuraDismiss` on that
      if presentingViewController.toBeDismissed {
        self.toBeDismissed = true
        presentingViewController.softDismiss(animated: animated, completion: completion)
      } else {
        // dismiss the viewController
        presentingViewController.dismiss(animated: animated, completion: completion)
      }
    }
  }
  
  public var toBeDismissed: Bool {
    get {
      let value = objc_getAssociatedObject(self, &toBeDismissedKey) as? NSNumber
      return value?.boolValue ?? false
    }
    
    set {
      let value = NSNumber(booleanLiteral: newValue)
      objc_setAssociatedObject(
        self,
        &toBeDismissedKey,
        value,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}
