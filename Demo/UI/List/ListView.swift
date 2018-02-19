//
//  ListView.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit
import Tempura
import PinLayout

class ListView: UIView, ViewControllerModellableView {
  
  // MARK: - Subviews
  var todoButton: UIButton = UIButton(type: .custom)
  var archiveButton: UIButton = UIButton(type: .custom)
  var addItemButton: UIButton = UIButton(type: .custom)
  var scrollView: UIScrollView = UIScrollView()
  var todoListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var archiveListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var sendToArchiveButton: UIButton = UIButton(type: .custom)
  
  // MARK: - Interactions
  var didTapAddItem: Interaction?
  var didTapEditItem: ((String) -> ())?
  var didToggleItem: ((String) -> ())?
  var didUnarchiveItem: ((String) -> ())?
  var didTapTodoSection: Interaction?
  var didTapCompletedSection: Interaction?
  var didTapArchive: (([String]) -> ())?
  
  // MARK: - Setup
  func setup() {
    self.scrollView.isPagingEnabled = true
    self.scrollView.isScrollEnabled = false
    let todoLayout = TodoFlowLayout()
    self.todoListView = CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>(frame: .zero, layout: todoLayout)
    self.todoListView.useDiffs = true
    let doneLayout = ArchiveFlowLayout()
    self.archiveListView = CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>(frame: .zero, layout: doneLayout)
    self.archiveListView.useDiffs = true
    self.addItemButton.on(.touchUpInside) { [unowned self] button in
      self.didTapAddItem?()
    }
    self.todoButton.on(.touchUpInside) { [unowned self] button in
      self.didTapTodoSection?()
    }
    self.archiveButton.on(.touchUpInside) { [unowned self] button in
      self.didTapCompletedSection?()
    }
    self.sendToArchiveButton.on(.touchUpInside) { [unowned self] button in
      guard let model = self.model else { return }
      let toBeArchivedIDs: [String] = model.archivable.map { $0.id }
      self.didTapArchive?(toBeArchivedIDs)
    }
    self.todoListView.configureInteractions = { [unowned self] cell, indexPath in
      cell.didTapEdit = { [unowned self] id in
        self.didTapEditItem?(id)
      }
      cell.didToggle = { [unowned self] itemID in
        self.didToggleItem?(itemID)
      }
    }
    self.archiveListView.configureInteractions = { [unowned self] cell, indexPath in
      cell.didTapEdit = { [unowned self] id in
        self.didTapEditItem?(id)
      }
      cell.didToggle = { [unowned self] itemID in
        self.didUnarchiveItem?(itemID)
      }
    }
    self.scrollView.addSubview(self.todoListView)
    self.scrollView.addSubview(self.archiveListView)
    self.addSubview(self.scrollView)
    self.addSubview(self.todoButton)
    self.addSubview(self.archiveButton)
    self.addSubview(self.addItemButton)
    self.addSubview(self.sendToArchiveButton)
  }
  
  // MARK: - Style
  func style() {
    self.backgroundColor = .white
    self.styleTodoListView()
    self.stylearchiveListView()
    self.styleAddItemButton()
    self.stylesendToArchiveButton()
  }
  
  // MARK: - Update
  func update(oldModel: ListViewModel?) {
    guard let model = self.model, oldModel != self.model else { return }
    let todos = model.todos.map { TodoCellViewModel(todo: $0) }
    self.todoListView.source = SimpleSource<TodoCellViewModel>(todos)
    let archived = model.archived.map { TodoCellViewModel(todo: $0) }
    self.archiveListView.source = SimpleSource<TodoCellViewModel>(archived)
    self.styleTodoButton(selected: model.selectedSection == .todo)
    self.stylearchiveButton(selected: model.selectedSection == .completed)
    // switch to selected section
    if model.selectedSection != oldModel?.selectedSection {
      if case .todo = model.selectedSection {
        self.scrollView.setContentOffset(.zero, animated: true)
      } else {
        let offset: CGPoint = CGPoint(x: self.scrollView.bounds.width, y: 0)
        self.scrollView.setContentOffset(offset, animated: true)
      }
    }
    // archive button update
    if let om = oldModel, model.containsArchivableItems != om.containsArchivableItems ||
      model.selectedSection != om.selectedSection {
      UIView.animate(withDuration: 0.3,
                     delay: 0.0,
                     usingSpringWithDamping: 0.9,
                     initialSpringVelocity: 1.0,
                     options: [.curveEaseInOut], animations: {
                      self.setNeedsLayout()
                      self.layoutIfNeeded()
      }, completion: nil)
    }
    // blink archive icon if needed
    if let om = oldModel,
      model.archived.count > om.archived.count,
      model.selectedSection == .todo {
      self.archiveButton.blink()
    }
    // blink todo icon if needed
    if let om = oldModel,
      model.archived.count < om.archived.count,
      model.selectedSection == .completed {
      self.todoButton.blink()
    }
  }
  
  // MARK: - Layout
  override func layoutSubviews() {
    // we are using PinLayout here but you can use the layout system you want
    self.todoButton.sizeToFit()
    self.todoButton.pin.left(30).top(self.universalSafeAreaInsets.top + 20)
    self.archiveButton.pin.size(36).right(32).vCenter(to: self.todoButton.edge.vCenter)
    self.addItemButton.pin.left().right().below(of: todoButton).marginTop(34).height(50)
    self.scrollView.pin.below(of: self.addItemButton).left().right().bottom()
    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width * 2, height: self.scrollView.bounds.height)
    self.todoListView.frame = self.scrollView.frame.bounds
    self.archiveListView.frame = self.todoListView.frame.offsetBy(dx: self.scrollView.bounds.width, dy: 0)
    guard let model = self.model else { return }
    self.sendToArchiveButton.pin.size(CGSize(width: 260, height: 58)).hCenter()
    if model.containsArchivableItems && model.selectedSection == .todo {
      self.sendToArchiveButton.pin.bottom(self.universalSafeAreaInsets.bottom + 20)
      let bottomInset = self.frame.height - self.sendToArchiveButton.frame.minY
      self.todoListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    } else {
      self.sendToArchiveButton.pin.below(of: self)
      self.todoListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
  }
}

// MARK: - Styling
extension ListView {
  func styleTodoButton(selected: Bool = true) {
    self.todoButton.setTitle("To Do", for: .normal)
    if selected {
      self.todoButton.setTitleColor(.black, for: .normal)
      self.todoButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
    } else {
      self.todoButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
      self.todoButton.setTitleColor(.black, for: .highlighted)
    }
    self.todoButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
  }
  func stylearchiveButton(selected: Bool = false) {
    if selected {
      self.archiveButton.setImage(UIImage(named: "archiveSectionIconS"), for: .normal)
    } else {
     self.archiveButton.setImage(UIImage(named: "archiveSectionIcon"), for: .normal)
    }
  }
  func styleTodoListView() {
    self.todoListView.backgroundColor = .white
  }
  func stylearchiveListView() {
    self.archiveListView.backgroundColor = .white
  }
  func styleAddItemButton() {
    self.addItemButton.backgroundColor = .white
    self.addItemButton.setTitle("What are you going to do today?", for: .normal)
    self.addItemButton.setTitleColor(UIColor(red: 0.98, green: 0.25, blue: 0.44, alpha: 1), for: .normal)
    self.addItemButton.setTitleColor(UIColor(red: 0.48, green: 0.0, blue: 0.14, alpha: 1), for: .highlighted)
    self.addItemButton.titleLabel?.textAlignment = .left
    self.addItemButton.setImage(UIImage(named: "add"), for: .normal)
    self.addItemButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
    self.addItemButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
  }
  func stylesendToArchiveButton() {
    self.sendToArchiveButton.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.92, alpha: 1)
    self.sendToArchiveButton.layer.cornerRadius = 13
    self.sendToArchiveButton.setImage(UIImage(named: "archiveSectionIconSmallS"), for: .normal)
    self.sendToArchiveButton.setImage(UIImage(named: "archiveSectionIconSmall"), for: .highlighted)
    self.sendToArchiveButton.setTitle("Archive completed items", for: .normal)
    self.sendToArchiveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    self.sendToArchiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    self.sendToArchiveButton.setTitleColor(.black, for: .normal)
    self.sendToArchiveButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
  }
}

// MARK: - View Model
struct ListViewModel: ViewModelWithLocalState, Equatable {
  var todos: [Todo]
  var archived: [Todo]
  var selectedSection: ListView.Section = .todo
  var archivable: [Todo]
  var containsArchivableItems: Bool {
    return !archivable.isEmpty
  }
  
  init?(state: AppState?, localState: ListLocalState) {
    guard let state = state else { return nil }
    self.todos = state.pendingItems
    self.archived = state.archivedItems
    self.selectedSection = localState.selectedSection
    self.archivable = state.archivableItems
  }
  
  static func == (l: ListViewModel, r: ListViewModel) -> Bool {
    if l.todos != r.todos { return false }
    if l.archived != r.archived { return false }
    if l.selectedSection != r.selectedSection { return false }
    if l.archivable != r.archivable { return false }
    return true
  }
}
