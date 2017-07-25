//
//  Add.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana

public struct Add: AppAction {
  func updatedState(currentState: inout AppState) {
    currentState.counter = currentState.counter + 1
  }
}
