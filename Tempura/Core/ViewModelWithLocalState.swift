//
//  ViewModelWithLocalState.swift
//  Tempura
//
//  Created by Andrea De Angelis on 31/07/2017.
//
//

import Foundation

public protocol ViewModelWithLocalState: ViewModel {
  associatedtype LS: LocalState
  
  mutating func updateLocalState(with localState: LS)
}
