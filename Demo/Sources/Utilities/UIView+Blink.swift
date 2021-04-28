//
//  UIView+Blink.swift
//  Demo
//
//  Created by Andrea De Angelis on 16/02/2018.
//

import UIKit

extension UIView {
  func blink() {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
      self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    }) { completed in
      UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveLinear], animations: {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }, completion: { completed in
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
          self.transform = CGAffineTransform.identity
        }, completion: nil)
      })
    }
  }
}
