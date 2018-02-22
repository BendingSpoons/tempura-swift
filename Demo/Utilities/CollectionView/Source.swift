//
//  Source.swift
//  TempuraElements
//
//  Created by Andrea De Angelis on 10/01/2018.
//

import Foundation
import UIKit
import DeepDiff

/// Source protocol defines the methods needed to automatically implement a
/// UICollectionViewDataSource delegate around a specific type of data `SourceType`
public protocol Source {
  associatedtype SourceType: Equatable
  func numberOfSections() -> Int
  func numberOfRows(section: Int) -> Int
  func data(section: Int, row: Int) -> SourceType?
  
  /// perform the diff update of the collectionView transitioning from old to self
  /// the `readyToUpdateDataSource` callback needs to be triggered when it's safe to update the dataSource
  func diffUpdate(for collectionView: UICollectionView, old: Self)
}

/// SimpleSource is the default implementation of a Source used for a simple
/// UICollectionView with only one section. This is using [T] as main data structure
public class SimpleSource<T: Hashable>: Source {
  private var items: [T] = []
  
  public init(_ items: [T]) {
    self.items = items
  }
  
  public func numberOfSections() -> Int {
    return 1
  }
  
  public func numberOfRows(section: Int) -> Int {
    guard section == 0 else { return 0 }
    return self.items.count
  }
  
  public func data(section: Int, row: Int) -> T? {
    guard section == 0, row < self.items.count else { return nil }
    return self.items[row]
  }
  
  public func diffUpdate(for collectionView: UICollectionView, old: SimpleSource<T>) {
    //collectionView.animateItemChanges(oldData: old.items, newData: self.items, readyToUpdateDataSource: readyToUpdateDataSource)
    let changes = diff(old: old.items, new: self.items)
    collectionView.reload(changes: changes) { _ in }
  }
}

/// SimpleSource is the default implementation of a Source used for a generic
/// UICollectionView with more than one section. This is [[T]] as main data structure
public class SourceWithSections<T: Equatable>: Source {
  
  private var items: [[T]] = []
  
  public init(_ items: [[T]]) {
    self.items = items
  }
  
  public func numberOfSections() -> Int {
    return self.items.count
  }
  
  public func numberOfRows(section: Int) -> Int {
    guard section < self.items.count else { return 0 }
    return self.items[section].count
  }
  
  public func data(section: Int, row: Int) -> T? {
    guard section < self.items.count, row < self.items[section].count else { return nil }
    return self.items[section][row]
  }
  
  /// Current Swift Implementation (4.0.3) is not supporting Conditional Conformance
  /// This means that it cannot infer that [[T]] is equatable when T is equatable
  public func diffUpdate(for collectionView: UICollectionView,
                         old: SourceWithSections<T>) {
    fatalError("""
      diff updates for Sections are not yet implemented, we need Conditional Conformance in Swift
      (https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md)
      """)
  }
}
