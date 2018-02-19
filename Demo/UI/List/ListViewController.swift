//
//  ListViewController.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit
import Tempura

class ListViewController: ViewControllerWithLocalState<ListView> {
  override func setup() {
    super.setup()
    // we want to keep this connected also when the AddItem screen is shown on top
    self.shouldDisconnectWhenInvisible = false
  }
  
  override func setupInteraction() {
    self.rootView.didToggleItem = { [unowned self] id in
      self.dispatch(ToggleItem(itemID: id))
    }
    self.rootView.didTapTodoSection = { [unowned self] in
      if self.localState.selectedSection != .todo {
        self.localState.selectedSection = .todo
      }
    }
    self.rootView.didTapCompletedSection = { [unowned self] in
      if self.localState.selectedSection != .completed {
        self.localState.selectedSection = .completed
      }
    }
    self.rootView.didTapArchive = { [unowned self] toBeArchivedIDs in
      self.dispatch(ToggleArchiveItems(ids: toBeArchivedIDs))
    }
    self.rootView.didUnarchiveItem = { [unowned self] toBeUnarchivedID in
      self.dispatch(ToggleArchiveItems(ids: [toBeUnarchivedID], archived: false))
    }
    self.rootView.didTapAddItem = { [unowned self] in
      self.dispatch(Show(Screen.addItem))
    }
    self.rootView.didTapEditItem = { [unowned self] itemID in
      self.dispatch(Show(Screen.addItem, animated: false, context: itemID))
    }
  }
}

struct ListLocalState: LocalState {
  var selectedSection: ListView.Section = .todo
}

extension ListView {
  enum Section {
    case todo
    case completed
  }
}
