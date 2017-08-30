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
  
  func push(identifier: RouteElementIdentifier,
                        animated: Bool,
                        completion: @escaping RoutingCompletion)
  
  func pop(identifier: RouteElementIdentifier,
                       vcToPop: UIViewController,
                       animated: Bool,
                       completion: @escaping RoutingCompletion)
  
  func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          completion: @escaping RoutingCompletion)
  
  /// handle a modal view controller
  /// in order to avoid code repetition you should handle modals at the lowest possible level of the routing tree
  /// modal: the identifier of the view controller to present
  /// animated: specify if the presentation should be animated
  /// completion: this completion handler MUST be called when the presentation is complete
  /// return true if self is handling the presentation of the modal
  func presentModally(modal: RouteElementIdentifier,
                   animated: Bool,
                   completion: @escaping RoutingCompletion) -> Bool
  
  // ATTENTION: you should call completion only if you return true
  func dismissModally(identifier: RouteElementIdentifier,
                      vcToDismiss: UIViewController,
                      animated: Bool,
                      completion: @escaping RoutingCompletion) -> Bool
}

public extension Routable {
  public func push(identifier: RouteElementIdentifier,
                        animated: Bool,
                        completion: @escaping RoutingCompletion) {
    fatalError("This Routable element cannot push other elements, the implementation of \(#function) is missing")
  }
  
  public func pop(identifier: RouteElementIdentifier,
                  vcToPop: UIViewController,
                       animated: Bool,
                       completion: @escaping RoutingCompletion) {
    fatalError("This Routable element cannot pop other elements, the implementation of \(#function) is missing")
  }
  
  public func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          completion: @escaping RoutingCompletion) {
    fatalError("This Routable element cannot change the navigation, the implementation of \(#function) is missing")
  }
  
  public func presentModally(modal: RouteElementIdentifier,
                             animated: Bool,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
  
  public func dismissModally(identifier: RouteElementIdentifier,
                             vcToDismiss: UIViewController,
                             animated: Bool,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
}
