//
//  ViewControllerTestCase.swift
//  Tempura
//
//  Created by Andrea De Angelis on 22/11/2018.
//

import Foundation
import XCTest
import Tempura


public protocol ViewControllerTestCase {
  associatedtype VC: AnyViewController
  
  /**
   Add new UI tests to be performed
   
   - parameter testCases: a dictionary of test cases, where the key is the identifier and the value the
   view model to use to render the view
   - parameter context: a context used to pass information and control how the view should be rendered
   */
  func uiTest(testCases: [String], context: UITests.VCContext<VC>)
  
  /**
   Method used to check whether the view is ready to be snapshotted
   - parameter view: the view that will be snapshotted
   - parameter identifier: the test case identifier
   */
  func isViewReady(_ view: VC.V, identifier: String) -> Bool
  
  /// used to provide the VC, we cannot instantiate it as we cannot require an init in the AnyViewController protocol
  /// otherwise it will require all of the subclasses to have that init
  var viewController: VC { get }
  
  /// configure the VC for the specified `testCase`
  /// this is when you manually inject the ViewModel to all the children VCs
  func configure(vc: VC, for testCase: String)
}


public extension ViewControllerTestCase where Self: XCTestCase {
  public func uiTest(testCases: [String], context: UITests.VCContext<VC>) {
    let snapshotConfiguration = UITests.VCScreenSnapshot<VC>(
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
        
        let isReady = isOrientationCorrect && self.typeErasedIsViewReady(view, identifier: identifier)
        
        if isReady {
          self.configure(vc: vcs.contained, for: identifier)
        }
        
        return isReady
      }
      
      UITests.asyncSnapshot(view: vcs.container.view,
                            viewToWaitFor: (vcs.contained as! UIViewController).view,
                            description: description,
                            isViewReadyClosure: isViewReadyClosure) {
                              expectation.fulfill()
      }
      
      expectations.append(expectation)
    }
    
    self.wait(for: expectations, timeout: 100)
  }
  
  func typeErasedIsViewReady(_ view: UIView, identifier: String) -> Bool {
    guard let view = view as? VC.V else {
      return false
    }
    return self.isViewReady(view, identifier: identifier)
  }
}

public extension ViewControllerTestCase {
  /// The default implementation returns true
  public func isViewReady(_ view: VC.V, identifier: String) -> Bool {
    return true
  }
  
  public func uiTest(testCases: [String]) {
    let standardContext = UITests.VCContext<VC>()
    self.uiTest(testCases: testCases, context: standardContext)
  }
}

// MARK: Sub types
extension UITests {
  /// Struct that holds some information used to control how the view is rendered
  public struct VCContext<VC: AnyViewController> {
    
    /// the container in which the main view of the VC will be embedded
    public var container: UITests.Container
    
    /// some hooks that can be added to customize the view after its creation
    public var hooks: [UITests.Hook: UITests.HookClosure<VC.V>]
    
    /// the size of the window in which the view will be rendered
    public var screenSize: CGSize
    
    /// the orientation of the view
    public var orientation: UIDeviceOrientation
    
    public init(container: Container = .none,
                hooks: [UITests.Hook: UITests.HookClosure<VC.V>] = [:],
                screenSize: CGSize = UIScreen.main.bounds.size,
                orientation: UIDeviceOrientation = .portrait) {
      self.container = container
      self.hooks = hooks
      self.screenSize = screenSize
      self.orientation = orientation
    }
  }
}
