//
//  UITestCaseKeyValidator.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation

/// Mutable data structure for ensuring that sets of given keys are disjoint from previously provided keys.
///
/// @note Data structure is thread-safe.
class UITestCaseKeyValidator {
  /// Singleton instance of this class.
  static let singletonInstance = UITestCaseKeyValidator()

  /// Mapping of keys to test case names with which the `validate` method of this instance has been invoked.
  private var keysToTestCaseNames = [String: String]()

  /// Lock used internally for thread-safety.
  private let lock = NSRecursiveLock()

  /// Initializes a new instance.
  private init() {}

  /// Validates that the given `keys` of the test case with the given `testCaseName` are disjoint from any keys previously
  /// provided to this method. If a duplicate key is found, the method fatally errs.
  func validate(keys: Set<String>, ofTestCaseWithName testCaseName: String) {
    self.lock.lock()

    keys.forEach {
      if let previousTestCaseName = self.keysToTestCaseNames[$0] {
        fatalError("Duplication detected. Key \($0) used both in \(testCaseName) and \(previousTestCaseName)")
      }

      self.keysToTestCaseNames[$0] = testCaseName
    }

    self.lock.unlock()
  }
}
