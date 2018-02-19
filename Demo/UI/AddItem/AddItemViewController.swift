//
//  AddItemViewController.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import UIKit
import Tempura

class AddItemViewController: ViewController<AddItemView> {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.rootView.textField.becomeFirstResponder()
  }
  
  override func setupInteraction() {
    self.rootView.didTapCancel = { [unowned self] in
      self.dispatch(Hide())
    }
    self.rootView.didTapEnter = { [unowned self] text in
      self.dispatch(AddItem(text: text))
      self.dispatch(Hide())
    }
  }
}
