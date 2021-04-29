//
//  ListView.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import PinLayout
import Tempura
import UIKit

class ListView: UIView, ViewControllerModellableView {
  // MARK: - Subviews

  var todoButton = UIButton(type: .custom)
  var archiveButton = UIButton(type: .custom)
  var actionButton = UIButton(type: .custom)
  var scrollView = UIScrollView()
  var todoListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var archiveListView: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>!
  var sendToArchiveButton = UIButton(type: .custom)
  // the view of the child view controller
  var childViewContainer = ContainerView()

  // MARK: - Interactions

  var didTapAddItem: Interaction?
  var didTapClearItems: Interaction?
  var didTapEditItem: ((String) -> Void)?
  var didToggleItem: ((String) -> Void)?
  var didUnarchiveItem: ((String) -> Void)?
  var didTapTodoSection: Interaction?
  var didTapCompletedSection: Interaction?
  var didTapArchive: (([String]) -> Void)?

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

    self.actionButton.on(.touchUpInside) { [unowned self] _ in
      guard let model = self.model else { return }
      if model.selectedSection == .todo {
        self.didTapAddItem?()
      } else {
        self.didTapClearItems?()
      }
    }
    self.todoButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapTodoSection?()
    }
    self.archiveButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapCompletedSection?()
    }
    self.sendToArchiveButton.on(.touchUpInside) { [unowned self] _ in
      guard let model = self.model else { return }
      let toBeArchivedIDs: [String] = model.archivable.map { $0.id }
      self.didTapArchive?(toBeArchivedIDs)
    }
    self.todoListView.configureInteractions = { [unowned self] cell, _ in
      cell.didTapEdit = { [unowned self] id in
        self.didTapEditItem?(id)
      }
      cell.didToggle = { [unowned self] itemID in
        self.didToggleItem?(itemID)
      }
    }
    self.archiveListView.configureInteractions = { [unowned self] cell, _ in
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
    self.addSubview(self.actionButton)
    self.addSubview(self.sendToArchiveButton)
    self.addSubview(self.childViewContainer)
  }

  // MARK: - Style

  func style() {
    self.backgroundColor = .white
    self.styleTodoListView()
    self.stylearchiveListView()
    self.stylesendToArchiveButton()
  }

  // MARK: - Update

  func update(oldModel: ListViewModel?) {
    guard let model = self.model, oldModel != self.model else { return }

    self.styleActionButton(section: model.selectedSection)
    self.styleTodoButton(selected: model.selectedSection == .todo)
    self.stylearchiveButton(selected: model.selectedSection == .archived)

    let todos = model.todos.map { TodoCellViewModel(todo: $0) }
    self.todoListView.source = SimpleSource<TodoCellViewModel>(todos)
    let archived = model.archived.map { TodoCellViewModel(todo: $0) }
    self.archiveListView.source = SimpleSource<TodoCellViewModel>(archived)

    // switch to selected section
    if model.selectedSection != oldModel?.selectedSection {
      if case .todo = model.selectedSection {
        self.scrollView.setContentOffset(.zero, animated: true)
      } else {
        let offset = CGPoint(x: self.scrollView.bounds.width, y: 0)
        self.scrollView.setContentOffset(offset, animated: true)
      }
    }
    // archive button update
    if let om = oldModel, model.containsArchivableItems != om.containsArchivableItems ||
      model.selectedSection != om.selectedSection {
      UIView.animate(
        withDuration: 0.3,
        delay: 0.0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1.0,
        options: [.curveEaseInOut],
        animations: {
          self.setNeedsLayout()
          self.layoutIfNeeded()
        },
        completion: nil
      )
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
       model.todos.count > om.todos.count,
       model.selectedSection == .archived {
      self.todoButton.blink()
    }
    // hide action button when needed
    if model.selectedSection == .archived, model.archived.isEmpty {
      self.actionButton.alpha = 0.0
    } else {
      self.actionButton.alpha = 1.0
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    // we are using PinLayout here but you can use the layout system you want
    self.todoButton.sizeToFit()
    self.todoButton.pin.left(30).top(self.universalSafeAreaInsets.top + 70)
    self.archiveButton.pin.size(36).right(32).vCenter(to: self.todoButton.edge.vCenter)
    self.actionButton.pin.left().right().below(of: self.todoButton).marginTop(24).height(50)
    self.scrollView.pin.below(of: self.actionButton).left().right().bottom()
    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width * 2, height: self.scrollView.bounds.height)
    self.todoListView.frame = self.scrollView.frame.bounds
    self.archiveListView.frame = self.todoListView.frame.offsetBy(dx: self.scrollView.bounds.width, dy: 0)
    guard let model = self.model else { return }
    if model.containsArchivableItems, model.selectedSection == .todo {
      self.sendToArchiveButton.pin.hCenter().bottom(self.universalSafeAreaInsets.bottom + 85).height(6%).width(60%)
      let bottomInset = self.frame.height - self.sendToArchiveButton.frame.minY
      self.todoListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    } else {
      self.sendToArchiveButton.pin.below(of: self)
      self.todoListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    self.childViewContainer.pin.bottom().left().right().height(80)
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

  func styleActionButton(section: ListView.Section) {
    self.actionButton.backgroundColor = .white
    self.actionButton.setTitleColor(UIColor(red: 0.98, green: 0.25, blue: 0.44, alpha: 1), for: .normal)
    self.actionButton.setTitleColor(UIColor(red: 0.48, green: 0.0, blue: 0.14, alpha: 1), for: .highlighted)
    self.actionButton.titleLabel?.textAlignment = .left
    self.actionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
    self.actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)

    if section == .todo {
      self.actionButton.setTitle("What are you going to do today?", for: .normal)
      self.actionButton.setImage(UIImage(named: "add"), for: .normal)
    } else {
      self.actionButton.setTitle("Clear archived items", for: .normal)
      self.actionButton.setImage(UIImage(named: "clearIcon"), for: .normal)
    }
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
    return !self.archivable.isEmpty
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

// MARK: - List sections

extension ListView {
  enum Section {
    case todo
    case archived
  }
}
