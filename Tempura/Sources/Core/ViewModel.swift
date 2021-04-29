//
//  ViewModel.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

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
