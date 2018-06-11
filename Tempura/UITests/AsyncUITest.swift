//
//  AsyncUITest.swift
//  Tempura
//
//  Created by Mauro Bolis on 07/05/2018.
//

import Foundation
import XCTest
import Tempura

extension UITests {
  public struct Context<V: ViewControllerModellableView> {
    var container: UITests.Container
    var hooks: [UITests.Hook: UITests.HookClosure<V>]
    var screenSize: CGSize
    
    init() {
      self.container = .none
      self.hooks = [:]
      self.screenSize = UIScreen.main.bounds.size
    }
  }
}

@available(*, deprecated: 1.9, message: "Use UITestCase instead")
public typealias AsyncUITest = UITestCase

/**
 AsyncUITest is a more complex form of UITest that is used when the UI cannot be rendered immediately.
 This happens for instance when things that are shown in the screen are taken from a remote server.
 
 The idea is that the view is rendered but the system waits until `isViewReady` returns true to take the snapshot
 and pass to the next test case. `isViewReady` is invoked various times with the view instance. The method should be implemented
 so that it checks possible things that may not be ready yet and return true only when the view is ready to be snapshotted.
 
 Note that this is a protocol as XCode fails to recognize subclasses of XCTestCase's subclasses that are written in Swift.
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
  
  func uiTest(testCases: [String: V.VM], context: UITests.Context<V>)
  
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

      let isViewReadyClosure: (UIView) -> Bool = { view in
        return self.typeErasedIsViewReady(view, identifier: identifier)
      }

      UITests.asyncSnapshot(view: vc.view, description: description, isViewReadyClosure: isViewReadyClosure) {
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

public extension AsyncUITest {
  /// The default implementation returns true
  public func isViewReady(_ view: V, identifier: String) -> Bool {
    return self.isViewReady(view)
  }
  
  public func uiTest(testCases: [String: V.VM]) {
    let standardContext = UITests.Context<V>()
    self.uiTest(testCases: testCases, context: standardContext)
  }
}

// MARK: Deprecated
public extension AsyncUITest {
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
