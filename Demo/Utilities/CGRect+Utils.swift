//
//  CGRect+Utils.swift
//  Demo
//
//  Created by Andrea De Angelis on 16/02/2018.
//

import UIKit

extension CGRect {
  var bounds: CGRect {
    return CGRect(origin: .zero, size: self.size)
  }
}
