//
//  CollectionView.swift
//  TempuraElements
//
//  Created by Andrea De Angelis on 10/01/2018.
//

import Foundation
import UIKit

/// CollectionView is a subclass of `UICollectionView` that doesn't require you to implement `UICollectionViewDataSource` methods
/// It has a `source` property, assigning your data structure to that, the collectionView will update itself
/// If you want to update the single items that are changed
/// instead of reloading everything (will use `reloadData()` behind the scenes),
/// set the `useDiffs` property to `true` and the CollectionView will automatically take care of that
/// (using 'performBatchUpdates()' on the changes)

open class CollectionView<Cell: UICollectionViewCell, S: Source>: UICollectionView,
UICollectionViewDelegateFlowLayout  where Cell: ConfigurableCell & SizeableCell, Cell.VM == S.SourceType {
  
  public typealias ItemSelectionHandler = (IndexPath) -> ()
  
  public var customDataSource: DataSource<S, Cell>!
  
  open var source: S? {
    set {
      // we are not updating the `customDataSource` right away in order to support `performBatchUpdates`
      // given that right before the update the system will call the `numberOfItemsInSection` method of the delegate
      // and we need to specify the oldSource count for that to work
      self.oldSource = self.customDataSource.source
      self.update(from: self.oldSource, new: newValue)
    }
    
    get {
      return self.customDataSource.source
    }
  }
  
  // old source used in the diff updates
  private var oldSource: S?
  
  open var useDiffs: Bool
  
  public init(frame: CGRect, layout: UICollectionViewLayout, source: S? = nil, useDiffs: Bool = false) {
    self.useDiffs = useDiffs
    super.init(frame: frame, collectionViewLayout: layout)
    self.customDataSource = DataSource<S, Cell>(collectionView: self)
    self.register(Cell.self, forCellWithReuseIdentifier: Cell.identifierForReuse)
    self.delegate = self
    self.source = source
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func update(from old: S?, new: S?) {
    guard let old = old, self.useDiffs else {
      self.customDataSource.source = new
      self.reloadData()
      return
    }
    
    self.customDataSource.source = new
    // we are using `performBatchUpdates` here, we will update the customDataSource only inside the callback
    // because we still need the old dataSource in the first stage od the `performBatchUpdates`
    new?.diffUpdate(for: self, old: old)
  }
  
  // MARK: - Interactions
  open var didTapItem: ItemSelectionHandler?
  open var configureInteractions: ((Cell, IndexPath) -> ())? {
    didSet {
      self.customDataSource.configureInteractions = self.configureInteractions
    }
  }
  open var didTapEdit: ((String) -> ())?
  
  
  // MARK: - UICollectionViewDelegate
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.didTapItem?(indexPath)
  }
  
  open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let vm = source?.data(section: indexPath.section, row: indexPath.row) else { return .zero }
    return Cell.size(for: vm)
  }
}
