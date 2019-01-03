//
//  ViewController+Containment.swift
//  Tempura
//
//  Created by Andrea De Angelis on 25/10/2018.
//


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
  
  /// Remove self as child ViewController of parent
  public func remove() {
    guard let _ = parent else { return }
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
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.subviews.forEach {
      $0.frame = self.bounds
    }
  }
}
