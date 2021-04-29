//
//  ImmediateAsyncProvider.swift
//  TempuraTests
//
//  Created by LorDisturbia on 28/04/21.
//

import Foundation
import Katana

/// An AsyncProvider that just executed the closure on the given thread. To be used for testing.
struct ImmediateAsyncProvider: AsyncProvider {
  func execute(_ closure: @escaping () -> Void) {
    closure()
  }
}
