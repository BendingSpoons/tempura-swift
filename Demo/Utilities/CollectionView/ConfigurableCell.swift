//
//  ConfigurableCell.swift
//  TempuraElements
//
//  Created by Andrea De Angelis on 10/01/2018.
//

import Tempura

// a ReusableCell is a cell defining a `reuseIdentifier` to be used when dequeueing the cell
public protocol ReusableCell {
  static var identifierForReuse: String { get }
}

// a configurableCell is a ReusableCell that can be configured with an object T and the indexPath
// this will be used when it's time to load the cell content
public protocol ConfigurableCell: ReusableCell, ModellableView {
  
}

