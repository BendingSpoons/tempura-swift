//
//  SwiftUIViewControllerModellableView.swift
//  Tempura
//
//  Created by MicheleGruppioni on 01/12/20.
//

import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Special `ViewControllerModellableView` that adapt a `SwiftUIModellableView` to Tempura
///
/// This view present fullscreen a SwiftUI View that conforms to `SwiftUIModellableView` using a `UIHostingController`
/// All the update events are forwaded to the SwiftUI world using a `ViewModelProvider`
///
/// ## Example
/// ```swift
/// class CustomViewController: ViewController<SwiftUIViewControllerModellableView<SwiftUICustomView>> {
/// }
/// ```

@available(iOS 13.0.0, *)
open class SwiftUIViewControllerModellableView<SwiftUIView: SwiftUIModellableView>: ContainerView, ViewControllerModellableView {
  public typealias VM = SwiftUIView.VM

  /// A ViewModelProvider used to forward the ViewModel updates to the SwiftUI View
  private let viewModelProvider = ViewModelProvider<VM>()

  // MARK: - Subviews

  /// The `UIHostingController` used to embed a SwiftUI view in the current UIKit view hirearchy
  private let hostingController: UIHostingController<SwiftUIView>

  /// The embedded SwiftUI View
  public var swiftUIView: SwiftUIView {
    get {
      hostingController.rootView
    }
    set {
      hostingController.rootView = newValue
    }
  }

  // MARK: - Init

  public override init(frame: CGRect) {
    let swiftUIView = SwiftUIView(viewModelProvider: self.viewModelProvider)
    self.hostingController = UIHostingController(rootView: swiftUIView)

    super.init(frame: frame)

    self.setup()
    self.style()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  // MARK: - Setup

  public func setup() {
    if let viewController = self.viewController {
      viewController.addChild(self.hostingController)
      self.addSubview(self.hostingController.view)
      self.hostingController.didMove(toParent: viewController)
    }
  }
  
  // MARK: - Style

  public func style() {}

  // MARK: - Update

  public func update(oldModel: VM?) {
    guard let model = self.model else { return }
    self.viewModelProvider.update(model: model, oldModel: oldModel)
  }
}
