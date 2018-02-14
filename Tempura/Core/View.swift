//
//  View.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/08/2017.
//
//

import Foundation

/// the View protocol defines the structure of a View level code in Tempura
/// ideally all the reusable simple Views of the app should conform to View
/// for more complex Views please refer to `ModellableView` protocol

public protocol View: class {
  /// create, configure and add (using `addSubview()`) the children of the view
  func setup()
  /// configure all the style related properties of the view and its children
  func style()
  /// update the view and its children based on the relevant properties of the view
  func update()
  /// layout the children of the view using the layouting method that you want (frame based, autolayout, etc.)
  func layoutSubviews()
}
