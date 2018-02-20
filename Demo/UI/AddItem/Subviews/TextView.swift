//
//  TextField.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import UIKit
import Tempura

class TextView: UITextView, UITextViewDelegate {
  
  override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
    super.init(frame: frame, textContainer: textContainer)
    self.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Interaction
  var didPressEnter: Interaction?
  
  // MARK: - TextView Delegate
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text.rangeOfCharacter(from: CharacterSet.newlines) != nil {
      self.didPressEnter?()
      return false
    }
    return true
  }
}
