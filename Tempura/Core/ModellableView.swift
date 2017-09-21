//
//  ModellableView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

/// the ModellableView protocol defines the structure of a View that is more complex than a simple reusable View
/// (for which we use the simpler `View` protocol).
/// A perfect candidate for this protocol is a View that contains specific Domain level knowledge and
/// it is more natural to be updated using the concept of a ViewModel instead of a set of properties.


fileprivate var modelWrapperKey = "modellableview_model_wrapper_key"

/**
 
 # Live Reload
 ViewControllerModellableView automatically implements a method to leverage live reload.
 Basically, when the view changes, update and layout are invoked and you have
 the chance of updating the view without recompiling the application.
 
 If you need to perform tasks before update and layout, see `liveReloadWillInvokeUpdateAndLayout`,
 if you want to customise the model that is passed to `update`, see `liveReloadOldModel`
 */

public protocol ModellableView: View, LiveReloadableView {
  associatedtype VM: ViewModel
  
  /// the ViewModel of the View. Once changed, the `update(oldModel: VM)` will be called
  var model: VM! { get set }
  
  /// the ViewModel is changed, update the View using the `oldModel` and the new `self.model`
  func update(oldModel: VM?)
  
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
  func liveReloadOldModel() -> VM?
}

/// implementation detail, wrapper of the model to work with the associatedObject mechanism
private final class ModelWrapper<VM: ViewModel> {
  var model: VM?
  
  init(model: VM?) {
    self.model = model
  }
}

/// model update logic implementation
public extension ModellableView {
  
  private var modelWrapper: ModelWrapper<VM> {
    get {
      if let modelWrapper = objc_getAssociatedObject(self, &modelWrapperKey) as? ModelWrapper<VM> {
        return modelWrapper
      }
      let newWrapper = ModelWrapper<VM>(model: nil)
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
  
  public var model: VM! {
    get {
      return self.modelWrapper.model
    }
    
    set {
      let oldValue = self.model
      self.modelWrapper.model = newValue

      self.update(oldModel: oldValue)
    }
  }
  
  func update() {
    fatalError("You should not use \(#function) in a ModellableView. Change the model instead" )
  }
}

/// live reload implementation
public extension ModellableView {
  func viewDidLiveReload() {
    self.liveReloadWillInvokeUpdateAndLayout()
    self.style()
    self.update(oldModel: self.liveReloadOldModel())
    
    // layoutIfNeeded would be the correct way to trigger an update
    // It seems that it doesn't work though
    // For the live reload purposes, we call layoutSubviews directly
    self.layoutSubviews()
  }
  
  /// The default implementation return the current model
  func liveReloadOldModel() -> VM? {
    return self.model
  }
  
  /// The default implementation does nothing
  func liveReloadWillInvokeUpdateAndLayout() {}
}
