//
//  SwiftUIModellableView.swift
//  Tempura
//
//  Created by MicheleGruppioni on 01/12/20.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Basic protocol representing a SwiftUI View in Tempura.
///
/// Every SwiftUI View must conform to this protocol to be presented using Tempura.
/// The viewModelProvider is the object that proxies the view updates from the Tempura
/// environment to a SwiftUI ObservableObject.
///
/// ## Example
/// ```swift
/// struct SwiftUICustomView: SwiftUIModellableView {
///   @ObservedObject var viewModelProvider: ViewModelProvider<SwiftUICustomViewModel>
///
///   init(viewModelProvider: ViewModelProvider<CustomViewModel>) {
///     self.viewModelProvider = viewModelProvider
///   }
///
///   var body: some SwiftUI.View {
///     ...
///   }
/// }
///
/// struct SwiftUICustomViewModel: ViewModelWithState {
///   init(state: AppState) {
///     ...
///   }
/// }
/// ```

@available(iOS 13.0.0, *)
public protocol SwiftUIModellableView: SwiftUI.View {
  associatedtype VM: ViewModelWithState

  var viewModelProvider: ViewModelProvider<VM> { get }

  init(viewModelProvider: ViewModelProvider<VM>)
}
