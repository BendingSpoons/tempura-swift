//
//  AddItemView.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import UIKit
import Tempura

class AddItemView: UIView, ViewControllerModellableView {
  
  // MARK: - Subviews
  var backgroundView: UIView = UIView()
  var cancelButton: UIButton = UIButton(type: .custom)
  var textField: TextView = TextView()
  var deleteButton: UIButton = UIButton(type: .custom)
  
  // MARK: - Interactions
  var didTapCancel: Interaction?
  var didTapEnter: ((String) -> ())?
  var didTapDelete: Interaction?
  
  // MARK: - Setup
  func setup() {
    self.cancelButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapCancel?()
    }
    self.deleteButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapDelete?()
    }
    self.textField.didPressEnter = { [unowned self] in
      self.didTapEnter?(self.textField.text)
    }
    self.addSubview(self.backgroundView)
    self.addSubview(self.cancelButton)
    self.addSubview(self.textField)
    self.addSubview(self.deleteButton)
  }
  
  // MARK: Style
  func style() {
    self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    self.styleCancelButton()
    self.styleBackgroundView()
    self.styleTextField()
    self.styleDeleteButton()
  }
  
  // MARK: - Update
  func update(oldModel: AddItemViewModel?) {
    guard let model = self.model else { return }
    
    self.textField.text = model.editingText
    self.deleteButton.alpha = model.isEditingAlreadyExistingItem ? 1.0 : 0.0
  }
  
  // MARK: - Layout
  override func layoutSubviews() {
    self.cancelButton.pin.left().right().top().bottom()
    self.backgroundView.pin
      .left().marginLeft(20)
      .right().marginRight(20)
      .height(200)
      .top(self.universalSafeAreaInsets.top + 120)
    self.deleteButton.sizeToFit()
    self.deleteButton.pin
      .bottom(to: self.backgroundView.edge.bottom).marginBottom(10)
      .hCenter(-10)
    self.textField.pin
      .left(to: self.backgroundView.edge.left).marginLeft(20)
      .right(to: self.backgroundView.edge.right).marginRight(20)
      .top(to: self.backgroundView.edge.top).marginTop(30)
      .bottom(to: self.deleteButton.edge.top)
  }
}

// MARK: - Styling
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
  func styleDeleteButton() {
    self.deleteButton.backgroundColor = .white
    self.deleteButton.setTitle("Delete this item", for: .normal)
    self.deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    self.deleteButton.setTitleColor(UIColor(red: 0.98, green: 0.25, blue: 0.44, alpha: 1), for: .normal)
    self.deleteButton.setTitleColor(UIColor(red: 0.48, green: 0.0, blue: 0.14, alpha: 1), for: .highlighted)
    self.deleteButton.setImage(UIImage(named: "clearIcon"), for: .normal)
    self.deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
  }
}

// MARK: - View Model
struct AddItemViewModel: ViewModelWithLocalState {
  var editingText: String?
  
  var isEditingAlreadyExistingItem: Bool {
    return self.editingText != nil
  }
  
  init?(state: AppState?, localState: AddItemLocalState) {
    guard let state = state else { return nil }
    if let itemID = localState.itemID {
      let editingItem = state.items.first { $0.id == itemID }
      self.editingText = editingItem?.text
    }
  }
}
