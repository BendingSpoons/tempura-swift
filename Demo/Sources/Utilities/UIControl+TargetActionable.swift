//
//  UIControl+TargetActionable.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import UIKit

class Trampoline: NSObject {
  @objc func action(sender _: UIControl) {}
}

class ActionTrampoline<T>: Trampoline {
  var act: (T) -> Void

  init(action: @escaping (T) -> Void) {
    self.act = action
  }

  override func action(sender: UIControl) {
    self.act(sender as! T)
  }
}

extension UIControl.Event {
  var number: NSNumber {
    return NSNumber(integerLiteral: Int(self.rawValue))
  }
}

public protocol TargetActionable {}

private var actionTrampolinesKey = "targetactionable_action_trampolines_key"

extension TargetActionable where Self: UIControl {
  public mutating func on(_ event: UIControl.Event, _ action: @escaping (Self) -> Void) {
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

extension TargetActionable where Self: UIBarButtonItem {
  public func onTap(_ action: @escaping (Self) -> Void) {
    let trampoline = ActionTrampoline(action: action)

    self.target = trampoline
    self.action = #selector(trampoline.action)

    // just needed to retain the trampoline to keep it alive
    objc_setAssociatedObject(self, tapHandlerKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
  }
}

extension UIControl: TargetActionable {}
extension UIBarButtonItem: TargetActionable {}
