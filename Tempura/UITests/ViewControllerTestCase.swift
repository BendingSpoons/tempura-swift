//
//  ViewControllerTestCase.swift
//  Tempura
//
//  Created by Andrea De Angelis on 22/11/2018.
//

import Foundation
import XCTest
import Tempura

/**
 Test a ViewController embedded in a Container.
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
   
   - parameter testCases: a dictionary of test cases, where the key is the identifier and the value the
   view model to use to render the view
   - parameter context: a context used to pass information and control how the view should be rendered
   */
  func uiTest(testCases: [String], context: UITests.VCContext<V>)
  
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
  /// We cannot instantiate it as we cannot require an init in the AnyViewController protocol
  /// otherwise it will require all of the subclasses to have it specified.
  func viewController(for testCase: String) -> VC
  
  /// configure the VC for the specified `testCase`
  /// this is typically used to manually inject the ViewModel to all the children VCs.
  func configure(vc: VC, for testCase: String)
}

public extension UIViewControllerTestCase where Self: XCTestCase {
  func uiTest(testCases: [String], context: UITests.VCContext<V>) {
    let snapshotConfiguration = UITests.VCScreenSnapshot<VC, V>(
      vc: self.viewController,
      container: context.container,
      testCases: testCases,
      hooks: context.hooks,
      size: context.screenSize
    )
    
    let viewControllers = snapshotConfiguration.renderingViewControllers
    let screenSizeDescription: String = "\(UIScreen.main.bounds.size)"
    
    var expectations: [XCTestExpectation] = []
    
    for (identifier, vcs) in viewControllers {
      let description = "\(identifier) \(screenSizeDescription)"
      
      let expectation = XCTestExpectation(description: description)
      XCUIDevice.shared.orientation = context.orientation
      
      let isViewReadyClosure: (UIView) -> Bool = { view in
        var isOrientationCorrect = true
        
        // read again in case some weird code changed it outside the ViewControllerTestCase APIs
        let isViewInPortrait = view.frame.size.height > view.frame.size.width
        
        if context.orientation.isPortrait {
          isOrientationCorrect = isViewInPortrait
          
        } else if context.orientation.isLandscape {
          isOrientationCorrect = !isViewInPortrait
        }
        
        guard let view = view as? V else { fatalError("Wrong View Type") }
        
        let isReady = isOrientationCorrect && self.typeErasedIsViewReady(view, identifier: identifier)
        
        if isReady {
          self.configure(vc: vcs.contained, for: identifier)
        }
        
        return isReady
      }
      
      UITests.asyncSnapshot(view: vcs.container.view,
                            viewToWaitFor: vcs.contained.view,
                            description: description,
                            isViewReadyClosure: isViewReadyClosure) {
                              // ScrollViews snapshot
                              self.scrollViewsToTest(in: vcs.contained, identifier: identifier).forEach { entry in
                                UITests.snapshotScrollableContent(entry.value, description: "\(identifier)_scrollable_content \(screenSizeDescription)")
                              }
                              expectation.fulfill()
      }
      
      expectations.append(expectation)
    }
    
    self.wait(for: expectations, timeout: 100)
  }
  
  func typeErasedIsViewReady(_ view: V, identifier: String) -> Bool {
    return self.isViewReady(view, identifier: identifier)
  }
}

public extension UIViewControllerTestCase {
  /// The default implementation returns true
  func isViewReady(_ view: V, identifier: String) -> Bool {
    return true
  }
  
  func uiTest(testCases: [String]) {
    let standardContext = UITests.VCContext<V>()
    self.uiTest(testCases: testCases, context: standardContext)
  }
  
  func scrollViewsToTest(in view: VC, identifier: String) -> [String: UIScrollView] { return [:] }
}

/// Test a ViewController and its ViewControllerModellableView embedded in a Container with a specific ViewModel.
public protocol ViewControllerTestCase: UIViewControllerTestCase where VC: AnyViewController, V == VC.V {}

// MARK: Sub types
extension UITests {
  /// Struct that holds some information used to control how the view is rendered
  public struct VCContext<V: UIView> {
    
    /// the container in which the main view of the VC will be embedded
    public var container: UITests.Container
    
    /// some hooks that can be added to customize the view after its creation
    public var hooks: [UITests.Hook: UITests.HookViewClosure<V>]
    
    /// the size of the window in which the view will be rendered
    public var screenSize: CGSize
    
    /// the orientation of the view
    public var orientation: UIDeviceOrientation
    
    public init(container: Container = .none,
                hooks: [UITests.Hook: UITests.HookViewClosure<V>] = [:],
                screenSize: CGSize = UIScreen.main.bounds.size,
                orientation: UIDeviceOrientation = .portrait) {
      self.container = container
      self.hooks = hooks
      self.screenSize = screenSize
      self.orientation = orientation
    }
  }
}
