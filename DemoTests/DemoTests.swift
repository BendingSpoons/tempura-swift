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

class DemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
      
      let store = Store<AppState>(middleware: [], dependencies: DependenciesContainer.self)
      let vc = ListViewController(store: store)
      uiTest(vc: vc)
      let model = ListViewModel(state: nil, localState: ListLocalState())
      uiTest(view: ListView.self, viewModel: model!)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
