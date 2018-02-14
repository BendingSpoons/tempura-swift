//
//  Routable.swift
//  WeightLoss
//
//  Created by Andrea De Angelis on 30/06/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import UIKit

public typealias RouteElementIdentifier = String
public typealias Route = [RouteElementIdentifier]

public typealias RoutingCompletion = () -> ()

public protocol Routable: class {
  var routeIdentifier: RouteElementIdentifier { get }
  
  func show(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool
  
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool
  
  func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          context: Any?,
                          completion: @escaping RoutingCompletion)
}

public extension Routable {
  
  public func change(from: RouteElementIdentifier,
                          to: RouteElementIdentifier,
                          animated: Bool,
                          context: Any?,
                          completion: @escaping RoutingCompletion) {
    fatalError("This Routable element cannot change the navigation from \"\(from)\" to \"\(to)\", the implementation of \(#function) is missing")
  }
  
  public func show(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             context: Any?,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
  
  public func hide(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             context: Any?,
                             completion: @escaping RoutingCompletion) -> Bool {
    return false
  }
}
