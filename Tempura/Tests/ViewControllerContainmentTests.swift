//
//  ViewControllerContainmentTests.swift
//  TempuraTests
//
//  Created by LorDisturbia on 28/04/21.
//

import Katana
import XCTest
import UIKit
@testable import Tempura

class ViewControllerContainmentTests: XCTestCase {
  func testContainment_whenStateIsChanged_updateOnChildVCIsCalled() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    mainVC.viewWillAppear(true)
    XCTAssertEqual(mainVC.rootView.model?.counter, 0)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(mainVC.rootView.model?.counter, 1)
    XCTAssertEqual(childVC.rootView.model?.counter, 1)
  }

  func testContainment_hasChildViewAsChildOfParentView() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)
  }

  func testContainment_whenChildDisconnected_itStopsReceivingUpdates() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    mainVC.viewWillAppear(true)
    XCTAssertEqual(mainVC.rootView.model?.counter, 0)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)

    childVC.connected = false
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(mainVC.rootView.model?.counter, 1)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)
  }

  func testContainment_whenChildRemovedFromParentVC_isRemovedFromViewHierarchy() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)
    childVC.remove()
    XCTAssertNil(childVC.rootView.superview)
  }

  func testContainment_whenChildRemovedFromParentVC_stopsReceivingUpdates() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)

    childVC.remove()
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(mainVC.rootView.model?.counter, 1)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)
  }

  func testContainment_whenUsingTransitions_theOldChildOfParentViewIsRemoved() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)

    let secondChildVC = ChildViewController(store: store, connected: true)
    mainVC.transition(to: secondChildVC, in: mainVC.rootView.container, duration: 0)
    XCTAssertNil(childVC.rootView.superview)
  }

  func testContainment_whenUsingTransitions_theNewChildHasTheMainViewAsSuperview() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)

    let secondChildVC = ChildViewController(store: store, connected: true)
    mainVC.transition(to: secondChildVC, in: mainVC.rootView.container, duration: 0)
    XCTAssertEqual(secondChildVC.rootView.superview, mainVC.rootView.container)
  }

  func testContainment_whenUsingTransitions_theOldChildOfParentViewStopsReceivingUpdates() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let mainVC = MainViewController(store: store, connected: true)
    let childVC = ChildViewController(store: store, connected: true)

    mainVC.add(childVC, in: mainVC.rootView.container)
    XCTAssertEqual(childVC.rootView.superview, mainVC.rootView.container)

    let secondChildVC = ChildViewController(store: store, connected: true)
    mainVC.transition(to: secondChildVC, in: mainVC.rootView.container, duration: 0)
    mainVC.viewWillAppear(true)
    XCTAssertEqual(mainVC.rootView.model?.counter, 0)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(mainVC.rootView.model?.counter, 1)
    XCTAssertEqual(childVC.rootView.model?.counter, 0)
    XCTAssertEqual(secondChildVC.rootView.model?.counter, 1)
  }
}

// MARK: - Helpers

fileprivate extension ViewControllerContainmentTests {
  class MainView: TestView {
    var container: ContainerView = ContainerView()

    override func setup() {
      super.setup()
      self.addSubview(self.container)
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      self.container.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    }
  }

  class ChildView: TestView {}

  class MainViewController: SpyViewController<MainView> {}

  class ChildViewController: SpyViewController<ChildView> {}
}
