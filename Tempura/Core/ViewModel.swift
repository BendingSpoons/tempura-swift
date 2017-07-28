//
//  ViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

public protocol ViewModel {
  associatedtype S = State
  init()
  
  // TODO: change in mutating
  mutating func updated(with state: S)
}
