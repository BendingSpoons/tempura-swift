//
//  MainThread.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation

func mainThread(_ block: () -> Void) {
  if !Thread.isMainThread {
    DispatchQueue.main.sync {
      block()
    }
  } else {
    block()
  }
}

func mainThread<T>(_ block: () -> T) -> T {
  var result: T! // swiftlint:disable:this implicitly_unwrapped_optional
  mainThread {
    result = block()
  }
  return result
}
