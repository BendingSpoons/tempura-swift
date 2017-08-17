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

public protocol ModellableView: class {
 associatedtype VM: ViewModel
  
  var model: VM { get set }
  
  var viewController: UIViewController? { get set }
  
  func setup()
  func style()
  func update(oldModel: VM)
  func layout()
  
 /*open override func layoutSubviews() {
    self.layout(model: self.model)
  }*/
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
