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
/// A ViewControllerModellableView has also access to the `universalSafeAreaInsets.
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
  public var navigationBar: UINavigationBar? {
    return viewController?.navigationController?.navigationBar
  }
  
  /// Shortcut to the navigationItem, if present.
  public var navigationItem: UINavigationItem? {
    return viewController?.navigationItem
  }
  /// Syntactic sugar to access the `ViewController` that is managing this View.
  public var viewController: UIViewController? {
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
  public var universalSafeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return self.safeAreaInsets
    } else {
      return self.legacyIOSSafeAreaInsets
    }
  }
  
  private var legacyIOSSafeAreaInsets: UIEdgeInsets {
    guard let vc = self.recursiveViewController else {
      return .zero
    }
    let rootView: UIView! = vc.view
    var top = vc.topLayoutGuide.length
    var bottom = vc.bottomLayoutGuide.length
    // the safe area expressed in rootView coordinates
    let rootViewSafeAreaFrame = CGRect(x: 0, y: top, width: rootView.bounds.width, height: rootView.bounds.height - top - bottom)
    // convert the rootViewSafeAreaFrame in self coordinates
    let convertedFrame = rootView.convert(rootViewSafeAreaFrame, to: self)
    // find the portion of safe area that intersects with self.bounds
    let intersectionFrame = self.bounds.intersection(convertedFrame)
    top = intersectionFrame.minY
    bottom = self.bounds.maxY - intersectionFrame.maxY
    
    return UIEdgeInsets(
      top: top,
      left: 0,
      bottom: bottom,
      right: 0
    )
  }
  
  /// Traverse up the hierarchy to find the first UIViewController
  private var recursiveViewController: UIViewController? {
    if let modellableView = self as? AnyViewControllerModellableView {
      return modellableView.viewController
    }
    if let parent = self.superview {
      return parent.recursiveViewController
    }
    return nil
  }
}
