//
//  ViewControllerTests.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Katana
import UIKit
import XCTest
@testable import Tempura

class ViewControllerTests: XCTestCase {
  func testViewController_callsViewSetupAndViewStyleExactlyOnce() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)

    XCTAssertEqual(testVC.rootView.numberOfTimesSetupIsCalled, 1)
    XCTAssertEqual(testVC.rootView.numberOfTimesStyleIsCalled, 1)
  }

  func testViewController_whenViewModelUpdated_viewUpdateIsCalledWithCorrectParameters() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    let viewModel = TestViewModel(counter: 100)

    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)

    testVC.viewModel = viewModel
    XCTAssertEqual(testVC.rootView.lastOldModel?.counter, 0)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)
    XCTAssertEqual(testVC.rootView.model?.counter, 100)

    let newViewModel = TestViewModel(counter: 200)
    testVC.viewModel = newViewModel
    XCTAssertEqual(testVC.rootView.lastOldModel?.counter, 100)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 3)
    XCTAssertEqual(testVC.rootView.model?.counter, 200)
  }

  func testViewController_whenActionIsDispatched_whenViewControllerConnected_viewModelIsUpdated() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    testVC.viewWillAppear(true)

    XCTAssertEqual(testVC.rootView.model?.counter, 0)

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.model?.counter, 1)
  }

  func testViewController_whenActionIsDispatched_whenViewControllerIsNotConnected_viewModelIsNotUpdated() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    testVC.viewWillAppear(true)
    XCTAssertNotNil(testVC.rootView.model)
    XCTAssertEqual(testVC.rootView.model?.counter, 0)

    testVC.connected = false

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.model?.counter, 0)
  }

  func testViewController_whenDisconnected_updateIsCalledAtFirstConnect() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: false)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 0)
    testVC.connected = true
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
    testVC.connected = false
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
  }

  func testViewController_whenViewModelIsUpdated_willUpdateAndDidUpdateAreCalled() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.numberOfTimesWillUpdateIsCalled, 1)
    XCTAssertEqual(testVC.numberOfTimesDidUpdateIsCalled, 1)
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.numberOfTimesWillUpdateIsCalled, 2)
    XCTAssertEqual(testVC.numberOfTimesDidUpdateIsCalled, 2)
    XCTAssertEqual(testVC.viewModelWhenWillUpdateHasBeenCalled?.counter, 0)
    XCTAssertEqual(testVC.newViewModelWhenWillUpdateHasBeenCalled?.counter, 1)
    XCTAssertEqual(testVC.oldViewModelWhenDidUpdateHasBeenCalled?.counter, 0)
    XCTAssertEqual(testVC.viewModelWhenDidUpdateHasBeenCalled?.counter, 1)
  }

  func testViewController_whenDisconnected_whenShouldConnectWhenVisibleIsTrue_itConnectsWhenBecomingVisible() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: false)
    testVC.shouldConnectWhenVisible = true
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 0)
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
  }

  func testViewController_whenDisconnected_whenShouldConnectWhenVisibleIsFalse_itDoesNotConnectWhenBecomingVisible() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: false)
    testVC.shouldConnectWhenVisible = false
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 0)
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 0)
    testVC.shouldConnectWhenVisible = true
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
  }

  func testViewController_whenConnected_whenShouldDisconnectWhenVisibleIsTrue_itDisconnectsWhenBecomingInvisible() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    testVC.shouldDisconnectWhenInvisible = true
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)

    testVC.viewWillDisappear(true)
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)
  }

  func testViewController_whenConnected_whenShouldDisconnectWhenVisibleIsFalse_itDoesNotDisconnectWhenBecomingInvisible() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    testVC.shouldDisconnectWhenInvisible = false
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)

    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)

    testVC.viewWillDisappear(true)
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 3)
  }

  func testViewController_whenConnected_whenStateResultsInNilViewModel_shouldHaveNilViewModel() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewController(store: store, connected: true)
    XCTAssertNotNil(testVC.viewModel)

    self.waitForPromise(store.dispatch(ResetDataFromAPI()))
    XCTAssertNil(testVC.viewModel)
  }
}
