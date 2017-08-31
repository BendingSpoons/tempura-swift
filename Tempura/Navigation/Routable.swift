//
//  Routable.swift
//  WeightLoss
//
//  Created by Andrea De Angelis on 30/06/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

public typealias RoutingCompletion = () -> ()

public protocol Routable {
  var routeIdentifier: RouteElementIdentifier { get }
  
  func show(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            completion: @escaping RoutingCompletion) -> Bool
  
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            completion: @escaping RoutingCompletion) -> Bool
  
  func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          completion: @escaping RoutingCompletion)
  
  /// handle a modal view controller
  /// in order to avoid code repetition you should handle modals at the lowest possible level of the routing tree
  /// from: the UIViewController to use to present the modal view controller
  /// modal: the identifier of the view controller to present
  /// animated: specify if the presentation should be animated
  /// completion: this completion handler MUST be called when the presentation is complete
  /// return true if self is handling the presentation of the modal
  /*func presentModally(from: UIViewController,
                   modal: RouteElementIdentifier,
                   animated: Bool,
                   completion: @escaping RoutingCompletion) -> Bool
  
  // ATTENTION: you should call completion only if you return true
  func dismissModally(identifier: RouteElementIdentifier,
                      vcToDismiss: UIViewController,
                      animated: Bool,
                      completion: @escaping RoutingCompletion) -> Bool
 */
}

public extension Routable {
  
  public func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          completion: @escaping RoutingCompletion) {
    fatalError("This Routable element cannot change the navigation, the implementation of \(#function) is missing")
  }
  
  public func show(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
  
  public func hide(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
}
