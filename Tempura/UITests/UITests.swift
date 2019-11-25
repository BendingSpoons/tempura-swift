//
//  UITests.swift
//  Tempura
//
//  Created by Andrea De Angelis on 09/02/2018.
//

import Foundation
import Katana
import Tempura
import XCTest

public enum UITests {
  
  /**
   A snapshot is a struct that contains all the informations to create a view-homogenous set of snapshots.
   
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
  
  
  public struct VCScreenSnapshot<VC: AnyViewController> {
    let vc: () -> VC
    let container: Container
    let testCases: [String]
    let hooks: [Hook: HookClosure<VC.V>]
    let size: CGSize
    
    init(vc: @autoclosure @escaping () -> VC, container: Container, testCases: [String], hooks: [Hook: HookClosure<VC.V>], size: CGSize) {
      self.vc = vc
      self.container = container
      self.testCases = testCases
      self.hooks = hooks
      self.size = size
    }
    
    public var renderingViewControllers: [String: (container: UIViewController, contained: VC)] {
      return self.testCases.reduce(into: [String: (container: UIViewController, contained: VC)]()) { dict, identifier in
        let containedVC = vc()
        let containerVC = container.container(for: containedVC as! UIViewController)
        dict[identifier] = (container: containerVC, contained: containedVC)
      }
    }
    
  }
  
  public struct ScreenSnapshot<V: ViewControllerModellableView> {
    let viewType: V.Type
    let models: [String: V.VM]
    let container: Container
    let size: CGSize
    let hooks: [Hook: HookClosure<V>]
    
    /// A dictionary of configured view controllers for the various snapshot's cases
    public var renderingViewControllers: [String: (container: UIViewController, contained: UIViewController)] {
      return self.models.mapValues { model in
        let renderer = Renderer(self.viewType, model: model, container: self.container, size: self.size, hooks: self.hooks)
        return renderer.getRenderingViewControllers()
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
  
  
  /// A Renderer will take a type of View, a ViewModel, a Container and will create the rendering UIViewController
  /// that will be used to render the View.
  /// Use `getRenderingViewControllers()` in order to get the configured view controllers
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
    
    func getRenderingViewControllers() -> (UIViewController, UIViewController) {
      
      let containerVC: UIViewController
      
      let containedVC = HookableViewController<V>()
      containedVC.hooks = hooks
      containedVC.rootView.model = self.model
      
      switch self.container {
      case .none:
        containerVC = containedVC
        
      case .navigationController:
        let navVC = UINavigationController(rootViewController: containedVC)
        containerVC = navVC
        
        if let hook = hooks[.navigationControllerHasBeenCreated] {
          hook(containedVC.rootView)
        }
        
      case .tabBarController:
        let tabVC = UITabBarController()
        tabVC.viewControllers = [containedVC]
        containerVC = tabVC
        
      case .custom(let customController):
        containerVC = customController(containedVC)
      }
      
      containerVC.view.frame.size = self.size
      return (containerVC, containedVC)
    }
  }
  
  /// A UIViewController that allows hooks to be registered
  class HookableViewController<V: ViewControllerModellableView>: UIViewController {
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
      
      if let hook = self.hooks?[.viewDidLoad] {
        hook(self.rootView)
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if let hook = self.hooks?[.viewWillAppear] {
        hook(self.rootView)
      }
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      if let hook = self.hooks?[.viewDidAppear] {
        hook(self.rootView)
      }
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
      if let hook = self.hooks?[.viewDidLayoutSubviews] {
        hook(self.rootView)
      }
    }
  }
  
  /// Hooks can be used to customize the behaviour of the mocked view controller that renders the view.
  public enum Hook: Int {
    /**
     The navigation controller has been created and can be customized.
     This hook is triggered only when the container is `navigationController`
     */
    case navigationControllerHasBeenCreated
    
    /// UIViewController's lifecycle hooks
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewDidLayoutSubviews
  }
  
  /// Closure invoked when a hook is triggered
  public typealias HookClosure<V: ViewControllerModellableView> = (V) -> Void
  
  /// The container UIViewController subclass in which the view can be embedded
  public enum Container {
    /// No container
    case none
    /// UINavigationController
    case navigationController
    /// UITabBarController
    case tabBarController
    /// provide a custom UIViewController as a container
    case custom((UIViewController) -> (UIViewController))
    
    func container(for vc: UIViewController) -> UIViewController {
      switch self {
        case .none:
          return vc
        case .navigationController:
          return UINavigationController(rootViewController: vc)
        case .tabBarController:
          let tc = UITabBarController()
          tc.viewControllers = [vc]
          return tc
        case .custom (let customController):
          return customController(vc)
      }
    }
  }
  
  /// Create a snapshot image of the view and pass the test
  /// The snapshot will be saved under the UI_TEST_DIR specified in your info.plist
  static func verifyView(view: UIView, description: String) {
    snapshot(view: view, description: description)
    XCTAssertTrue(true)
  }
  
  /// Create a snapshot image of the view.
  /// The snapshot will be saved under the UI_TEST_DIR specified in your info.plist
  private static func snapshot(view: UIView, description: String? = nil) {
    let description = description ?? String(describing: type(of: view))
    let frame = UIScreen.main.bounds
    view.frame = frame
    
    let snapshot = view.snapshot()
    guard let image = snapshot else { return }
    self.saveImage(image, description: description)
  }
  
  static func asyncSnapshot(view: UIView, viewToWaitFor: UIView? = nil, description: String, isViewReadyClosure: @escaping (UIView) -> Bool, completionClosure: @escaping () -> Void) {
    let frame = UIScreen.main.bounds
    view.frame = frame
    
    view.snapshotAsync(viewToWaitFor: viewToWaitFor, isViewReadyClosure: isViewReadyClosure) { snapshot in
      defer {
        completionClosure()
      }
      
      guard let image = snapshot else {
        return
      }
      
      self.saveImage(image, description: description)
    }
  }
  
  static func snapshotScrollableContent(_ scrollView: UIScrollView, description: String) {
    // Resize the frame to render all the content
    let fullWidth = scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right
    let fullHeight = scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom
    let fullSize = CGSize(width: max(scrollView.frame.width, fullWidth),
                          height: max(scrollView.frame.height, fullHeight))
    scrollView.frame = CGRect(origin: scrollView.frame.origin, size: fullSize)
    
    scrollView.setNeedsLayout()
    scrollView.layoutIfNeeded()
    
    guard let snapshot = scrollView.snapshot() else { return }
    self.saveImage(snapshot, description: description)
  }
  
  private static func saveImage(_ image: UIImage, description: String) {
    guard var dirPath = Bundle.main.infoDictionary?["UI_TEST_DIR"] as? String else { fatalError("UI_TEST_DIR not defined in your info.plist") }
    
    if let collatorIdentifier = Locale.current.collatorIdentifier {
      dirPath = dirPath.appending("/\(collatorIdentifier)/")
    }
    let screenSize = UIScreen.main.bounds.size
    let screenSizeDescription: String = "\(min(screenSize.width, screenSize.height))x\(max(screenSize.width, screenSize.height))"
    
    dirPath = dirPath.appending("/\(screenSizeDescription)/")
    
    let fileManager = FileManager.default
    
    var dirURL = URL(fileURLWithPath: dirPath)
    let recording: Bool = (Bundle.main.infoDictionary?["UI_TEST_RECORDING"] as? Bool) == true
    
    if recording {
      dirURL.appendPathComponent("/reference")
    }
    
    guard let pngData = image.pngData() else { return }
    let scaleFactor = Int(UIScreen.main.scale)
    let fileURL = dirURL.appendingPathComponent("\(description)@\(scaleFactor)x.png")
    guard let _ = try? fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil) else { return }
    guard let _ = try? pngData.write(to: fileURL) else { return }
  }
}

/// Test a ViewControllerModellableView embedded in a Container with a specific ViewModel.
/// The test will produce a screenshot of the view.
/// The screenshots will be located in the directory specified inside the plist with the `UI_TEST_DIR` key.
/// After the screenshot is completed, the test will pass.
/// This function can only be used in a XCTest environment.
@available(*, deprecated, message: "Use UITestCase API instead")
public func test<V: ViewControllerModellableView & UIView>(_ viewType: V.Type,
                                                           with model: V.VM,
                                                           identifier: String,
                                                           container: UITests.Container = .none,
                                                           hooks: [UITests.Hook: UITests.HookClosure<V>] = [:],
                                                           size: CGSize = UIScreen.main.bounds.size) {
  test(viewType, with: [identifier: model], container: container, hooks: hooks, size: size)
}

/// Test a ViewControllerModellableView embedded in a Container with a specific set of ViewModels.
/// The test will produce a set of screenshots of the view, one for each ViewModel specified.
/// The screenshots will be located in the directory specified inside the plist with the `UI_TEST_DIR` key.
/// After the screenshot is completed, the test will pass.
/// This function can only be used in a XCTest environment.
@available(*, deprecated, message: "Use UITestCase API instead")
public func test<V: ViewControllerModellableView & UIView>(_ viewType: V.Type,
                                                           with models: [String: V.VM],
                                                           container: UITests.Container = .none,
                                                           hooks: [UITests.Hook: UITests.HookClosure<V>] = [:],
                                                           size: CGSize = UIScreen.main.bounds.size) {
  let snapshotConfiguration = UITests.ScreenSnapshot<V>(type: viewType, container: container, models: models, hooks: hooks, size: size)
  let viewControllers = snapshotConfiguration.renderingViewControllers
  let screenSizeDescription: String = "\(UIScreen.main.bounds.size.description)"
  for (identifier, vcs) in viewControllers {
    let description = "\(identifier) \(screenSizeDescription)"
    UITests.verifyView(view: vcs.container.view, description: description)
  }
}

extension CGSize {
  public var description: String {
    return "\(Int(self.width))x\(Int(self.height))"
  }
}
