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
  uiTest(view: vc.rootView)
}

public func uiTest<V: ModellableView & UIView, VM>(view: V, viewModel: VM) where V.VM == VM {
  view.model = viewModel
  uiTest(view: view)
}

public func uiTest<V: ModellableView & UIView, VM>(view: V.Type, viewModel: VM) where V.VM == VM {
  let v = view.init()
  v.model = viewModel
  uiTest(view: v)
}

public func uiTest(view: UIView, description: String? = nil) {
  let description = description ?? String(describing: type(of: view))
  let frame = UIScreen.main.bounds
  view.frame = frame
  
  let snapshot = view.snapshot()
  guard let image = snapshot else { return }
  let fileManager: FileManager = FileManager()
  guard let dirPath = Bundle.main.infoDictionary?["UI_TEST_DIR"] as? String else { fatalError("UI_TEST_DIR not defined in your info.plist") }
  let dirURL = URL(fileURLWithPath: dirPath)
  guard let pngData = UIImagePNGRepresentation(image) else { return }
  let scaleFactor = Int(UIScreen.main.scale)
  let fileURL = dirURL.appendingPathComponent("\(description)@\(scaleFactor)x.png")
  guard let _ = try? fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil) else { return }
  guard let didWrite = try? pngData.write(to: fileURL) else { return }
}

public extension UIView {
  func snapshot() -> UIImage? {
    let window: UIWindow?
    var removeFromSuperview: Bool = false
    
    if let w = self as? UIWindow {
      window = w
    } else if let w = self.window {
      window = w
    } else {
      window = UIApplication.shared.keyWindow
      window?.addSubview(self)
      removeFromSuperview = true
    }
    
    self.layoutIfNeeded()
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if removeFromSuperview {
      self.removeFromSuperview()
    }
    
    return snapshot
  }
}
