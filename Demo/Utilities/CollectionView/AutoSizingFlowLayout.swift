//
//  AutoSizingFlowLayout.swift
//  Demo
//
//  Created by Andrea De Angelis on 15/02/2018.
//

import UIKit

final class AutoSizingExampleLayout: UICollectionViewFlowLayout {

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
}
