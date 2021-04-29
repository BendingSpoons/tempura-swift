//
//  AppState.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

struct AppState: State {
  var items: [Todo] = [
    Todo(text: "Pet my unicorn"),
    Todo(text: "Become a doctor.\nChange last name to Acula"),
    Todo(text: "Hire two private investigators.\nGet them to follow each other"),
    Todo(text: "Visit mars"),
  ]

  var pendingItems: [Todo] {
    return self.items.filter { !$0.archived }
  }

  var completedItems: [Todo] {
    return self.items.filter { $0.completed }
  }

  var uncompletedItems: [Todo] {
    return self.items.filter { !$0.completed }
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
