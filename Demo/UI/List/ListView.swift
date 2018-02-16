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
  var doneButton: UIButton = UIButton(type: .custom)
  var scrollView: UIScrollView = UIScrollView()
  var todoListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var doneListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var archiveButton: UIButton = UIButton(type: .custom)
  
  // MARK: - Interactions
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
    self.todoListView.didTapItem = { indexPath in
      guard let itemID = self.model?.todos[indexPath.item].id else { return }
      self.didToggleItem?(itemID)
    }
    let doneLayout = ArchiveFlowLayout()
    self.doneListView = CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>(frame: .zero, layout: doneLayout)
    self.doneListView.useDiffs = true
    self.doneListView.didTapItem = { indexPath in
      guard let itemID = self.model?.archived[indexPath.item].id else { return }
      self.didUnarchiveItem?(itemID)
    }
    self.todoButton.on(.touchUpInside) { [unowned self] button in
      self.didTapTodoSection?()
    }
    self.doneButton.on(.touchUpInside) { [unowned self] button in
      self.didTapCompletedSection?()
    }
    self.archiveButton.on(.touchUpInside) { [unowned self] button in
      guard let model = self.model else { return }
      let toBeArchivedIDs: [String] = model.archivable.map { $0.id }
      self.didTapArchive?(toBeArchivedIDs)
    }
    self.scrollView.addSubview(self.todoListView)
    self.scrollView.addSubview(self.doneListView)
    self.addSubview(self.scrollView)
    self.addSubview(self.todoButton)
    self.addSubview(self.doneButton)
    self.addSubview(self.archiveButton)
  }
  
  // MARK: - Style
  func style() {
    self.backgroundColor = .white
    self.styleTodoListView()
    self.styleDoneListView()
    self.styleArchiveButton()
  }
  
  // MARK: - Update
  func update(oldModel: ListViewModel?) {
    guard let model = self.model, oldModel != self.model else { return }
    let todos = model.todos.map { TodoCellViewModel(todo: $0) }
    self.todoListView.source = SimpleSource<TodoCellViewModel>(todos)
    let archived = model.archived.map { TodoCellViewModel(todo: $0) }
    self.doneListView.source = SimpleSource<TodoCellViewModel>(archived)
    self.styleTodoButton(selected: model.selectedSection == .todo)
    self.styleDoneButton(selected: model.selectedSection == .completed)
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
      self.doneButton.blink()
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
    self.doneButton.pin.size(36).right(32).vCenter(to: self.todoButton.edge.vCenter)
    self.scrollView.pin.below(of: todoButton).marginTop(34).left().right().bottom()
    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width * 2, height: self.scrollView.bounds.height)
    self.todoListView.frame = self.scrollView.frame.bounds
    self.doneListView.frame = self.todoListView.frame.offsetBy(dx: self.scrollView.bounds.width, dy: 0)
    guard let model = self.model else { return }
    self.archiveButton.pin.size(CGSize(width: 260, height: 58)).hCenter()
    if model.containsArchivableItems && model.selectedSection == .todo {
      self.archiveButton.pin.bottom(self.universalSafeAreaInsets.bottom + 20)
    } else {
      self.archiveButton.pin.below(of: self)
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
  func styleDoneButton(selected: Bool = false) {
    if selected {
      self.doneButton.setImage(UIImage(named: "archiveSectionIconS"), for: .normal)
    } else {
     self.doneButton.setImage(UIImage(named: "archiveSectionIcon"), for: .normal)
    }
  }
  func styleTodoListView() {
    self.todoListView.backgroundColor = .white
  }
  func styleDoneListView() {
    self.doneListView.backgroundColor = .white
  }
  func styleArchiveButton() {
    self.archiveButton.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.92, alpha: 1)
    self.archiveButton.layer.cornerRadius = 13
    self.archiveButton.setImage(UIImage(named: "archiveSectionIconSmallS"), for: .normal)
    self.archiveButton.setImage(UIImage(named: "archiveSectionIconSmall"), for: .highlighted)
    self.archiveButton.setTitle("Archive completed items", for: .normal)
    self.archiveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    self.archiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    self.archiveButton.setTitleColor(.black, for: .normal)
    self.archiveButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
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
