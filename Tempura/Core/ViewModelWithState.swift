//
//  ViewModelWithState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 30/08/2017.
//
//

import Foundation
import Katana

public protocol ViewModelWithState: ViewModel {
  associatedtype S = State
  
  init(state: S)
  
}
