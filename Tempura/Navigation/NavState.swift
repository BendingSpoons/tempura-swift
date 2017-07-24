//
//  NavState.swift
//  WeightLoss
//
//  Created by Andrea De Angelis on 30/06/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

public typealias RouteElementIdentifier = String
public typealias Route = [RouteElementIdentifier]

public struct NavState {
  
  public var requestingRoute: Route = []
  
  var changeRouteAnimated: Bool = true
  
}

public protocol StateWithNav: State {
  var navigationState: NavState { get set }
}
