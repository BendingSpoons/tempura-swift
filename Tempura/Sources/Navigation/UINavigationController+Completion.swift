//
//  UINavigationController+Completion.swift
//  Tempura
//
//  Created by Andrea De Angelis on 02/07/2018.
//

import UIKit

public extension UINavigationController {
  
  /// Helper method to trigger the completion callback right after a navigation transition ends
  private func completionHelper(for completion: (() -> ())?) {
    if let transitionCoordinator = self.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { _ in
        completion?()
      }
    } else {
      completion?()
    }
  }
  
  /// `pushViewController` method with completion callback
  func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
    self.pushViewController(viewController, animated: animated)
    self.completionHelper(for: completion)
  }
  
  /// `popViewController` method with completion callback
  func popViewController(animated: Bool, completion: (() -> ())?) {
    self.popViewController(animated: animated)
    self.completionHelper(for: completion)
  }
  
  /// `popToRootViewController` method with completion callback
  func popToRootViewController(animated: Bool, completion: (() -> ())?) {
    self.popToRootViewController(animated: animated)
    self.completionHelper(for: completion)
  }
  
  /// `popToViewController` method with completion callback
  func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
    self.popToViewController(viewController, animated: animated)
    self.completionHelper(for: completion)
  }
}
