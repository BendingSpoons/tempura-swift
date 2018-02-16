//
//  AppState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Katana

struct AppState: State {
  var items: [Todo] = [
    Todo(text: "Pet my unicorn"),
    Todo(text: "Do something\nTwo lines"),
    Todo(text: "Keep doing")
  ]
  
  var pendingItems: [Todo] {
    return self.items.filter { !$0.archived }
  }
  
  var completedItems: [Todo] {
    return self.items.filter { $0.completed }
  }
  
  var archivedItems: [Todo] {
    return self.items.filter { $0.archived }
  }
  
  var archivableItems: [Todo] {
    return self.items.filter { $0.completed && !$0.archived }
  }
  
  var containsArchivableItems: Bool {
    return !self.archivableItems.isEmpty
  }
}
