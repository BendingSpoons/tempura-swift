//
//  HomeCollectionViewLayout.swift
//  KatanaExperiment
//
//  Created by Mauro Bolis on 16/07/2017.
//

import Foundation
import UIKit

final class HomeCollectionLayout: UICollectionViewFlowLayout {
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = self.collectionView else {
      return super.layoutAttributesForElements(in: rect)
    }
    
    let insets = collectionView.contentInset
    let offset = collectionView.contentOffset
    let minY = -insets.top
    
    // First get the superclass attributes.
    guard let attributes = super.layoutAttributesForElements(in: rect) else {
      return nil
    }
    
    // Check if we've pulled below past the lowest position
    if offset.y < minY {
      
      // Figure out how much we've pulled down
      let deltaY = fabs(offset.y - minY)
      
      for attrs in attributes {
        // Locate the header attributes
        let kind = attrs.representedElementKind
        
        if kind == UICollectionElementKindSectionHeader {
          // Adjust the header's height and y based on how much the user
          // has pulled down.
          let headerSize = CGSize(width: collectionView.frame.size.width, height: 240)
          var headerRect = attrs.frame
          headerRect.size.height = max(minY, headerSize.height + deltaY)
          headerRect.origin.y = headerRect.origin.y - deltaY
          
          attrs.frame = headerRect
          break
        }
      }
    }
    
    return attributes
  }
}

