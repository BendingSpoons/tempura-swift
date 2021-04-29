//
//  CGRect+Utils.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import UIKit

extension CGRect {
  var bounds: CGRect {
    return CGRect(origin: .zero, size: self.size)
  }
}
