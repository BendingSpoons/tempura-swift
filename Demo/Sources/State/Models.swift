//
//  Models.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 10/07/2017.
//

import Foundation
import UIKit

struct Todo: Equatable {
  let id: String
  var text: String
  var completed: Bool
  var archived: Bool

  init(text: String, completed: Bool = false) {
    self.id = String.random(length: 16)
    self.text = text
    self.completed = completed
    self.archived = false
  }

  static func == (l: Todo, r: Todo) -> Bool {
    return l.id == r.id && l.text == r.text
  }
}
