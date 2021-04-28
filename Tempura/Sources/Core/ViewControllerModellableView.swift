//
//  ViewControllerModellableView.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/08/2017.
//
//

import Foundation
import UIKit

fileprivate var viewControllerKey = "modellableview_view_controller_key"

/// Extends the `ModellableView` protocol to add
/// some convenience variables that refers to the ViewController that owns the View.


/// A special case of `ModellableView` representing the UIView that the `ViewController` is managing.
/// It's intended to be used only as the main View of a `ViewController`.

/// ## Overview
/// A ViewControllerModellableView is a `ModellableView` that a `ViewController` is managing directly.
/// It differs from a ModellableView only for a couple of computed variables
/// used as syntactic sugar to access navigation items on the navigation bar
/// (if present).
/// A ViewControllerModellableView has also access to the `universalSafeAreaInsets`.
/// The `ViewController` that is managing this View is responsible to call `ModellableView.setup()` and
/// `ModellableView.style()` during the setup phase of the ViewController so you don't need to do that.

public protocol ViewControllerModellableView: ModellableView, AnyViewControllerModellableView where VM: ViewModelWithState {
  
}

/// type erasure for ViewControllerModellableView in order to access to the viewController property
/// without specifying the VM
public protocol AnyViewControllerModellableView {
  /// Syntactic sugar to access the `ViewController` that is managing this View.
  var viewController: UIViewController? { get set }
}

public extension ViewControllerModellableView {
  
  /// Shortcut to the navigationBar, if present.
  var navigationBar: UINavigationBar? {
    return viewController?.navigationController?.navigationBar
  }
  
  /// Shortcut to the navigationItem, if present.
  var navigationItem: UINavigationItem? {
    return viewController?.navigationItem
  }
  /// Syntactic sugar to access the `ViewController` that is managing this View.
  var viewController: UIViewController? {
    get {
      return objc_getAssociatedObject(self, &viewControllerKey) as? UIViewController
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &viewControllerKey,
        newValue,
        .OBJC_ASSOCIATION_ASSIGN
      )
    }
  }
}

/// Implementation of iOS 11 safeAreaInsets accessible even to older iOS versions.
/// see also https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area
public extension UIView {
  /// Implementation of safeAreaInsets in order to be accessible even to older iOS versions.
  var universalSafeAreaInsets: UIEdgeInsets {
    return self.safeAreaInsets
  }
}
