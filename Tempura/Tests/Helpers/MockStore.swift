//
//  MockStore.swift
//  TempuraTests
//
//  Created by LorDisturbia on 28/04/21.
//

import Foundation
@testable import Katana

extension Store {
  static func mock(
    asyncProvider: AsyncProvider = ImmediateAsyncProvider()
  ) -> Store<MockAppState, EmptySideEffectDependencyContainer> {
    return .init(
      interceptors: [],
      stateInitializer: { MockAppState() },
      dependenciesInitializer: EmptySideEffectDependencyContainer.init(dispatch:getState:),
      configuration: .init(stateInitializerAsyncProvider: asyncProvider, listenersAsyncProvider: asyncProvider)
    )
  }
}

struct MockAppState: State {
  var counter: Int = 0
  var dataFromAPIRequest: String? = "something"
}

struct Increment: StateUpdater {
  func updateState(_ currentState: inout MockAppState) {
    currentState.counter += 1
  }
}

struct ResetDataFromAPI: StateUpdater {
  func updateState(_ currentState: inout MockAppState) {
    currentState.dataFromAPIRequest = nil
  }
}
