//
//  AsyncUITest.swift
//  Tempura
//
//  Created by Mauro Bolis on 07/05/2018.
//

import Foundation
import XCTest
import Tempura

public protocol AsyncUITest {
  associatedtype V: UIView & ViewControllerModellableView
  
  func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>], size: CGSize)
  func isViewReady(_ view: V) -> Bool
}

public extension AsyncUITest where Self: XCTestCase {
  func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>], size: CGSize) {
    let snapshotConfiguration = UITests.ScreenSnapshot<V>(type: V.self, container: container, models: [identifier: model], hooks: hooks, size: size)
    let viewControllers = snapshotConfiguration.renderingViewControllers
    let screenSizeDescription: String = "\(UIScreen.main.bounds.size)"

    var expectations: [XCTestExpectation] = []

    for (identifier, vc) in viewControllers {
      let description = "\(identifier) \(screenSizeDescription)"

      let expectation = XCTestExpectation(description: description)

      UITests.asyncSnapshot(view: vc.view, description: description, isViewReadyClosure: self.typeErasedIsViewReady) {
        expectation.fulfill()
      }

      expectations.append(expectation)
    }

    self.wait(for: expectations, timeout: 100)
  }
  
  func typeErasedIsViewReady(_ view: UIView) -> Bool {
    return self.isViewReady(view as! V)
  }
}

public extension AsyncUITest {
  func isViewReady(_ view: V) -> Bool {
    return true
  }
  
  func uiTest(model: V.VM, identifier: String) {
    self.uiTest(model: model, identifier: identifier, container: .none, hooks: [:], size: UIScreen.main.bounds.size)
  }
  
  func uiTest(model: V.VM, identifier: String, container: UITests.Container) {
    self.uiTest(model: model, identifier: identifier, container: container, hooks: [:], size: UIScreen.main.bounds.size)
  }
  
  func uiTest(model: V.VM, identifier: String, container: UITests.Container, hooks: [UITests.Hook: UITests.HookClosure<V>]) {
    self.uiTest(model: model, identifier: identifier, container: container, hooks: hooks, size: UIScreen.main.bounds.size)
  }
}
