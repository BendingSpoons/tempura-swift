//
//  MockViewControllers.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Tempura
import UIKit

class SpyViewController<V: UIView & ViewControllerModellableView>: ViewController<V> {
  var numberOfTimesWillUpdateIsCalled: Int = 0
  var viewModelWhenWillUpdateHasBeenCalled: V.VM?
  var newViewModelWhenWillUpdateHasBeenCalled: V.VM?
  var numberOfTimesDidUpdateIsCalled: Int = 0
  var viewModelWhenDidUpdateHasBeenCalled: V.VM?
  var oldViewModelWhenDidUpdateHasBeenCalled: V.VM?

  override func willUpdate(new: V.VM?) {
    self.numberOfTimesWillUpdateIsCalled += 1
    self.viewModelWhenWillUpdateHasBeenCalled = self.viewModel
    self.newViewModelWhenWillUpdateHasBeenCalled = new
  }

  override func didUpdate(old: V.VM?) {
    self.numberOfTimesDidUpdateIsCalled += 1
    self.viewModelWhenDidUpdateHasBeenCalled = self.viewModel
    self.oldViewModelWhenDidUpdateHasBeenCalled = old
  }
}

struct TestViewModel: ViewModelWithState {
  var counter: Int = 0

  init?(state: MockAppState) {
    guard let _ = state.dataFromAPIRequest else { return nil }
    self.counter = state.counter
  }

  init(counter: Int) {
    self.counter = counter
  }
}

class TestView: UIView, ViewControllerModellableView {
  var numberOfTimesSetupIsCalled: Int = 0
  var numberOfTimesStyleIsCalled: Int = 0
  var numberOfTimesUpdateIsCalled: Int = 0
  var lastOldModel: TestViewModel?

  typealias VM = TestViewModel
  func setup() {
    self.numberOfTimesSetupIsCalled += 1
  }

  func style() {
    self.numberOfTimesStyleIsCalled += 1
  }

  func update(oldModel: TestViewModel?) {
    self.numberOfTimesUpdateIsCalled += 1
    self.lastOldModel = oldModel
  }

  override func layoutSubviews() {}
}

class TestViewController: SpyViewController<TestView> {}
