//
//  LiveReload.swift
//  Tempura
//
//  Created by Mauro Bolis on 18/08/2017.
//
//

import Foundation
import UIKit

/**
 Manager for live reload.
 
 This manager should be used as a singleton.
 In the AppDelegate, you should call `LiveReloadManager.shared.liveReloadViews(in: window)`.
 
 The method just listen for a notification and it doens't do anything else. That being said,
 it is suggested to use a environment conditional check (that is, run this only in debug builds).
*/
public final class LiveReloadManager {
  public static let shared: LiveReloadManager = LiveReloadManager()
  private static let injectedNotification = Notification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION")
  
  private let notificationCenter: NotificationCenter
  
  private init() {
    self.notificationCenter = NotificationCenter.default
  }
  
  /// Starts the live reload listening for all the subviews of the provided window
  public func liveReloadViews(in window: UIWindow) {
    self.notificationCenter.addObserver(
      forName: LiveReloadManager.injectedNotification,
      object: nil,
      queue: .main) { [unowned self] notification in
     
        guard
          let anyTypes = notification.object as? [Any],
          let rootView = window.rootViewController?.view
          
        else {
          return
        }
        
        let reloadTypes = anyTypes.flatMap { $0 as? LiveReloadableView.Type }
        
        if reloadTypes.isEmpty {
          return
        }
        
        self.reload(view: rootView, ifTypeIn: reloadTypes)
    }
  }
  
  
  func reload(view: UIView, ifTypeIn types: [LiveReloadableView.Type]) {
    let t = type(of: view)

    if
      types.contains(where: { $0 == t }),
      let reloadView = view as? LiveReloadableView {
      
      reloadView.viewDidLiveReload()
    }
    
    for subview in view.subviews {
      self.reload(view: subview, ifTypeIn: types)
    }
  }
}

/**
 Protocol that views that wants to leverage the live reload should implement.
 The idea is that every time the view's code changes, the system invokes `viewDidLiveReload`.
 
 - note: for `ModellableView`, the method is already implemented. See `ModellableView` documentation
 for more information.
 
 ### Current known limitations:
 - uiview class cannot be final
 - you cannot add new lazy variables to your view
*/
public protocol LiveReloadableView {
  func viewDidLiveReload()
}
