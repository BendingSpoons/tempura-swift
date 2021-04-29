//
//  AddItemViewController.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Katana
import Tempura
import UIKit

class AddItemViewController: ViewControllerWithLocalState<AddItemView> {
  init(store: PartialStore<AppState>, itemIDToEdit: String? = nil) {
    super.init(store: store, localState: AddItemLocalState(), connected: false)
    self.localState.itemID = itemIDToEdit
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.rootView.textField.becomeFirstResponder()
  }

  // listen for interactions from the view
  // dispatch actions or change the local state in response to user actions
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

// MARK: - Local State

struct AddItemLocalState: LocalState {
  /// if we are editing an existing item, this will contain the ID of that item
  var itemID: String? = nil
}
