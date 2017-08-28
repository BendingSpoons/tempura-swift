//
//  UIControl+TargetActionable.swift
//  Tempura
//
//  Created by Andrea De Angelis on 23/08/2017.
//
//

import Foundation

class Trampoline: NSObject {
  @objc func action(sender: UIControl) {}
}

class ActionTrampoline<T>: Trampoline {
  var act: (T) -> ()
  
  init(action: @escaping (T) -> ()) {
    self.act = action
  }
  
  override func action(sender: UIControl) {
    act(sender as! T)
  }
}

extension UIControlEvents {
  var number: NSNumber {
    return NSNumber(integerLiteral: Int(self.rawValue))
  }
}

public protocol TargetActionable {}

fileprivate var actionTrampolinesKey = "targetactionable_action_trampolines_key"

public extension TargetActionable where Self: UIControl {
  
  mutating func on(_ event: UIControlEvents, _ action: @escaping (Self) -> ()) {
    if let oldTrampoline = self.actionTrampolines?[event.number] as? Trampoline {
      self.removeTarget(oldTrampoline, action: #selector(oldTrampoline.action), for: event)
    }
    if self.actionTrampolines == nil {
      self.actionTrampolines = NSMutableDictionary()
    }
    let trampoline = ActionTrampoline(action: action)
    self.addTarget(trampoline, action: #selector(trampoline.action), for: event)
    self.actionTrampolines?[event.number] = trampoline
  }
  
  private var actionTrampolines: NSMutableDictionary? {
    get {
      if let actionTrampolines = objc_getAssociatedObject(self, &actionTrampolinesKey) as? NSMutableDictionary {
        return actionTrampolines
      }
      return nil
    }
    
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(
          self,
          &actionTrampolinesKey,
          newValue as NSMutableDictionary?,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }
  }
  
}

private let tapHandlerKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

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
