//
//  ModellableView.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

/*protocol ModellableView {
  var model: ViewModel { get set }
}*/

public class ModellableView<VM: ViewModel>: UIView {
 public var model: VM = VM() {
    didSet {
      self.update(model: self.model, oldModel: oldValue)
    }
  }
  
  /// do not call this method, set self.model variable instead
  /// TODO: think about changing this name, and how to avoid the developer to call this directly
  public func update(model: VM, oldModel: VM) {}
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public override func layoutSubviews() {
    self.layout(model: self.model)
  }
  
  /// do not call this method, use .setNeedsLayout() instead
  public func layout(model: VM) {}
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
