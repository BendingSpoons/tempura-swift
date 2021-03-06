//
//  NavigationWitnessTests.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Hydra
import Tempura
import XCTest

class NavigationWitnessTests: XCTestCase {
  func testLiveShow_dispatchesTempuraShow() {
    var showCalls = 0

    let navigationWitness: NavigationWitness = .live(dispatch: { dispatchable in
      showCalls += 1
      let showSideEffect = dispatchable as? Show
      switch showCalls {
      case 1:
        XCTAssertEqual(showSideEffect?.identifiersToShow, ["first"])
        XCTAssertEqual(showSideEffect?.animated, true)
        XCTAssertNil(showSideEffect?.context)
      case 2:
        XCTAssertEqual(showSideEffect?.identifiersToShow, ["second"])
        XCTAssertEqual(showSideEffect?.animated, false)
        XCTAssertEqual(showSideEffect?.context as? Int, 3)
      default:
        XCTFail("dispatch should not be called more than twice")
      }
      return Promise(resolved: ())
    })

    _ = navigationWitness.show("first", animated: true, context: nil)
    _ = navigationWitness.show("second", animated: false, context: 3)

    XCTAssertEqual(showCalls, 2)
  }

  func testLiveHide_dispatchesTempuraShow() {
    var hideCalls = 0

    let navigationWitness: NavigationWitness = .live(dispatch: { dispatchable in
      hideCalls += 1
      let showSideEffect = dispatchable as? Hide
      switch hideCalls {
      case 1:
        XCTAssertEqual(showSideEffect?.identifierToHide, "first")
        XCTAssertEqual(showSideEffect?.animated, true)
        XCTAssertNil(showSideEffect?.context)
        XCTAssertEqual(showSideEffect?.atomic, false)
      case 2:
        XCTAssertEqual(showSideEffect?.identifierToHide, "second")
        XCTAssertEqual(showSideEffect?.animated, false)
        XCTAssertEqual(showSideEffect?.context as? Int, 3)
        XCTAssertEqual(showSideEffect?.atomic, true)
      default:
        XCTFail("dispatch should not be called more than twice")
      }
      return Promise(resolved: ())
    })

    _ = navigationWitness.hide("first", animated: true, context: nil, atomic: false)
    _ = navigationWitness.hide("second", animated: false, context: 3, atomic: true)

    XCTAssertEqual(hideCalls, 2)
  }

  func testMockShow_appendsTheNavigationRequest() {
    let navigationRequests = NavigationRequests()
    let navigationWitness: NavigationWitness = .mocked(appendTo: navigationRequests)
    _ = navigationWitness.show("first", animated: false, context: nil)
    XCTAssertEqual(navigationRequests, [.show("first")])
    _ = navigationWitness.show("second", animated: true, context: 5)
    XCTAssertEqual(navigationRequests, [.show("first"), .show("second")])
  }

  func testMockHide_appendsTheNavigationRequest() {
    let navigationRequests = NavigationRequests()
    let navigationWitness: NavigationWitness = .mocked(appendTo: navigationRequests)
    _ = navigationWitness.show("first", animated: false, context: nil)
    XCTAssertEqual(navigationRequests, [.show("first")])
    _ = navigationWitness.show("second", animated: true, context: 5)
    XCTAssertEqual(navigationRequests, [.show("first"), .show("second")])
    _ = navigationWitness.hide("second", animated: true, context: 5)
    XCTAssertEqual(navigationRequests, [.show("first"), .show("second"), .hide("second")])
    _ = navigationWitness.hide("first", animated: false, context: nil)
    XCTAssertEqual(navigationRequests, [.show("first"), .show("second"), .hide("second"), .hide("first")])
  }
}
