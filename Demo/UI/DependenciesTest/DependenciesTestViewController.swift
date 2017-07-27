//
//  StoryChatViewController.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 14/07/2017.
//

import Foundation
import UIKit
import Tempura
import Katana

class FakeManager {}

/// this is an example to show how we want to handle ViewControllers with dependencies

class DependenciesTestViewController: ViewController<DependenciesTestView, AppState, DependenciesTestViewModel> {
  
  let dumbManager: FakeManager
  
  init(dependency: FakeManager, store: AnyStore? = Tempura.store, connected: Bool = true) {
    guard let store = store else { fatalError("Tempura.store is not specified")}
    self.dumbManager = dependency
    super.init(store: store, connected: connected)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
}

