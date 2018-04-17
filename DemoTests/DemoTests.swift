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

class DemoTest: TempuraUITest {
  override var screenSnapshots: [AnyScreenSnapshot] {
    return [
      ScreenSnapshot<AddItemView>(
        type: AddItemView.self,
        container: .tabBarController,
        models: [
          "first": AddItemViewModel(editingText: "test"),
          "second": AddItemViewModel(editingText: "test2")
        ]
      )
    ]
  }
}
