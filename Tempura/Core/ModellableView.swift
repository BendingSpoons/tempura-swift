//
//  ModellableView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

// typealias for interaction callback
public typealias Interaction = () -> ()

fileprivate var viewControllerKey = "modellableview_view_controller_key"
fileprivate var modelWrapperKey = "modellableview_model_wrapper_key"

/**
 
 # Live Reload
 ModellableView automatically implements a method to leverage live reload.
 Basically, when the view changes, update and layout are invoked and you have
 the chance of updating the view without recompiling the application.
 
 If you need to perform tasks before update and layout, see `liveReloadWillInvokeUpdateAndLayout`,
 if you want to customise the model that is passed to `update`, see `liveReloadOldModel`
*/
public protocol ModellableView: class, LiveReloadableView {
 associatedtype VM: ViewModel
  
  var model: VM { get set }
  
  var viewController: UIViewController? { get set }
  
  func setup()
  func style()
  func update(oldModel: VM)
  func layout()

  /**
   This method is invoked before `update` and `layout` are invoked
   by the live reload. You can use it reset checks or
   do anything you think it is useful to make the live reload work.
   
   This method is never invoked in production runs as well as other live
   reload methods.
  */
  func liveReloadWillInvokeUpdateAndLayout()
  
  /**
   This method can be used to customise the old model passed to
   `update`, when it is invoked by the live reload system.
   
   This method is never invoked in production runs as well as other live
   reload methods.
  */
  func liveReloadOldModel() -> VM

 /*open override func layoutSubviews() {
    self.layout(model: self.model)
  }*/
}

public extension ModellableView {
  func viewDidLiveReload() {
    self.update(oldModel: self.liveReloadOldModel())
    self.layout()
  }
  
  /// The default implementation return the current model
  func liveReloadOldModel() -> VM {
    return self.model
  }
  
  /// The default implementation does nothing
  func liveReloadWillInvokeUpdateAndLayout() {}
}

private final class ModelWrapper<VM: ViewModel> {
  var model: VM
  
  init(model: VM) {
    self.model = model
  }
}

public extension ModellableView {
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
  
  private var modelWrapper: ModelWrapper<VM> {
    get {
      if let modelWrapper = objc_getAssociatedObject(self, &modelWrapperKey) as? ModelWrapper<VM> {
        return modelWrapper
      }
      
      let newWrapper = ModelWrapper(model: VM())
      self.modelWrapper = newWrapper
      return newWrapper
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &modelWrapperKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  
  public var model: VM {
    get {
      return self.modelWrapper.model
    }
    
    set {
      let oldValue = self.model
      self.modelWrapper.model = newValue
      self.update(oldModel: oldValue)
    }
  }
}
