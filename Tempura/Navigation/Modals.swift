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
  public func tempuraPresent(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    // check if we are already presenting something, if so, ask the presented to present the viewController
    if let vc = self.presentedViewController {
      vc.tempuraPresent(viewController: viewController, animated: true, completion: completion)
    } else {
      self.present(viewController, animated: animated, completion: completion)
    }
    
  }
  
  public func tempuraDismiss(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    // check if the viewController to dismiss is actually a modal
    guard let presentingViewController = viewController.presentingViewController else { return }
    // check if the viewController is presenting something (not marked as toBeDismissed)
    // if so, we cannot dismiss it (otherwise it will dismiss all the segues)
    // but we mark it as `toBeDismissed`
    if let presentedViewController = viewController.presentedViewController, !presentedViewController.toBeDismissed {
      viewController.toBeDismissed = true
    } else {
      // this viewController can be dismissed now, let's check if the parent is marked as `toBeDismissed`
      // in that case invoke `tempuraDismiss` on that
      if presentingViewController.toBeDismissed {
        viewController.toBeDismissed = true
        self.tempuraDismiss(viewController: presentingViewController, animated: animated, completion: completion)
      } else {
        viewController.dismiss(animated: animated, completion: completion)
      }
    }
  }
  
  public var toBeDismissed: Bool {
    get {
      let value = objc_getAssociatedObject(self, &toBeDismissedKey) as! NSNumber
      return value.boolValue
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
  
  public func tempuraDismiss(animated: Bool = false, completion: (() -> Void)?) {
    self.tempuraDismiss(viewController: self, animated: animated, completion: completion)
  }
}
