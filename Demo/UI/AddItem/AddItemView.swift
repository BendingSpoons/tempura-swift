//
//  AddItemView.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import UIKit
import Tempura

class AddItemView: UIView, ViewControllerModellableView {
  
  var backgroundView: UIView = UIView()
  var cancelButton: UIButton = UIButton(type: .custom)
  var textField: TextView = TextView()
  
  func setup() {
    self.cancelButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapCancel?()
    }
    self.textField.didPressEnter = { [unowned self] in
      self.didTapEnter?(self.textField.text)
    }
    self.addSubview(self.backgroundView)
    self.addSubview(self.cancelButton)
    self.addSubview(self.textField)
  }
  
  func style() {
    self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    self.styleCancelButton()
    self.styleBackgroundView()
    self.styleTextField()
  }
  
  func update(oldModel: AddItemViewModel?) {
    
  }
  
  // MARK: - Interactions
  var didTapCancel: Interaction?
  var didTapEnter: ((String) -> ())?
  
  override func layoutSubviews() {
    self.cancelButton.pin.left().right().top().bottom()
    self.backgroundView.pin
      .left().marginLeft(20)
      .right().marginRight(20)
      .height(200)
      .top(self.universalSafeAreaInsets.top + 50)
    self.textField.pin
      .left(to: self.backgroundView.edge.left).marginLeft(20)
      .right(to: self.backgroundView.edge.right).marginRight(20)
      .top(to: self.backgroundView.edge.top).marginTop(30)
      .bottom(to: self.backgroundView.edge.bottom).marginBottom(30)
  }
}

// MARK: - Style
extension AddItemView {
  func styleCancelButton() {
    self.cancelButton.backgroundColor = .clear
  }
  func styleBackgroundView() {
    self.backgroundView.backgroundColor = .white
    self.backgroundView.layer.cornerRadius = 20
  }
  func styleTextField() {
    self.textField.backgroundColor = .white
    self.textField.font = UIFont.systemFont(ofSize: 17)
  }
}

struct AddItemViewModel: ViewModelWithState {
  
  init?(state: AppState) {
    
  }
}
