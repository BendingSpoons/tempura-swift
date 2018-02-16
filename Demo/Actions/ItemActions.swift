//
//  MarkItem.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import Katana

struct ToggleItem: AppAction {
  var itemID: String
  
  func updatedState(currentState: inout AppState) {
    let position = currentState.items.index { $0.id == itemID }
    guard let index = position else { return }
    currentState.items[index].completed = !currentState.items[index].completed
  }
}

struct ToggleArchiveItems: AppAction {
  var ids: [String]
  var archived: Bool
  
  init(ids: [String], archived: Bool = true) {
    self.ids = ids
    self.archived = archived
  }
  
  func updatedState(currentState: inout AppState) {
    let positions = ids.flatMap { [currentState] id -> Int? in
      currentState.items.index { $0.id == id }
    }
    positions.forEach {
      currentState.items[$0].archived = archived
    }
  }
}
