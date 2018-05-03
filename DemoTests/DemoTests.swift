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
    test(AddItemView.self, with: AddItemViewModel(editingText: "this is a test"), identifier: "addItem01")
    
    /// multiple test with two ViewModel, this will produce two distinct screenshots
    test(AddItemView.self, with: ["addItem02": AddItemViewModel(editingText: "this is another test"),
                                  "addItem03": AddItemViewModel(editingText: "what about this?")],
         container: .none)
    
    /// test with hooks to configure the ViewController after the viewDidLoad
    test(AddItemView.self,
         with: AddItemViewModel(editingText: "this is a test with hooks"),
         identifier: "addItem04",
         container: .tabBarController,
         hooks: [UITests.Hook.viewDidLoad: { view in
          view.viewController?.automaticallyAdjustsScrollViewInsets = true
        }])
    
    /// test with a custom ViewController used a container of the ViewController to test
    test(AddItemView.self,
         with: AddItemViewModel(editingText: "this is a test with a custom Container ViewController"),
         identifier: "addItem05",
         container: .custom({ addItemViewController in
          let containerVC = UITabBarController()
          containerVC.viewControllers = [addItemViewController]
          return containerVC
         }))
  }
  
}
