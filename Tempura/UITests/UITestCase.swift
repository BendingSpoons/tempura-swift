//
//  UITestCase.swift
//  Tempura
//
//  Created by Mauro Bolis on 07/05/2018.
//

import Foundation
import XCTest
import Tempura

@available(*, deprecated: 1.9, message: "Use UITestCase instead")
public typealias AsyncUITest = UITestCase

/**
 Test a ViewControllerModellableView embedded in a Container with a specific ViewModel.
 The test will produce a screenshot of the view.
 The screenshots will be located in the directory specified inside the plist with the `UI_TEST_DIR` key.
 After the screenshot is completed, the test will pass.
 The protocol can only be used in a XCTest environment.
 
 The idea is that the view is rendered but the system waits until `isViewReady` returns true to take the snapshot
 and pass to the next test case. `isViewReady` is invoked various times with the view instance. The method should be implemented
 so that it checks possible things that may not be ready yet and return true only when the view is ready to be snapshotted.
 
 Note that this is a protocol as Xcode fails to recognize methods of XCTestCase's subclasses that are written in Swift.
*/
public protocol UITestCase {
  associatedtype V: UIView & ViewControllerModellableView
  
  /**
   Add a new UI test to be performed
   
   - parameter model: the view model with which the view is created
   - parameter identifier: a string identifier that is used to name the snapshot file
   - parameter container: a parameter that specify in which container the view will be embedded
   - parameter hooks: some hooks that can be added to customize the view after its creation
   - parameter size: the size of the view
  */
  @available(*, deprecated: 1.9, message: "Use uiTest(testCases:context:) instead")
  func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>], size: CGSize)
  
  /**
   Add new UI tests to be performed
   
   - parameter testCases: a dictionary of test cases, where the key is the identifier and the value the
                          view model to use to render the view
   - parameter context: a context used to pass information and control how the view should be rendered
   */
  func uiTest(testCases: [String: V.VM], context: UITests.Context<V>)
  
  /// Retrieves a dictionary containing the scrollable subviews to test.
  /// The snapshot will contain the whole scrollView content.
  ///
  /// - Parameters:
  ///   - view: The `viewControllerModellableView` under test.
  ///           `isViewReady` has already returned `true` at this point.
  ///   - identifier: the test case identifier.
  /// - Returns: A dictionary where the value is the ScrollView instance to snapshot and the key is a suffix for the test case identifier.
  func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView]
  
  /**
   Method used to check whether the view is ready to be snapshotted
   - parameter view: the view that will be snapshotted
  */
  @available(*, deprecated: 1.9, message: "Use isViewReady(:identifier:) instead")
  func isViewReady(_ view: V) -> Bool
  
  /**
   Method used to check whether the view is ready to be snapshotted
   - parameter view: the view that will be snapshotted
   - parameter identifier: the test case identifier
   */
  func isViewReady(_ view: V, identifier: String) -> Bool
}

public extension AsyncUITest {
  func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView] { return [:] }
}

public extension AsyncUITest where Self: XCTestCase {
  public func uiTest(testCases: [String: V.VM], context: UITests.Context<V>) {
    let snapshotConfiguration = UITests.ScreenSnapshot<V>(
      type: V.self,
      container: context.container,
      models: testCases,
      hooks: context.hooks,
      size: context.screenSize
    )
    
    let viewControllers = snapshotConfiguration.renderingViewControllers
    let screenSizeDescription: String = "\(UIScreen.main.bounds.size)"

    var expectations: [XCTestExpectation] = []
    

    for (identifier, vc) in viewControllers {
      let description = "\(identifier) \(screenSizeDescription)"

      let expectation = XCTestExpectation(description: description)
      XCUIDevice.shared.orientation = context.orientation
      
      let isViewReadyClosure: (UIView) -> Bool = { view in
        var isOrientationCorrect = true
        
        // read again in case some weird code changed it outside the UITestCase APIs
        let isViewInPortrait = view.frame.size.height > view.frame.size.width
        
        if context.orientation.isPortrait {
          isOrientationCorrect = isViewInPortrait
        
        } else if context.orientation.isLandscape {
          isOrientationCorrect = !isViewInPortrait
        }
        
        return isOrientationCorrect && self.typeErasedIsViewReady(view, identifier: identifier)
      }

      UITests.asyncSnapshot(view: vc.view, description: description, isViewReadyClosure: isViewReadyClosure) {
        // ScrollViews snapshot
        self.scrollViewsToTest(in: vc.view as! V, identifier: identifier).forEach { entry in
          UITests.snapshotScrollableContent(entry.value, description: "\(identifier)_\(entry.key)")
        }
        expectation.fulfill()
      }

      expectations.append(expectation)
    }

    self.wait(for: expectations, timeout: 100)
  }
  
  func typeErasedIsViewReady(_ view: UIView, identifier: String) -> Bool {
    return self.isViewReady(view as! V, identifier: identifier)
  }
}

public extension UITestCase {
  /// The default implementation returns true
  public func isViewReady(_ view: V, identifier: String) -> Bool {
    return self.isViewReady(view)
  }
  
  public func uiTest(testCases: [String: V.VM]) {
    let standardContext = UITests.Context<V>()
    self.uiTest(testCases: testCases, context: standardContext)
  }
}

// MARK: Sub types
extension UITests {
  /// Struct that holds some information used to control how the view is rendered
  public struct Context<V: ViewControllerModellableView> {
    
    /// the container in which the view will be embedded
    public var container: UITests.Container
    
    /// some hooks that can be added to customize the view after its creation
    public var hooks: [UITests.Hook: UITests.HookClosure<V>]
    
    /// the size of the window in which the view will be rendered
    public var screenSize: CGSize
    
    /// the orientation of the view
    public var orientation: UIDeviceOrientation
    
    public init() {
      self.container = .none
      self.hooks = [:]
      self.screenSize = UIScreen.main.bounds.size
      self.orientation = .portrait
    }
  }
}

// MARK: Deprecated
public extension UITestCase {
  @available(*, deprecated: 1.9, message: "Use uiTest(testCases:context:) instead")
  public func uiTest(model: V.VM, identifier: String) {
    let context = UITests.Context<V>()
    self.uiTest(testCases: [identifier: model], context: context)
  }
  
  @available(*, deprecated: 1.9, message: "Use uiTest(testCases:context:) instead")
  public func uiTest(model: V.VM, identifier: String, container: UITests.Container) {
    var context = UITests.Context<V>()
    context.container = container
    
    self.uiTest(testCases: [identifier: model], context: context)
  }
  
  @available(*, deprecated: 1.9, message: "Use uiTest(testCases:context:) instead")
  public func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>], size: CGSize) {
    var context = UITests.Context<V>()
    context.container = container
    context.hooks = hooks
    context.screenSize = size
    
    self.uiTest(testCases: [identifier: model], context: context)
  }
  
  @available(*, deprecated: 1.9, message: "Use uiTest(testCases:context:) instead")
  public func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>]) {
    var context = UITests.Context<V>()
    context.container = container
    context.hooks = hooks
    
    self.uiTest(testCases: [identifier: model], context: context)
  }
  
  /// The default implementation returns true
  @available(*, deprecated: 1.9, message: "Use isViewReady(:identifier:) instead")
  public func isViewReady(_ view: V) -> Bool {
    return true
  }
}
