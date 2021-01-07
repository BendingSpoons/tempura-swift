//
//  UITestCaseKeyValidator.swift
//  TempuraTesting
//
//  Created by Rouven Strauss on 07/01/2021.
//

import Foundation

/// Mutable data structure for ensuring that sets of given keys are disjoint from previously provided keys.
class UITestCaseKeyValidator {
  /// Singleton instance of this class.
  static let singletonInstance = UITestCaseKeyValidator()

  /// Mapping of keys to test case names with which the `validate` method of this instance has been invoked.
  private var keysToTestCaseNames = [String: String]()

  /// Initializes a new instance.
  private init() {}

  /// Validates that the given `keys` of the test case with the given `testCaseName` are disjoint from any keys previously
  /// provided to this method. If a duplicate key is found, the method fatally errs.
  func validate(keys: Set<String>, ofTestCaseWithName testCaseName: String) {

    keys.forEach {
      if let previousTestCaseName = self.keysToTestCaseNames[$0] {
        fatalError("Duplication detected. Key \($0) used both in \(testCaseName) and \(previousTestCaseName)")
      }

      self.keysToTestCaseNames[$0] = testCaseName
    }
  }
}
