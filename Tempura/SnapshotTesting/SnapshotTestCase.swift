//
//  SnapshotTestCase.swift
//  Tempura
//
//  Created by Mauro Bolis on 02/09/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import FBSnapshotTestCase

/// Type Erasure for `ViewSnapshot`
public protocol AnyViewSnapshot {
  
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
public struct ViewSnapshot<V: ViewControllerModellableView>: AnyViewSnapshot {
  let viewType: V.Type
  let models: [String: V.VM]
  let container: Container
  let size: CGSize
  let hooks: [Hook: HookClosure<V>]
  
  /// A dictionary of configured view controllers for the various snapshot's cases
  public var configuredViewControllers: [String : UIViewController] {
    return self.models.mapValues { model in
      let renderer = Renderer(self.viewType, model: model, container: self.container, size: self.size, hooks: self.hooks)
      return renderer.getViewController()
    }
  }
  
  /// The name of the view
  public var viewName: String {
    return "\(self.viewType)"
  }
  
  init(
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

/**
 Subclass of `FBSnapshotTestCase` (provided by FB's library) that takes care of
 managing the snapshots defined using instances of `ViewSnapshot`.
 
 To use this class it is just enough to subclass it and override the `viewSnapshots`
 parameter
*/
open class SnapshotTestCase: FBSnapshotTestCase {
  
  /// The snapshosts to generate
  open var viewSnapshots: [AnyViewSnapshot] {
    return []
  }
  
  override open func setUp() {
    super.setUp()
    self.recordMode = true
    self.isDeviceAgnostic = true
  }
  
  func testScreens() {
    for configuration in self.viewSnapshots {
      let viewName = configuration.viewName
      let vcS = configuration.configuredViewControllers
      
      for (configurationName, vc) in vcS {
        let identifier = "\(viewName)_\(configurationName)"
        FBSnapshotVerifyView(vc.view, identifier: identifier)
      }
    }
  }
}
