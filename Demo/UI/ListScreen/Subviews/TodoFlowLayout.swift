//
//  AutoSizingFlowLayout.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit

final class TodoFlowLayout: UICollectionViewFlowLayout {
  
  var insertingIndexes: [IndexPath] = []
  var removingIndexes: [IndexPath] = []

  override init() {
    super.init()
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  private func setup() {
    self.minimumLineSpacing = 0
    self.minimumInteritemSpacing = 0
  }
  
  override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    super.prepare(forCollectionViewUpdates: updateItems)
    updateItems.forEach {
      if $0.indexPathBeforeUpdate == nil {
        if let index = $0.indexPathAfterUpdate {
          self.insertingIndexes.append(index)
        }
      } else if $0.indexPathAfterUpdate == nil {
        if let index = $0.indexPathBeforeUpdate {
          self.removingIndexes.append(index)
        }
      }
    }
  }
  
  override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
    guard self.removingIndexes.contains(itemIndexPath) else { return attributes }
    let frame = CGRect(x: attributes.frame.minX + attributes.frame.width,
                       y: attributes.frame.minY,
                       width: attributes.frame.width,
                       height: attributes.frame.height)
    attributes.frame = frame
    return attributes
  }
  
  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()
    self.insertingIndexes = []
    self.removingIndexes = []
  }
}
