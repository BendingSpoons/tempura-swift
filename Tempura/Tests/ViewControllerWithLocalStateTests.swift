//
//  ViewControllerWithLocalStateTests.swift
//  TempuraTests
//
//  Created by LorDisturbia on 28/04/21.
//

import Katana
import XCTest
@testable import Tempura

class ViewControllerWithLocalStateTests: XCTestCase {
  func testViewControllerWithLocalState_whenViewModelIsUpdated_updateIsCalledWithTheCorrectParameters() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewControllerWithLocalState(store: store, connected: true)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
    XCTAssertNil(testVC.rootView.lastOldModel)

    testVC.viewModel = TestViewModelWithLocalState(counter: 100, localCounter: 200)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)
    XCTAssertEqual(testVC.rootView.model?.counter, 100)
    XCTAssertEqual(testVC.rootView.model?.localCounter, 200)

    testVC.viewModel = TestViewModelWithLocalState(counter: 101, localCounter: 201)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 3)
    XCTAssertEqual(testVC.rootView.lastOldModel?.counter, 100)
    XCTAssertEqual(testVC.rootView.lastOldModel?.localCounter, 200)
    XCTAssertEqual(testVC.rootView.model?.counter, 101)
    XCTAssertEqual(testVC.rootView.model?.localCounter, 201)
  }

  func testViewControllerWithLocalState_whenLocalStateChanges_viewModelIsUpdated() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewControllerWithLocalState(store: store, connected: true)
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.rootView.model?.localCounter, 0)
    testVC.localState.localCounter = 11
    XCTAssertEqual(testVC.rootView.model?.localCounter, 11)
  }

  func testViewControllerWithLocalState_whenLocalStateChanges_whenViewControllerDisconnected_viewModelIsPartiallyUpdated() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewControllerWithLocalState(store: store, connected: true)
    testVC.viewWillAppear(true)
    testVC.connected = false

    XCTAssertEqual(testVC.rootView.model?.localCounter, 0)

    testVC.localState.localCounter = 11
    XCTAssertEqual(testVC.rootView.model?.localCounter, 11)
    XCTAssertEqual(testVC.rootView.model?.counter, 0)

    // check if the dispatch of the Increment is not resetting the local state
    self.waitForPromise(store.dispatch(Increment()))
    XCTAssertEqual(testVC.rootView.model?.localCounter, 11)
    XCTAssertEqual(testVC.rootView.model?.counter, 0)
  }

  func testViewControllerWithLocalState_whenViewControllerAppears_updateIsCalledOnce() throws {
    let store = Store<MockAppState, EmptySideEffectDependencyContainer>.mock()
    let testVC = TestViewControllerWithLocalState(store: store, connected: true)

    // ViewControllerWithLocalState will trigger an update upon creation even if it's disconnected
    // because it needs to update the ViewModel based on the localState
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 1)
    testVC.viewWillAppear(true)
    XCTAssertEqual(testVC.rootView.numberOfTimesUpdateIsCalled, 2)
  }
}

// MARK: - Helpers

extension ViewControllerWithLocalStateTests {
  struct TestLocalState: LocalState {
    var localCounter: Int = 0
  }

  struct TestViewModelWithLocalState: ViewModelWithLocalState {
    var counter: Int?
    var localCounter: Int = 0

    init(state: MockAppState?, localState: TestLocalState) {
      self.counter = state?.counter
      self.localCounter = localState.localCounter
    }

    init(counter: Int?, localCounter: Int) {
      self.counter = counter
      self.localCounter = localCounter
    }
  }

  class TestViewWithLocalState: UIView, ViewControllerModellableView {
    var numberOfTimesSetupIsCalled: Int = 0
    var numberOfTimesStyleIsCalled: Int = 0
    var numberOfTimesUpdateIsCalled: Int = 0
    var lastOldModel: TestViewModelWithLocalState?

    typealias VM = TestViewModelWithLocalState
    func setup() {
      self.numberOfTimesSetupIsCalled += 1
    }

    func style() {
      self.numberOfTimesStyleIsCalled += 1
    }

    func update(oldModel: TestViewModelWithLocalState?) {
      self.numberOfTimesUpdateIsCalled += 1
      self.lastOldModel = oldModel
    }

    override func layoutSubviews() {}
  }

  class TestViewControllerWithLocalState: ViewControllerWithLocalState<TestViewWithLocalState> {
    var numberOfTimesWillUpdateIsCalled: Int = 0
    var viewModelWhenWillUpdateHasBeenCalled: TestViewModelWithLocalState?
    var newViewModelWhenWillUpdateHasBeenCalled: TestViewModelWithLocalState?
    var numberOfTimesDidUpdateIsCalled: Int = 0
    var viewModelWhenDidUpdateHasBeenCalled: TestViewModelWithLocalState?
    var oldViewModelWhenDidUpdateHasBeenCalled: TestViewModelWithLocalState?

    override func willUpdate(new: TestViewModelWithLocalState?) {
      self.numberOfTimesWillUpdateIsCalled += 1
      self.viewModelWhenWillUpdateHasBeenCalled = self.viewModel
      self.newViewModelWhenWillUpdateHasBeenCalled = new
    }

    override func didUpdate(old: TestViewModelWithLocalState?) {
      self.numberOfTimesDidUpdateIsCalled += 1
      self.viewModelWhenDidUpdateHasBeenCalled = self.viewModel
      self.oldViewModelWhenDidUpdateHasBeenCalled = old
    }

    init(store: PartialStore<V.VM.S>, connected: Bool = false) {
      let localState = TestLocalState()
      super.init(store: store, localState: localState, connected: connected)
    }

    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}
