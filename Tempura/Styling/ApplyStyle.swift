//
//  ApplyStyle.swift
//  Tempura
//
//  Created by Mauro Bolis on 18/10/2017.
//

import Foundation

/// Closure that is used to apply a style to a view (or view-like class)
public typealias StyleClosure<V> = (V) -> Void

/**
 Globally available function that is used to apply the style to a view.
 The suggested way to invoke the function is the following:
 ```
 Tempura.applyStyle(function, to: self.view)
 ```
 
 - parameter closure: the closure that contains the styling logic of the view
 - parameter view: the view
*/
public func applyStyle<V>(_ closure: StyleClosure<V>, to view: V) -> Void {
  closure(view)
}
