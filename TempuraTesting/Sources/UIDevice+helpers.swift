//
//  UIDevice+helpers.swift
//  TempuraTesting
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import UIKit

extension UIDevice {
  func setOrientation(_ orientation: UIDeviceOrientation) {
    self.setValue(NSNumber(integerLiteral: orientation.rawValue), forKey: "orientation")
  }
}
