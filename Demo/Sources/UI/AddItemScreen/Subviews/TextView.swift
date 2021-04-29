//
//  TextField.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import Tempura
import UIKit

class TextView: UITextView, UITextViewDelegate {
  // MARK: Interactions

  var didPressEnter: Interaction?

  // MARK: - Init

  override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
    super.init(frame: frame, textContainer: textContainer)
    self.delegate = self
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - TextView Delegate

  func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
    if text.rangeOfCharacter(from: CharacterSet.newlines) != nil {
      self.didPressEnter?()
      return false
    }
    return true
  }
}
