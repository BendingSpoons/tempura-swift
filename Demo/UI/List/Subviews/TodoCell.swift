//
//  TodoCollectionViewCell.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit
import Tempura
import PinLayout

public protocol SizeableCell: ModellableView {
  static func size(for model: VM) -> CGSize
}

class TodoCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
  
  static var identifierForReuse: String = "TodoCell"
  
  var label: UILabel = UILabel()
  var checkButton: UIButton = UIButton(type: .custom)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    self.addSubview(self.label)
    self.addSubview(self.checkButton)
  }
  func style() {
    self.backgroundColor = .white
    self.styleLabel()
    self.styleCheckButton()
  }
  
  func update(oldModel: TodoCellViewModel?) {
    guard let model = self.model else { return }
    self.label.text = model.todoText
    self.styleCheckButton(on: model.completed)
    self.setNeedsLayout()
  }
  
  static var paddingHeight: CGFloat = 10
  static var maxTextWidth: CGFloat = 0.80
  override func layoutSubviews() {
    guard let model = self.model else { return }
    self.checkButton.pin.size(30).vCenter().left(26)
    self.label.pin.top().bottom().left().right()
    let textWidth = self.bounds.width * TodoCell.maxTextWidth
    let textHeight = model.todoText.height(constraintedWidth: textWidth, font: UIFont.systemFont(ofSize: 17))
    self.label.pin.right(of: self.checkButton).marginLeft(13).vCenter().width(textWidth).height(textHeight)
  }
  
  // used by the auto sizable collectionView
  /*override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelSize = self.label.intrinsicContentSize
    
    return CGSize(
      width: UIScreen.main.bounds.width,
      height: labelSize.height + 2 * TodoCell.paddingHeight
    )
  }*/
  
  static func size(for model: TodoCellViewModel) -> CGSize {
    let textWidth = UIScreen.main.bounds.width * TodoCell.maxTextWidth
    let textHeight = model.todoText.height(constraintedWidth: textWidth, font: UIFont.systemFont(ofSize: 17))
    
    return CGSize(width: UIScreen.main.bounds.width,
                  height: textHeight + 2 * TodoCell.paddingHeight)
  }
}

// MARK: - Styling
extension TodoCell {
  func styleLabel() {
    self.label.font = UIFont.systemFont(ofSize: 17)
    self.label.numberOfLines = 0
  }
  func styleCheckButton(on: Bool = false) {
    if on {
      self.checkButton.setImage(UIImage(named: "checkOn"), for: .normal)
      self.checkButton.setImage(UIImage(named: "checkOff"), for: .highlighted)
    } else {
      self.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
      self.checkButton.setImage(UIImage(named: "checkOn"), for: .highlighted)
    }
  }
}

struct TodoCellViewModel: ViewModel, Hashable {
  var todoText: String = ""
  var completed: Bool = false
  
  var hashValue: Int {
    return todoText.hashValue
  }
  
  static func == (l: TodoCellViewModel, r: TodoCellViewModel) -> Bool {
    return l.todoText == r.todoText &&
      l.completed == r.completed
  }
  
  init(todo: Todo) {
    self.todoText = todo.text
    self.completed = todo.completed
  }
}

extension String {
  func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.text = self
    label.font = font
    label.sizeToFit()
    
    return label.frame.height
  }
}
