//
//  UITests.swift
//  Tempura
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import Foundation

/// this uiTest global function can be used inside a XCTest environment
/// this will create a snapshot of the ViewController `vc` taken in input
/// the snapshot will be saved under the UI_TEST_DIR specified in your info.plist

public func uiTest<VC: ViewController<V>, V>(vc: VC) {
  let frame = UIScreen.main.bounds
  vc.rootView.frame = frame
  
  let snapshot = vc.rootView.snapshot()
  guard let image = snapshot else { return }
  let fileManager: FileManager = FileManager()
  guard let dirPath = Bundle.main.infoDictionary?["UI_TEST_DIR"] as? String else { fatalError("UI_TEST_DIR not defined in your info.plist") }
  let dirURL = URL(fileURLWithPath: dirPath)
  guard let pngData = UIImagePNGRepresentation(image) else { return }
  let scaleFactor = Int(UIScreen.main.scale)
  let fileURL = dirURL.appendingPathComponent("\(String(describing: VC.self))@\(scaleFactor)x.png")
  guard let _ = try? fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil) else { return }
  guard let didWrite = try? pngData.write(to: fileURL) else { return }
}

public extension UIView {
  func snapshot() -> UIImage? {
    self.layoutIfNeeded()
    self.layer.layoutIfNeeded()
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.saveGState()
    self.layer.layoutIfNeeded()
    self.layer.render(in: context)
    context.restoreGState()
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
