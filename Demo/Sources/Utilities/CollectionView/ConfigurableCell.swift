//
//  ConfigurableCell.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Tempura

// a ReusableCell is a cell defining a `reuseIdentifier` to be used when dequeueing the cell
public protocol ReusableCell {
  static var identifierForReuse: String { get }
}

// a configurableCell is a ReusableCell that can be configured with an object T and the indexPath
// this will be used when it's time to load the cell content
public protocol ConfigurableCell: ReusableCell, ModellableView {}
