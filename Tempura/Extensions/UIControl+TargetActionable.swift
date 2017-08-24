//
//  UIControl+TargetActionable.swift
//  Tempura
//
//  Created by Andrea De Angelis on 23/08/2017.
//
//

import Foundation

class ActionTrampoline<T>: NSObject {
  var act: (T) -> ()
  
  init(action: @escaping (T) -> ()) {
    self.act = action
  }
  
  @objc func action(sender: UIControl) {
    act(sender as! T)
  }
}

public protocol TargetActionable {}

public extension TargetActionable where Self: UIControl {
  func on(_ event: UIControlEvents, _ action: @escaping (Self) -> ()) {
    let trampoline = ActionTrampoline(action: action)
    self.addTarget(trampoline, action: #selector(trampoline.action), for: event)
    // just needed to retain the trampoline to keep it alive
    objc_setAssociatedObject(self, "\(event)", trampoline, .OBJC_ASSOCIATION_RETAIN)
  }
}

let tapHandlerKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

public extension TargetActionable where Self: UIBarButtonItem {
  func onTap(_ action: @escaping (Self) -> ()) {
    let trampoline = ActionTrampoline(action: action)
    
    self.target = trampoline
    self.action = #selector(trampoline.action)
    
    // just needed to retain the trampoline to keep it alive
    objc_setAssociatedObject(self, tapHandlerKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
  }
}

extension UIControl: TargetActionable {}
extension UIBarButtonItem: TargetActionable {}
