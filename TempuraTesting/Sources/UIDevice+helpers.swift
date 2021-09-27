//
//  UIDevice+helpers.swift
//  TempuraTesting
//
//  Created by Alexandru Loghin on 27/09/21.
//

import Foundation
import UIKit

extension UIDevice {
  func setOrientation(_ orientation: UIDeviceOrientation) {
    self.setValue(NSNumber(integerLiteral: orientation.rawValue), forKey: "orientation")
  }
}
