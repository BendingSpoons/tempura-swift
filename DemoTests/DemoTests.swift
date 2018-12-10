//
//  DemoTests.swift
//  DemoTests
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import XCTest
@testable import Demo
import Tempura
import TempuraTesting
import Katana


class ScreenTests: XCTestCase, UITestCase {
//  
  typealias V = AddItemView
  
  // First test
  var firstTestViewModel: AddItemViewModel {
    return AddItemViewModel(editingText: "this is a test")
  }
  
  // Second test
  var secondTestViewModel: AddItemViewModel {
    return AddItemViewModel(editingText: "this is another test")
  }
  
  // Third test
  var thirdTestViewModel: AddItemViewModel {
    return AddItemViewModel(editingText: "what about this?")
  }
  
  // Fourth test
  var fourthTestViewModel: AddItemViewModel {
    return AddItemViewModel(editingText: "this is a test with hooks")
  }
  
  func testAddItemScreen() {
    self.uiTest(testCases: [
      "add_item_01": firstTestViewModel,
      "add_item_02": secondTestViewModel,
      "add_item_03": thirdTestViewModel
      ])
    
  }
  
  func testWithHooksAndContainer() {
    self.uiTest(testCases: [
      "add_item_04": fourthTestViewModel
      ],
      context: UITests.Context<AddItemView>(
        container: UITests.Container.tabBarController,
        hooks: [UITests.Hook.viewDidLoad: { view in
          view.viewController?.automaticallyAdjustsScrollViewInsets = true
        }])
      )
  }
  
}

class VCTests: XCTestCase, UIVCTestCase {
  
  var viewController: AddItemViewController {
    let store = Store<VC.V.VM.S, EmptySideEffectDependencyContainer>()
    let vc = AddItemViewController(store: store)
    return vc
  }
  
  typealias VC = AddItemViewController
  
  func configure(vc: AddItemViewController, for testCase: String) {
    if testCase == "firstTest" {
      vc.rootView.model = AddItemViewModel(editingText: "ViewController test")
    }
  }
  

  func testVC() {
    self.uiTest(testCases: ["firstTest"], context: UITests.VCContext<VCTests.VC>())
  }
}
