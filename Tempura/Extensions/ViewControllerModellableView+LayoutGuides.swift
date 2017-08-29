//
//  ViewControllerModellableView+LayoutGuides.swift
//  Tempura
//
//  Created by Andrea De Angelis on 29/08/2017.
//
//

import Foundation

public extension ViewControllerModellableView {
  
  public var topInset: CGFloat {
    let isTranslucent = self.navigationBar?.isTranslucent ?? false
    var height: CGFloat = 0.0
    if isTranslucent {
      let statusBarHeight = UIApplication.shared.statusBarFrame.height
      let navBarHeight: CGFloat = self.navigationBar?.bounds.size.height ?? 0.0
      height = statusBarHeight + navBarHeight
    }
    return height
  }
}
