//
//  UINavigationController+Completion.swift
//  Tempura
//
//  Created by Andrea De Angelis on 02/07/2018.
//

import UIKit

extension UINavigationController {
  /// Helper method to trigger the completion callback right after a navigation transition ends
  private func completionHelper(for completion: (() -> Void)?) {
    if let transitionCoordinator = self.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { _ in
        completion?()
      }
    } else {
      completion?()
    }
  }

  /// `pushViewController` method with completion callback
  public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    self.pushViewController(viewController, animated: animated)
    self.completionHelper(for: completion)
  }

  /// `popViewController` method with completion callback
  public func popViewController(animated: Bool, completion: (() -> Void)?) {
    self.popViewController(animated: animated)
    self.completionHelper(for: completion)
  }

  /// `popToRootViewController` method with completion callback
  public func popToRootViewController(animated: Bool, completion: (() -> Void)?) {
    self.popToRootViewController(animated: animated)
    self.completionHelper(for: completion)
  }

  /// `popToViewController` method with completion callback
  public func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    self.popToViewController(viewController, animated: animated)
    self.completionHelper(for: completion)
  }
}
