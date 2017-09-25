//
//  ViewControllerModellableView+LayoutGuides.swift
//  Tempura
//
//  Created by Andrea De Angelis on 29/08/2017.
//
//

import Foundation

// MARK: Layout Helpers
public extension ViewControllerModellableView where Self: UIView {
  /**
   The safe area of a view reflects the area not covered by navigation bars, tab bars, toolbars,
   and other ancestors that obscure a view controller's view. (In tvOS, the safe area reflects
   the area not covered by the screen's bezel.) You obtain the safe area for a view by applying the
   insets in this property to the view's bounds rectangle. If the view is not currently installed in a
   view hierarchy, or is not yet visible onscreen, the edge insets in this property are 0.
   
   For the view controller's root view, the insets account for the status bar and other visible bars.
   
   ## Prior iOS 11
   The UIKit `safeAreaInsets`'s property is not available prior iOS 11.
   Tempura creates a similar version of the same property by using values that are available in old
   versions of iOS. This value, though, is less accurate as it doesn't take into account left/right insets.
   This shouldn't be an issue as the only device where this may be useful is the iPhone X, which only runs
   iOS 11 (or newer).
   
   UIKit properties that may influece the safe area (see iOS 11 section) doesn't work on legacy versions
   of the system.
   
   ## iOS 11
   You can specify for your view controller using the `additionalSafeAreaInsets`property.
   For other views in the view hierarchy, the insets reflect only the portion of the view that is covered.
   For example, if a view is entirely within the safe area of its superview,
   the edge insets in this property are 0.
   
   - seeAlso: https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area
   */
  public var tempuraSafeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return self.safeAreaInsets
    } else {
      return self.legacyIOSSafeAreaInsets
    }
  }
  
  // The current height of the status bar
  public var statusBarHeight: CGFloat {
    return UIApplication.shared.statusBarFrame.height
  }
  
  /**
   Implementation of te safe area insets for iOS versions < 11.
   The implementation leverages the view controller's properties.
   
   - warning: When the vc is not available yet, the insets are zero
   */
  private var legacyIOSSafeAreaInsets: UIEdgeInsets {
    guard let vc = self.viewController else {
      return .zero
    }
    
    return UIEdgeInsets(
      top: vc.topLayoutGuide.length,
      left: 0,
      bottom: vc.bottomLayoutGuide.length,
      right: 0
    )
  }
}
