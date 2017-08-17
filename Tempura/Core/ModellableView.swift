//
//  ModellableView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

// typealias for interaction callback
public typealias Interaction = () -> ()

public protocol ModellableView: class {
 associatedtype VM: ViewModel
  
  var model: VM { get set }
  
  var viewController: UIViewController? { get set }
  
  func setup()
  func style()
  func update(oldModel: VM)
  func layout()
  
 /*open var model: VM = VM() {
    didSet {
      self.update(model: self.model, oldModel: oldValue)
    }
  }
  
  open override func layoutSubviews() {
    self.layout(model: self.model)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }*/
}

public extension ModellableView {
  /// shortcut to the navigationBar, if present
  public var navigationBar: UINavigationBar? {
    return viewController?.navigationController?.navigationBar
  }
  
  /// shortcut to the navigationItem, if present
  public var navigationItem: UINavigationItem? {
    return viewController?.navigationItem
  }
}
