//
//  TestHelpers.swift
//  Tempura
//
//  Created by Mauro Bolis on 02/09/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit
import Tempura

class Renderer<V: ViewControllerModellableView> {
  private var modellableViewType: V.Type
  private var model: V.VM
  private var container: Container
  private var size: CGSize
  private var hooks: [Hook: HookClosure<V>]
  
  init(_ type: V.Type, model: V.VM, container: Container, size: CGSize, hooks: [Hook: HookClosure<V>]) {
    self.modellableViewType = type
    self.model = model
    self.container = container
    self.size = size
    self.hooks = hooks
  }
  
  func getViewController() -> UIViewController {
    
    let containerViewController: UIViewController
    
    switch self.container {
    case .none:
      let containerVC = ContainerViewController<V>()
      containerVC.hooks = hooks
      containerVC.rootView.model = self.model
      containerViewController = containerVC
      
    case .navigationController:
      let containerVC = ContainerViewController<V>()
      containerVC.hooks = hooks
      containerVC.rootView.model = self.model
      let navVc = UINavigationController(rootViewController: containerVC)
      containerViewController = navVc
      
      if let hook = hooks[.navigationControllerHasBeenCreated] {
        hook(containerVC.rootView)
      }
    }
    
    containerViewController.view.frame.size = self.size
    return containerViewController
  }
}

class ContainerViewController<V: ViewControllerModellableView>: UIViewController {
  var hooks: [Hook: HookClosure<V>]?
  
  override func loadView() {
    self.view = (V.self as! UIView.Type).init()
    
    (self.view as! V).viewController = self
    
    self.rootView.setup()
    self.rootView.style()
  }
  
  var rootView: V {
    return self.view as! V
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.automaticallyAdjustsScrollViewInsets = false
    self.edgesForExtendedLayout = []
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard let hooks = self.hooks else {
      return
    }
    
    if let hook = hooks[.viewDidLayoutSubviews] {
      hook(self.rootView)
    }
  }
}

/**
 The container in which the view can be embedded
*/
public enum Container {
  
  /// No container
  case none
  
  /// The view is container in a navigation controller
  case navigationController
}

/// Closure invoked when a hook is triggered
public typealias HookClosure<View: ViewControllerModellableView> = (View) -> Void

/**
 A view's lifecycle hook
*/
public enum Hook: Int {
  /**
   The navigation controller has been created and can be customized.
   This hook is triggered only when the container is `navigationController`
  */
  case navigationControllerHasBeenCreated
  
  /// View has just laid out the subviews
  case viewDidLayoutSubviews
}
