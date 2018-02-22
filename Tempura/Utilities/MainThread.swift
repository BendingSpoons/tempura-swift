//
//  MainThread.swift
//  Tempura
//
//  Created by Andrea De Angelis on 22/02/2018.
//

import Foundation

public func mainThread(_ block: () -> ()) {
  if !Thread.isMainThread {
    DispatchQueue.main.sync {
      block()
    }
  } else {
    block()
  }
}

public func mainThread<T>(_ block: () -> (T)) -> T {
  var result: T!
  mainThread {
    result = block()
  }
  return result
}
