//
//  RootInstaller.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation

public protocol RootInstaller {
  func installRoot(identifier: RouteElementIdentifier, completion: Navigator.Completion)
}
