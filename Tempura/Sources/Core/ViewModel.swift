//
//  ViewModel.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 03/07/2017.
//  Copyright © 2017 Bending Spoons. All rights reserved.
//

import Foundation

/// A lightweight object that represents the set of properties
/// needed by a `ModellableView` to render itself.
/// ```swift
///    struct ContactViewModel: ViewModel {
///      var name: String = "John"
///      var lastName: String = "Doe"
///    }
/// ```
public protocol ViewModel {}
