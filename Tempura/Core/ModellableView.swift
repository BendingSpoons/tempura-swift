//
//  ModellableView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

fileprivate var modelWrapperKey = "modellableview_model_wrapper_key"

/// Mixin protocol for UIView subclasses based on the same SSUL lifecycle of `View`. Conforming to `ModellableView`, a UIView will get a `model: ViewModel` property
/// and the `update(oldModel: ViewModel?)` will be automatically called each time the model property will change.
/// If your UIView is simple and you don't want to use a ViewModel, refer to the `View` protocol instead.

/// ## Overview
/// The `View` protocol is good enough for small reusable UI elements that can be manipulated through **properties**.
/// There are a couple of drawbacks to this approach:
/// - it's not easy to test UI elements
/// - in the `View.update()` phase we don't know the actual property that is changed, meaning that we cannot reason in terms of differences from the old values
/// - changing two or more properties at the same time will trigger two or more updates.
///
/// To solve all of these issues we introduce the concept of `ViewModel`.
/// A ViewModel is a struct that contains all the properties that define the state of the View.

/// ```swift
///    struct ContactViewModel: ViewModel {
///      var name: String = "John"
///      var lastName: String = "Doe"
///    }
/// ```

/// A `ModellableView` then is a special case of `View` that is using a ViewModel to represent its state.
/// All the Setup, Style and Layout phases described in `View` are still in use, the only difference is that
/// the Update method of the ModellableView is getting an `oldModel` parameter.

/// ```swift
///    struct ContactView: UIView, ModellableView {
///
///      // subviews to create the UI
///      private var title = UILabel()
///      private var subtitle = UILabel()
///
///      // interactions
///      var nameDidChange: ((String) -> ())?
///      var lastNameDidChange: ((String) -> ())?
///
///      override init(frame: CGRect = .zero) {
///        super.init(frame: frame)
///        self.setup()
///        self.style()
///      }
///
///      func setup() {
///        // define the subviews that will make up the UI
///        self.addSubview(self.title)
///        self.addSubview(self.subtitle)
///
///        self.title.on(.didEndEditing) { [weak self] label in
///          self?.nameDidChange?(label.text)
///        }
///        self.subtitle.on(.didEndEditing) { [weak self] label in
///          self?.lastNameDidChange?(label.text)
///        }
///      }
///
///      func style() {
///        // define the default look and feel of the UI elements
///      }
///
///      func update(oldModel: ContactViewModel?) {
///        // update the UI based on the value of `self.model`
///        // you can use `oldModel` to reason about diffs
///        self.title.text = self.model.name
///        self.subtitle.text = self.model.lastname
///      }
///
///      override func layoutSubviews() {
///        // layout the subviews
///      }
///    }
/// ```
///
/// Conforming to `ModellableView` will:
/// - create the `model: ContactViewModel` variable automatically for you.
/// - automatically call the `ModellableView.update(oldModel:)` method every time the model changes
/// - allow to test the ViewModel instead of testing the ModellableView
/// - include the oldModel inside the `ModellableView.update(oldModel:)` so that you can reason about diffs
/// - allow to change more than one property and trigger only one update
///
/// ```swift
///    public protocol ModellableView: View {
///
///      associatedtype VM: ViewModel
///
///      // the ViewModel of the View.
///      // `update(oldModel: VM?)` will be called each time model will change
///      var model: VM? { get set }
///
///      // the model is changed, update the View
///      func update(oldModel: VM?)
///    }
/// ```

public protocol ModellableView: View {
  associatedtype VM: ViewModel
  
  /// The ViewModel of the View. Once changed, the `update(oldModel: VM?)` will be called.
  /// The model variable is automatically created for you once you conform to the ModellableView protocol.
  /// Swift is inferring the Type through the `oldModel` parameter of the `update(oldModel: ViewModel?)` method
  /// and we are adding the var exploiting a feature of the Objective-C runtime called [Associated Objects](http://nshipster.com/associated-objects/).
  var model: VM? { get set }
  
  /// Called when the ViewModel is changed. Update the View using `self.model`.
  func update(oldModel: VM?)
}

/// implementation detail, wrapper of the model to work with the associatedObject mechanism.
private final class ModelWrapper<VM: ViewModel> {
  var model: VM?
  
  init(model: VM?) {
    self.model = model
  }
}

/// model update logic implementation.
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
  
  /// The ViewModel of the View. Once changed, the `update(oldModel: VM?)` will be called.
  /// The model variable is automatically created for you once you conform to the ModellableView protocol.
  /// Swift is inferring the Type through the `oldModel` parameter of the `update(oldModel: ViewModel?)` method
  /// and we are adding the var exploiting a feature of the Objective-C runtime called [Associated Objects](http://nshipster.com/associated-objects/).
  public var model: VM? {
    get {
      return self.modelWrapper.model
    }
    
    set {
      let oldValue = self.model
      self.modelWrapper.model = newValue

      self.update(oldModel: oldValue)
    }
  }
  /// Will throw a fatalError. Use `update(oldMdel:)` instead.
  func update() {
    fatalError("You should not use \(#function) in a ModellableView. Change the model instead" )
  }
}
