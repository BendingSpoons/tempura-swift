//
//  DemoTests.swift
//  DemoTests
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import Katana
import Tempura
import TempuraTesting
import XCTest

@testable import Demo

class ScreenTests: XCTestCase, ViewTestCase {
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

  // Fifth test
  var fifthTestViewModel: AddItemViewModel {
    return AddItemViewModel(editingText: "this is a test with keyboard")
  }

  func testAddItemScreen() {
    self.uiTest(
      testCases: [
        "add_item_01": firstTestViewModel,
        "add_item_02": secondTestViewModel,
        "add_item_03": thirdTestViewModel,
        "add_item_05": thirdTestViewModel
      ],
      context: UITests.Context<AddItemView>(
        keyboardVisibility: { testCase in
          switch testCase {
          case "add_item_05": return .defaultHeight
          default: return .hidden
          }
        }
      )
    )
  }
  
  func testWithHooksAndContainer() {
    self.uiTest(
      testCases: [
        "add_item_04": fourthTestViewModel
      ],
      context: UITests.Context<AddItemView>(
        container: UITests.Container.tabBarController,
        hooks: [UITests.Hook.viewDidLoad: { view in
          view.viewController?.automaticallyAdjustsScrollViewInsets = true
        }]
      )
    )
  }
}

class VCTests: XCTestCase, ViewControllerTestCase {

  var viewController: AddItemViewController {
    let store = Store<VC.V.VM.S, EmptySideEffectDependencyContainer>()
    let vc = AddItemViewController(store: store)
    return vc
  }

  typealias VC = AddItemViewController

  var firstTestVM: AddItemViewModel {
    return AddItemViewModel(editingText: "ViewController test")
  }

  var secondTestVM: AddItemViewModel {
    return AddItemViewModel(editingText: "ViewController with keyboard test")
  }

  func testVC() {
    self.uiTest(
      testCases: [
      "firstTest": firstTestVM,
      "secondTestVM": secondTestVM,
      ],
      context: UITests.VCContext<VCTests.VC>(
        keyboardVisibility: { testCase in
          switch testCase {
          case "secondTestVM": return .defaultHeight
          default: return .hidden
          }
        }
      )
    )
  }
}

class UIVCTests: XCTestCase, UIViewControllerTestCase {
  typealias VC = UIViewController
  typealias V = UIView

  var viewController: UIViewController {
    let vc = UIViewController()
    return vc
  }
  
  func configure(vc: UIViewController, for testCase: String) {
    switch testCase {
    case "firstTest":
      vc.view.backgroundColor = .red
    case "secondTest":
      vc.view.backgroundColor = .yellow
    default:
      return
    }
  }

  func testUIVC() {
    self.uiTest(
      testCases: [
      "firstTest",
      "secondTest"
      ],
      context: UITests.VCContext<UIViewController>())
  }
}
