//
//  UIViewControllerTestCase.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Tempura
import XCTest

/**
 Test a UIViewController and its UIView embedded in a Container.
 The test will produce a screenshot of the view.
 The screenshots will be located in the directory specified inside the plist with the `UI_TEST_DIR` key.
 After the screenshot is completed, the test will pass.
 The protocol can only be used in a XCTest environment.

 The idea is that the view is rendered but the system waits until `isViewReady` returns true to take the snapshot
 and pass to the next test case. `isViewReady` is invoked various times with the view instance. The method should be implemented
 so that it checks possible things that may not be ready yet and return true only when the view is ready to be snapshotted.

 Note that this is a protocol as Xcode fails to recognize methods of XCTestCase's subclasses that are written in Swift.
 */

public protocol UIViewControllerTestCase {
  associatedtype VC: UIViewController
  associatedtype V: UIView

  /**
   Add new UI tests to be performed

   - parameter testCases: an array of test cases. Each item of the array will be used as input for the `configure(vc:for:)` method.
   - parameter context: a context used to pass information and control how the view should be rendered
   */
  func uiTest(testCases: [String], context: UITests.VCContext<VC>)

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
  func isViewReady(_ view: V, identifier: String) -> Bool

  /// used to provide the ViewController to test.
  /// We cannot instantiate it as you can use your own UIViewController subclass.
  var viewController: VC { get }

  /// configure the VC for the specified `testCase`
  /// this is typically used to manually configure properties to all the children VCs or Views.
  func configure(vc: VC, for testCase: String)
}

extension UIViewControllerTestCase where Self: XCTestCase {
  public func uiTest(testCases: [String], context: UITests.VCContext<VC>) {
    // Set the orientation right away to retrieve the correct `UIScreen.main.bounds.size` later.
    XCUIDevice.shared.orientation = context.orientation

    let screenSizeDescription: String = "\(UIScreen.main.bounds.size)"
    let descriptions: [String: String] = Dictionary(uniqueKeysWithValues: testCases.map { identifier in
      let description = "\(identifier) \(screenSizeDescription)"
      return (identifier, description)
    })

    let expectations: [String: XCTestExpectation] = descriptions.mapValues { _ in
      return XCTestExpectation(description: description)
    }

    DispatchQueue.global().async {
      for identifier in testCases {
        var contained: VC!
        var container: UIViewController!
        var view: UIView!
        var viewToWaitFor: UIView!

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
            self.typeErasedConfigure(contained, identifier: identifier)
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

  public func typeErasedIsViewReady(_ view: UIView, identifier: String) -> Bool {
    guard let view = view as? V else {
      return false
    }
    return self.isViewReady(view, identifier: identifier)
  }

  public func typeErasedConfigure(_ vc: UIViewController, identifier: String) {
    guard let vc = vc as? VC else {
      return
    }

    self.configure(vc: vc, for: identifier)
  }
}

extension UIViewControllerTestCase {
  /// The default implementation returns true
  public func isViewReady(_: V, identifier _: String) -> Bool {
    return true
  }

  /// The default implementation is empty
  public func configure(vc _: VC, for _: String) {}

  public func uiTest(testCases: [String]) {
    let standardContext = UITests.VCContext<VC>()
    self.uiTest(testCases: testCases, context: standardContext)
  }

  public func scrollViewsToTest(in _: VC, identifier _: String) -> [String: UIScrollView] { return [:] }
}
