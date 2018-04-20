//
//  DemoTests.swift
//  DemoTests
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import XCTest
@testable import Demo
import Tempura
import Katana


class ScreenTests: XCTestCase {
  
  func testAddItemScreen() {

    /// simple test with one ViewModel
    test(AddItemView.self, with: AddItemViewModel(editingText: "this is a test"), container: .none, identifier: "addItem01")
    
    /// multiple test with two ViewModel, this will produce two distinct screenshots
    test(AddItemView.self, with: ["addItem02": AddItemViewModel(editingText: "this is another test"),
                                  "addItem03": AddItemViewModel(editingText: "what about this?")],
         container: .none)
    
    test(AddItemView.self,
         with: AddItemViewModel(editingText: "this is a test with hooks"),
         container: .none,
         identifier: "addItem04",
         hooks: [UITests.Hook.viewDidLoad: { view in
          view.viewController?.automaticallyAdjustsScrollViewInsets = true
        }])
  }
  
}
