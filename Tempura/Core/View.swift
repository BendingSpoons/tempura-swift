//
//  View.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/08/2017.
//
//

import Foundation

/// Basic protocol representing the 4 main phases of the lifecycle of a UIView in Tempura.
///
/// Ideally all the reusable simple Views of the app should conform to this protocol.
/// Please note that this protocol is just used in order to enforce the same lifecycle for all the views.
///
/// For more complex Views please refer to the `ModellableView` protocol.

/// ## Overview
/// A view is a piece of UI that is visible on screen. It contains no business logic, it can contain UI logic.
/// ```swift
/// class Switch: UIView, View {
///
///   // subviews
///   private var thumb = UIView()
///
///   // properties
///   var isOn: Bool = false {
///     didSet {
///       guard self.isOn != oldValue else { return }
///       self.update()
///     }
///   }
///
///   override init(frame: CGRect = .zero) {
///     super.init(frame: frame)
///     self.setup()
///     self.style()
///   }
///
///   // interactions
///   var valueDidChange: ((Double) -> ())?
///
///   func setup() {
///     // define the subviews that will make up the UI
///   }
///
///   func style() {
///     // define the default look and feel of the UI elements
///   }
///
///   func update() {
///     // update the UI based on the value of the properties
///   }
///
///   func layoutSubviews() {
///     // layout the subviews, optionally considering the properties
///   }
/// }
/// ```
/// The interface that the View is exposing is composed by **properties** and **interactions**.
/// The `properties` are the internal state of the element that can be manipulated from the outside,
/// `interactions` are callbacks used to listen from outside of the view to changes occurred inside the element itself (like user interacting with the element changing its value).

/// The lifecycle of a View contains four different phases:
/// ```swift
/// public protocol View: class {
///   func setup()
///   func style()
///   func update()
///   func layoutSubviews()
/// }
/// ```
/// This protocol is not doing anything for us, it's just a way to enforce the SSUL phases.

/// ## Setup
/// The setup phase should execute only once when the `View` is created, here you tipically want to create and add all the children views as subviews

/// ```swift
/// func setup() {
///   self.addSubview(self.headerView)
///   self.addSubview(self.contentView)
///   self.addSubview(self.footerView)
/// }
/// ```

/// ## Style
/// The style phase should execute only once when the `View` is created,
/// right after the setup phase.
/// Here you configure all the style related properties that will not change over time.
/// For all the style attributes that change depending on the "state" of the view,
/// look at the `View.update()` phase.

/// ```swift
/// func style() {
///   self.headerView.backgroundColor = .white
///   self.contentView.layer.cornerRadius = 20
/// }
/// ```

/// ## Update
/// The update phase should execute every time the "state" of the View is changed.
/// Here you update the View in order to reflect its new state.

/// ```swift
/// var headerImage: UIImage? {
///   didSet {
///     self.update()
///   }
/// }
/// ```

/// ```swift
/// func update() {
///   self.headerView.image = self.headerImage
/// }
/// ```

/// ## Layout
/// The layout phase is where you define the layout of your view.
/// It's using the same `layoutSubviews()` method of `UIView`, meaning that can be triggered
/// using the usual `setNeedsLayout()` and `layoutIfNeeded()` methods of UIKit.

/// ```swift
/// override func layoutSubviews() {
///   self.headerView.frame = CGRect(x: 0, y:0, width: self.bounds.width, height: 100)
///   self.contentView.frame = CGRect(x: 0, y: 100, width: self.bounds.width, height: 300)
/// }
/// ```

/// ## Note on layout updates
/// When the layout of your view changes over time, you are responsible to call
/// `setNeedsLayout()` inside the `update()` phase in order to trigger a layout update.

/// ```swift
/// func update() {
///   self.headerView.image = self.headerImage
///   self.setNeedsLayout()
/// }
/// ```

/// ```swift
/// override func layoutSubviews() {
///   let containsImage: Bool = self.headerImage != nil
///   let headerHeight: CGFloat = containsImage ? 100 : 0
///   self.headerView.frame = CGRect(x: 0, y:0, width: self.bounds.width, height: headerHeight)
/// }
/// ```

/// ## Note on calling setup and style
/// When your UIView subclass conforms to the View protocol, you are responsible to call
/// the `setup()` and `style()` methods inside the init.

/// ```swift
/// class TestView: UIView, View {
///  override init(frame: CGRect = .zero) {
///    super.init(frame: frame)
///    self.setup()
///    self.style()
///  }
///
///  func setup() {}
///  func style() {}
///  func update() {}
///  override func layoutSubviews() {}
/// }
/// ```

public protocol View: class {
  /// The setup phase should execute only once when the `View` is created,
  /// here you tipically want to create and add all the children views as subviews.
  func setup()
  /// The style phase should execute only once when the `View` is created,
  /// right after the setup phase.
  /// Here you configure all the style related properties that will not change over time.
  /// For all the style attributes that change depending on the "state" of the view,
  /// look at the `View.update()` phase.
  func style()
  /// The update phase should execute every time the "state" of the View is changed.
  /// Here you update the View in order to reflect its new state.
  func update()
  /// The layout phase is where you define the layout of your view.
  /// It's using the same `layoutSubviews()` method of `UIView`, meaning that can be triggered
  /// using the usual `setNeedsLayout()` and `layoutIfNeeded()` methods of UIKit.
  func layoutSubviews()
}
