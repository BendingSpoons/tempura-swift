//
//  ImmediateAsyncProvider.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

/// An AsyncProvider that just executed the closure on the given thread. To be used for testing.
struct ImmediateAsyncProvider: AsyncProvider {
  func execute(_ closure: @escaping () -> Void) {
    closure()
  }
}
