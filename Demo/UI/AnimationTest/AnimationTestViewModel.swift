//
//  AnimationTestViewModel.swift
//  Tempura
//
//  Created by Andrea De Angelis on 01/08/2017.
//
//

import Foundation
import Tempura

struct AnimationTestViewModel: ViewModelWithLocalState {

  
  var expanded: Bool = false
  
  init() {}
  
  init(state: AppState?, localState: AnimationTestLocalState) {
    self.expanded = localState.expanded
  }
}
