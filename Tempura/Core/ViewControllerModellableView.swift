//
//  ViewControllerModellableView.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/08/2017.
//
//

import Foundation
import UIKit

/// the ViewControllerModellableView extends the `ModellableView` protocol to add
/// some convenience variables that refers to the ViewController that owns the View
/// this is intended to be used on the main View of a `ViewController`

fileprivate var viewControllerKey = "modellableview_view_controller_key"


public protocol ViewControllerModellableView: ModellableView where VM: ViewModelWithState {
  
  var viewController: UIViewController? { get set }
}

public extension ViewControllerModellableView {
  
  /// shortcut to the navigationBar, if present
  public var navigationBar: UINavigationBar? {
    return viewController?.navigationController?.navigationBar
  }
  
  /// shortcut to the navigationItem, if present
  public var navigationItem: UINavigationItem? {
    return viewController?.navigationItem
  }
  
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

// MARK: SafeAreaInsets

public extension ViewControllerModellableView where Self: UIView {
  
  /// implementation of iOS 11 safeAreaInsets accessible even to older iOS versions
  /// see also https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area
  
  public var universalSafeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return self.safeAreaInsets
    } else {
      return self.legacyIOSSafeAreaInsets
    }
  }

  private var legacyIOSSafeAreaInsets: UIEdgeInsets {
    guard let vc = self.viewController else {
      return .zero
    }
    
    return UIEdgeInsets(
      top: vc.topLayoutGuide.length,
      left: 0,
      bottom: vc.bottomLayoutGuide.length,
      right: 0
    )
  }
}
