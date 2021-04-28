//
//  XCTestCase+Promise.swift
//  TempuraTests
//
//  Created by LorDisturbia on 28/04/21.
//

import Foundation
import Hydra
import XCTest

extension XCTestCase {
  func waitForPromise<T>(_ promise: Promise<T>) {
    let expectation = self.expectation(description: "Promise completed")
    promise.then(in: .main) { _ in expectation.fulfill() }

    self.wait(for: [expectation], timeout: .greatestFiniteMagnitude)
  }
}
