//
//  ChildViewController.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Tempura
import UIKit

struct ChildViewModel: ViewModelWithState {
  var numberOfTodosContent: String
  init?(state: AppState) {
    self.numberOfTodosContent = "There are \(state.uncompletedItems.count) items pending"
  }
}

class ChildView: UIView, ViewControllerModellableView {
  var label = UILabel()

  func setup() {
    self.addSubview(self.label)
  }

  func style() {
    self.backgroundColor = UIColor(red: 78.0 / 255.0, green: 205.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
    self.label.textColor = .black
    self.label.font = UIFont.systemFont(ofSize: 20)
    self.label.textAlignment = .center
  }

  func update(oldModel _: ChildViewModel?) {
    self.label.text = self.model?.numberOfTodosContent ?? ""
  }

  override func layoutSubviews() {
    self.label.sizeToFit()
    self.label.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
  }
}

class ChildViewController: ViewController<ChildView> {}
