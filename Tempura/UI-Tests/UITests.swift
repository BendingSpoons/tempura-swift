//
//  UITests.swift
//  Tempura
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import Foundation
import XCTest

// A Renderer will take a type of View, a ViewModel, a Container and will configure the viewController that will handle that View
/// use `getViewController()` in order to get the configured ViewController
class Renderer<V: ViewControllerModellableView> {
  private var modellableViewType: V.Type
  private var model: V.VM
  private var container: Container
  private var size: CGSize
  private var hooks: [Hook: HookClosure<V>]
  
  init(_ type: V.Type, model: V.VM, container: Container, size: CGSize, hooks: [Hook: HookClosure<V>]) {
    self.modellableViewType = type
    self.model = model
    self.container = container
    self.size = size
    self.hooks = hooks
  }
  
  func getViewController() -> UIViewController {
    
    let containerViewController: UIViewController
    
    let containerVC = ContainerViewController<V>()
    containerVC.hooks = hooks
    containerVC.rootView.model = self.model
    
    switch self.container {
    case .none:
      containerViewController = containerVC
      
    case .navigationController:
      let navVC = UINavigationController(rootViewController: containerVC)
      containerViewController = navVC
      
      if let hook = hooks[.navigationControllerHasBeenCreated] {
        hook(containerVC.rootView)
      }
      
    case .tabBarController:
      let tabVC = UITabBarController()
      tabVC.viewControllers = [containerVC]
      containerViewController = tabVC
    }
  
    
    containerViewController.view.frame.size = self.size
    return containerViewController
  }
}

/// A UIViewController that allows hooks to be registered
class ContainerViewController<V: ViewControllerModellableView>: UIViewController {
  var hooks: [Hook: HookClosure<V>]?
  
  override func loadView() {
    self.view = (V.self as! UIView.Type).init()
    
    (self.view as! V).viewController = self
    
    self.rootView.setup()
    self.rootView.style()
  }
  
  var rootView: V {
    return self.view as! V
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.automaticallyAdjustsScrollViewInsets = false
    self.edgesForExtendedLayout = []
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard let hooks = self.hooks else {
      return
    }
    
    if let hook = hooks[.viewDidLayoutSubviews] {
      hook(self.rootView)
    }
  }
}

/// The container in which the view can be embedded
public enum Container {
  /// No container
  case none
  /// UINavigationController
  case navigationController
  /// UITabBarController
  case tabBarController
}

/// Closure invoked when a hook is triggered
public typealias HookClosure<View: ViewControllerModellableView> = (View) -> Void

/// A UIViewController's lifecycle hook
public enum Hook: Int {
  /**
   The navigation controller has been created and can be customized.
   This hook is triggered only when the container is `navigationController`
   */
  case navigationControllerHasBeenCreated
  
  /// View has just laid out the subviews
  case viewDidLayoutSubviews
}

/// Type Erasure for `ScreenSnapshot`
public protocol AnyScreenSnapshot {
  
  /// The name of the view
  var viewName: String { get }
  
  /// A dictionary of configured view controllers for the various snapshot's cases
  var configuredViewControllers: [String: UIViewController] { get }
}

/**
 A snapshot is a view-homogenous set of snapshosts.
 
 The idea is that you can provide different configurations for the same view.
 Each configuration is basically a view model.
 Since the view should be 100% configured from the view model, it should be possible to
 create every situation the view could be presented.
 
 ## Container
 It is also possible to specify a container in which the view is embedded. A container can be
 a tabbar, a navigation controller or just nothing. Since these additional UIs should be configured from the
 view, these additional UI elements will be styled and properly rendered as well.
 
 # Hooks
 Sometimes it is required to execute some arbitrary code during the view lifecycle.
 Hooks can be used to customize the behaviour of the mocked view controller that renders the view.
 */
public struct ScreenSnapshot<V: ViewControllerModellableView>: AnyScreenSnapshot {
  let viewType: V.Type
  let models: [String: V.VM]
  let container: Container
  let size: CGSize
  let hooks: [Hook: HookClosure<V>]
  
  /// A dictionary of configured view controllers for the various snapshot's cases
  public var configuredViewControllers: [String: UIViewController] {
    return self.models.mapValues { model in
      let renderer = Renderer(self.viewType, model: model, container: self.container, size: self.size, hooks: self.hooks)
      return renderer.getViewController()
    }
  }
  
  /// The name of the view
  public var viewName: String {
    return "\(self.viewType)"
  }
  
  public init(
    type: V.Type,
    container: Container,
    models: [String: V.VM],
    hooks: [Hook: HookClosure<V>] = [:],
    size: CGSize = UIScreen.main.bounds.size) {
    
    self.viewType = type
    self.container = container
    self.models = models
    self.size = size
    self.hooks = hooks
  }
}

open class TempuraUITest: XCTestCase {
  
  /// The snapshosts to generate
  open var screenSnapshots: [AnyScreenSnapshot] {
    return []
  }
  
  open override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  open override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testScreen() {
    
    for snapshotConfiguration in self.screenSnapshots {
      let viewName = snapshotConfiguration.viewName
      let vcs = snapshotConfiguration.configuredViewControllers
      
      for (configurationName, vc) in vcs {
        let identifier = "\(viewName)_\(configurationName)"
        verifyView(view: vc.view, description: identifier)
      }
    }
  }
}

/// this uiTest global function can be used inside a XCTest environment
/// this will create a snapshot of the ViewController `vc` taken in input
/// the snapshot will be saved under the UI_TEST_DIR specified in your info.plist

private func verifyView(view: UIView, description: String) {
  uiTest(view: view, description: description)
  XCTAssertTrue(true)
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
  guard let _ = try? pngData.write(to: fileURL) else { return }
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
