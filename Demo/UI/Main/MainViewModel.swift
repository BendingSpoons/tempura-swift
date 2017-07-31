//
//  MainViewModel.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import Tempura

struct MainViewModel: ViewModel {
  
  var count: String = ""
  
  mutating func update(with state: AppState) {
    self.count = "the counter is at \(state.counter)"
  }
  
  init() {}
}
