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


class UITests: XCTestCase {
  
  func testAddItemScreen() {

    test(AddItemView.self, with: AddItemViewModel(editingText: "this is a test"), container: .none, identifier: "addItem01")
    
    test(AddItemView.self, with: ["addItem02": AddItemViewModel(editingText: "this is another test"),
                                  "addItem03": AddItemViewModel(editingText: "what about this?")],
         container: .none)
  }
  
}
