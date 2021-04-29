//
//  UIView+Blink.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import UIKit

extension UIView {
  func blink() {
    UIView.animate(
      withDuration: 0.1,
      delay: 0.0,
      options: [.curveEaseIn],
      animations: {
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      },
      completion: { _ in
        UIView.animate(
          withDuration: 0.1,
          delay: 0.0,
          options: [.curveLinear],
          animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
          },
          completion: { _ in
            UIView.animate(
              withDuration: 0.1,
              delay: 0.0,
              options: [.curveEaseOut],
              animations: {
                self.transform = CGAffineTransform.identity
              },
              completion: nil
            )
          }
        )
      }
    )
  }
}
