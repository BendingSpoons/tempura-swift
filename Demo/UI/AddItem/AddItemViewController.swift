//
//  AddItemViewController.swift
//  Demo
//
//  Created by Andrea De Angelis on 19/02/2018.
//

import UIKit
import Katana
import Tempura

class AddItemViewController: ViewControllerWithLocalState<AddItemView> {
  
  init(store: Store<AppState>, itemIDToEdit: String? = nil) {
    super.init(store: store, connected: false)
    self.localState.itemID = itemIDToEdit
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.rootView.textField.becomeFirstResponder()
  }
  
  override func setupInteraction() {
    self.rootView.didTapCancel = { [unowned self] in
      self.dispatch(Hide())
    }
    self.rootView.didTapEnter = { [unowned self] text in
      if let editingID = self.localState.itemID {
        self.dispatch(EditItem(id: editingID, text: text))
      } else {
        self.dispatch(AddItem(text: text))
      }
      self.dispatch(Hide())
    }
    self.rootView.didTapDelete = { [unowned self] in
      guard let editingID = self.localState.itemID else { return }
      self.dispatch(DeleteItem(id: editingID))
      self.dispatch(Hide())
    }
  }
}

struct AddItemLocalState: LocalState {
  /// if we are editing an existing item, this will contain the ID of that item
  var itemID: String? = nil
}
