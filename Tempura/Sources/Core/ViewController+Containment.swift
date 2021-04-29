//
//  ViewController+Containment.swift
//  Tempura
//
//  Created by Andrea De Angelis on 25/10/2018.
//

import UIKit

/// ViewController containment
extension ViewController {
  /// Add a ViewController (and its rootView) as a child of self
  /// You must provide a ContainerView inside self.rootView, that container view
  /// will automatically receive the rootView of the child ViewController as child
  public func add<View: ViewControllerModellableView>(_ child: ViewController<View>, in view: ContainerView) {
    self.addChild(child)
    view.addSubview(child.rootView)
    child.didMove(toParent: self)
  }

  /// Replace a ViewController (and its rootView) to the last child of self.
  /// You must provide a ContainerView inside self.rootView, the latest view of that container view
  /// is replaced with the rootView of the child ViewController with a cross-dissolve transition
  public func transition<View: ViewControllerModellableView>(
    to child: ViewController<View>,
    in view: ContainerView,
    duration: Double = 0.3,
    options: UIView.AnimationOptions = [.transitionCrossDissolve],
    completion: (() -> ())? = nil
  ) {
    guard
      let lastView = view.subviews.last,
      let lastViewVC = (lastView as? AnyViewControllerModellableView)?.viewController
    else {
      return
    }

    let animated = duration > 0
    lastViewVC.willMove(toParent: nil)
    lastViewVC.viewWillDisappear(animated)
    UIView.transition(
      from: lastView,
      to: child.rootView,
      duration: duration,
      options: options,
      completion: { _ in
        self.addChild(child)
        child.didMove(toParent: self)

        lastViewVC.removeFromParent()
        lastViewVC.viewDidDisappear(animated)
        completion?()
      }
    )
  }

  /// Remove self as child ViewController of parent
  public func remove() {
    guard let _ = self.parent else { return }
    self.willMove(toParent: nil)
    self.removeFromParent()
    self.rootView.removeFromSuperview()
    self.viewWillDisappear(false)
    self.viewDidDisappear(false)
  }
}

/// A View used to do ViewController containment
/// This is the View that will contain the View of the managed ViewController
public class ContainerView: UIView {
  
  /// See `UIView.layoutSubviews()`
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.subviews.forEach {
      $0.frame = self.bounds
    }
  }
}
