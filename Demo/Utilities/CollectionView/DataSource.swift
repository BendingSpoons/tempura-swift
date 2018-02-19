//
//  DataSource.swift
//  TempuraElements
//
//  Created by Andrea De Angelis on 10/01/2018.
//

import Foundation
import UIKit

// this class is implementing all the common methods of the UICollectionViewDataSource
// (like numberOfSections, numberOfItemsInSection, cellForItemAt) automatically,
// you can extend this class if you want to provide an implementation for all the other methods of UICollectionViewDataSource
// note that you still need to trigger reloadData() yourself
// if you are looking for a way to automatize the reloadData() or performBatchUpdates() when the data changes,
// look at the CollectionView class

public class DataSource<S: Source, Cell: UICollectionViewCell>: NSObject,
UICollectionViewDataSource where Cell: ConfigurableCell, Cell.VM == S.SourceType {
  
  public var source: S?
  
  public var configureInteractions: ((Cell, IndexPath) -> ())?
  
  unowned var collectionView: UICollectionView
  
  public init(collectionView: UICollectionView) {
    self.collectionView = collectionView
    super.init()
    collectionView.dataSource = self
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return self.source?.numberOfSections() ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.source?.numberOfRows(section: section) ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifierForReuse,
                                                             for: indexPath) as? Cell else { return UICollectionViewCell() }
    if let item = self.item(at: indexPath) {
      cell.model = item
    }
    
    self.configureInteractions?(cell, indexPath)
    
    return cell
  }
  
  public func item(at indexPath: IndexPath) -> S.SourceType? {
    guard indexPath.section >= 0,
      indexPath.row >= 0 else {
        return nil
    }
    return self.source?.data(section: indexPath.section, row: indexPath.row)
  }
  
}
