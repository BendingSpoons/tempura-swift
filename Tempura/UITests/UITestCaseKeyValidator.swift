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

  /// Set of keys with which the `validate` method of this instance has been invoked.
  private var keys = Set<String>()

  /// Initializes a new instance.
  private init() {}

  /// Validates that the given `keys` are disjoint from any keys previously provided to this method. If a duplicate key is found,
  /// the method fatally errs.
  func validate(keys: Set<String>) {
    guard self.keys.isDisjoint(with: keys) else {
      fatalError("Key duplication: \(keys)")
    }

    keys.forEach {
      self.keys.insert($0)
    }
  }
}
