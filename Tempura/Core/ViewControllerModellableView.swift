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


public protocol ViewControllerModellableView: ModellableView {
  
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
