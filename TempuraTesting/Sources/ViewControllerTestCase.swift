//
//  ViewControllerTestCase.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Tempura
import XCTest

/**
 Test a UIViewController and its ModellableView embedded in a Container with a specific ViewModel.
 You can use this class to test `ViewController`s with their `ViewControllerModellableView`s.
 You can still use this class to test simple `UIViewController`s that are managing a `ModellableView`.
 If you want to test a plain `UIViewController` with a simple `UIView`, you should use a `UIViewControllerTestCase`.
 The test will produce a screenshot of the view.
 The screenshots will be located in the directory specified inside the plist with the `UI_TEST_DIR` key.
 After the screenshot is completed, the test will pass.
 The protocol can only be used in a XCTest environment.

 The idea is that the view is rendered but the system waits until `isViewReady` returns true to take the snapshot
 and pass to the next test case. `isViewReady` is invoked various times with the view instance. The method should be implemented
 so that it checks possible things that may not be ready yet and return true only when the view is ready to be snapshotted.

 Note that this is a protocol as Xcode fails to recognize methods of XCTestCase's subclasses that are written in Swift.
 */

/// Defines a UIViewController that can be tested with a `ViewControllerTestCase`.
///
/// The only requirement is a `ModellableView` as `rootView`.
/// Please note that we are not requiring the view to be a `ViewControllerModellableView`
/// as it's not strictly needed and in this way we can also test a simple `UIViewController`
/// that is managing a `ModellableView`.
public protocol TestableViewController: UIViewController {
  associatedtype V: ModellableView

  var rootView: V { get }
}

extension ViewController: TestableViewController {}

/// A test case for a TestableViewController
public protocol ViewControllerTestCase {
  /// The view controller to be tested
  associatedtype VC: TestableViewController

  /**
   Add new UI tests to be performed

   - parameter testCases: a dictionary of test cases and the corresponding view models. Each pair of the array will be used as
     input for the `configure(vc:for:model:)` method.
   - parameter context: a context used to pass information and control how the view should be rendered
   */
  func uiTest(testCases: [String: VC.V.VM], context: UITests.VCContext<VC>)

  /// Retrieves a dictionary containing the scrollable subviews to test.
  /// The snapshot will contain the whole scrollView content.
  ///
  /// - Parameters:
  ///   - viewController: The viewController under test.
  ///           `isViewReady` has already returned `true` at this point.
  ///   - identifier: the test case identifier.
  /// - Returns: A dictionary where the value is the ScrollView instance to snapshot and the key is
  ///            a suffix for the test case identifier.
  func scrollViewsToTest(in viewController: VC, identifier: String) -> [String: UIScrollView]

  /**
   Method used to check whether the view is ready for the snapshot
   - parameter view: the view that will be snapshotted
   - parameter identifier: the test case identifier
   */
  func isViewReady(_ view: VC.V, identifier: String) -> Bool

  /// used to provide the ViewController to test.
  /// We cannot instantiate it as we cannot require an init in the AnyViewController protocol
  /// otherwise it will require all of the subclasses to have it specified.
  var viewController: VC { get }

  /// configure the VC for the specified `testCase`
  /// this is typically used to manually inject the ViewModel to all the children VCs.
  func configure(vc: VC, for testCase: String, model: VC.V.VM)
}

extension ViewControllerTestCase where Self: XCTestCase {
  /// Runs the given test cases in the given context
  public func uiTest(testCases: [String: VC.V.VM], context: UITests.VCContext<VC>) {
    UITestCaseKeyValidator.singletonInstance.validate(keys: Set(testCases.keys), ofTestCaseWithName: "\(Self.self)")

    // Set the orientation right away to retrieve the correct `UIScreen.main.bounds.size` later.
    UIDevice.current.setValue(NSNumber(integerLiteral: context.orientation.rawValue), forKey: "orientation")

    let screenSizeDescription: String = "\(UIScreen.main.bounds.size)"
    let descriptions: [String: String] = Dictionary(uniqueKeysWithValues: testCases.keys.map { identifier in
      let description = "\(identifier) \(screenSizeDescription)"
      return (identifier, description)
    })

    let expectations: [String: XCTestExpectation] = descriptions.mapValues { _ in
      return XCTestExpectation(description: description)
    }

    DispatchQueue.global().async {
      for (identifier, model) in testCases {
        var contained: VC! // swiftlint:disable:this implicitly_unwrapped_optional
        var container: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional
        var view: UIView! // swiftlint:disable:this implicitly_unwrapped_optional
        var viewToWaitFor: UIView! // swiftlint:disable:this implicitly_unwrapped_optional

        DispatchQueue.main.sync {
          contained = self.viewController
          container = context.container.container(for: contained)
          view = container.view
          view.frame.size = context.screenSize ?? UIScreen.main.bounds.size
          viewToWaitFor = contained.view
        }

        guard let description = descriptions[identifier] else { continue }

        let isViewReadyClosure: (UIView) -> Bool = { view in
          var isOrientationCorrect = true

          // read again in case some weird code changed it outside the ViewControllerTestCase APIs
          let isViewInPortrait = view.frame.size.height > view.frame.size.width

          if context.orientation.isPortrait {
            isOrientationCorrect = isViewInPortrait
          } else if context.orientation.isLandscape {
            isOrientationCorrect = !isViewInPortrait
          }

          let isReady = isOrientationCorrect && self.typeErasedIsViewReady(view, identifier: identifier)

          return isReady
        }

        UITests.syncSnapshot(
          view: view,
          viewToWaitFor: viewToWaitFor,
          description: description,
          configureClosure: {
            self.typeErasedConfigure(contained, identifier: identifier, model: model)
          },
          isViewReadyClosure: isViewReadyClosure,
          shouldRenderSafeArea: context.renderSafeArea,
          keyboardVisibility: context.keyboardVisibility(identifier)
        )

        // ScrollViews snapshot
        DispatchQueue.main.sync {
          self.scrollViewsToTest(in: contained, identifier: identifier).forEach { entry in
            UITests.snapshotScrollableContent(
              entry.value,
              description: "\(identifier)_\(entry.key)_scrollable_content \(screenSizeDescription)"
            )
          }
        }

        expectations[identifier]?.fulfill()
      }
    }

    self.wait(for: Array(expectations.values), timeout: 100)
  }

  /// Type erased isViewReady method
  public func typeErasedIsViewReady(_ view: UIView, identifier: String) -> Bool {
    guard let view = view as? VC.V else {
      return false
    }
    return self.isViewReady(view, identifier: identifier)
  }

  /// Type erased configure method
  public func typeErasedConfigure(_ vc: UIViewController, identifier: String, model: ViewModel) {
    guard let vc = vc as? VC,
          let model = model as? VC.V.VM
    else {
      return
    }

    self.configure(vc: vc, for: identifier, model: model)
  }
}

extension ViewControllerTestCase {
  /// The default implementation returns true
  public func isViewReady(_: VC.V, identifier _: String) -> Bool {
    return true
  }

  /// The default implementation sets the model of the root view to nil and then to the given model
  public func configure(vc: VC, for _: String, model: VC.V.VM) {
    // Reset this to nil so that animation depending on changes of the model should be skipped
    vc.rootView.model = nil
    vc.rootView.model = model
  }

  /// The default implementation uses the standard context
  public func uiTest(testCases: [String: VC.V.VM]) {
    let standardContext = UITests.VCContext<VC>()
    self.uiTest(testCases: testCases, context: standardContext)
  }

  /// The default implementation returns an empty dictionary
  public func scrollViewsToTest(in _: VC, identifier _: String) -> [String: UIScrollView] { return [:] }
}

// MARK: Sub types

extension UITests {
  /// Struct that holds some information used to control how the view is rendered
  public struct VCContext<VC: UIViewController> {
    /// the container in which the main view of the VC will be embedded
    public var container: UITests.Container

    /// the size of the window in which the view will be rendered
    public var screenSize: CGSize?

    /// the orientation of the view
    public var orientation: UIDeviceOrientation

    /// whether black dimmed rectangles should be rendered showing the safe area insets
    public var renderSafeArea: Bool

    /// whether gray rectangle representing the keyboard should be rendered on top of the view, for a given test case
    public var keyboardVisibility: (String) -> KeyboardVisibility

    /// Default initializer
    public init(
      container: Container = .none,
      screenSize: CGSize? = nil,
      orientation: UIDeviceOrientation = .portrait,
      renderSafeArea: Bool = true,
      keyboardVisibility: @escaping (String) -> KeyboardVisibility = { _ in .hidden }
    ) {
      self.container = container
      self.screenSize = screenSize
      self.orientation = orientation
      self.renderSafeArea = renderSafeArea
      self.keyboardVisibility = keyboardVisibility
    }
  }
}
