//
//  ViewModelProvider.swift
//  Tempura
//
//  Created by MicheleGruppioni on 01/12/20.
//

#if canImport(Combine)
import Combine
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

/// This object act as a proxy between the ViewModel updates in Tempura and SwiftUI.
/// It's an `ObservableObject` so a SwiftUI view can subscribe to it using the `@ObservedObject` property wrapper.
///
/// This object is instantiated inside any `SwiftUIViewControllerModellableView`.

@available(iOS 13.0.0, *)
open class ViewModelProvider<VM: ViewModelWithState>: ObservableObject {
  
  /// Publisher requred by `ObservableObject` in order to update the SwiftUI View.
  public let objectWillChange = ObservableObjectPublisher()

  /// Last `oldModel` received.
  private(set) var oldModel: VM?
  
  /// Last `model` received.
  private(set) var model: VM?

  /// Initialize a `ViewModelProvider` by setting the provided `model` and `oldModel`.
  public init(model: VM? = nil, oldModel: VM? = nil) {
    self.model = model
    self.oldModel = oldModel
  }

  /// Perform an update of the models.
  /// Everytime this method gets called a new `objectWillChange` events is emitted.
  public func update(model: VM, oldModel: VM?) {
    self.objectWillChange.send()
    self.oldModel = oldModel
    self.model = model
  }
}
