//
//  XCTestCase+Promise.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Hydra
import XCTest

extension XCTestCase {
  func waitForPromise<T>(_ promise: Promise<T>) {
    let expectation = self.expectation(description: "Promise completed")
    promise.then(in: .main) { _ in expectation.fulfill() }

    self.wait(for: [expectation], timeout: 10)
  }
}
