//
//  ViewControllerModellableView.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/08/2017.
//
//

import Foundation
import UIKit

private var viewControllerKey = "modellableview_view_controller_key"

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

public protocol ViewControllerModellableView: ModellableView, AnyViewControllerModellableView where VM: ViewModelWithState {}

/// type erasure for ViewControllerModellableView in order to access to the viewController property
/// without specifying the VM
public protocol AnyViewControllerModellableView {
  /// Syntactic sugar to access the `ViewController` that is managing this View.
  var viewController: UIViewController? { get set }
}

extension ViewControllerModellableView {
  /// Shortcut to the navigationBar, if present.
  public var navigationBar: UINavigationBar? {
    return self.viewController?.navigationController?.navigationBar
  }

  /// Shortcut to the navigationItem, if present.
  public var navigationItem: UINavigationItem? {
    return self.viewController?.navigationItem
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
