//
//  NavigationWitness.swift
//  Tempura
//
//  Created by Daniele Formichelli on 18/11/20.
//  Copyright © 2020 Bending Spoons. All rights reserved.
//

import Hydra
import Katana

// MARK: - Protocol Witness

/// Tempura navigation protocol witness.
public struct NavigationWitness {
  private let show: ([RouteElementIdentifier], Bool, Any?) -> Promise<Void>
  private let hide: (RouteElementIdentifier, Bool, Any?, Bool) -> Promise<Void>

  /// @see Tempura.Show
  public func show(
    _ identifiersToShow: [RouteElementIdentifier],
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void> {
    return self.show(identifiersToShow, animated, context)
  }

  /// @see Tempura.Show
  public func show(
    _ identifiersToShow: RouteElementIdentifier,
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void> {
    return self.show([identifiersToShow], animated, context)
  }

  /// @see Tempura.Show
  public func show<I>(
    _ identifiersToShow: [I],
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self.show(identifiersToShow.map { $0.rawValue }, animated, context)
  }

  /// @see Tempura.Show
  public func show<I>(
    _ identifiersToShow: I,
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self.show([identifiersToShow.rawValue], animated, context)
  }

  /// @see Tempura.Hide
  public func hide(
    _ identifierToHide: RouteElementIdentifier,
    animated: Bool = false,
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void> {
    return self.hide(identifierToHide, animated, context, atomic)
  }

  /// @see Tempura.Hide
  public func hide<I>(
    _ identifierToHide: I,
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self.hide(identifierToHide.rawValue, animated, context, false)
  }

  /// @see Tempura.Hide
  public func hide(
    animated: Bool = false,
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void> {
    guard let identifierToHide = UIApplication.shared.currentRoutableIdentifiers.last else {
      fatalError("No routable identifiers found")
    }
    return self.hide(identifierToHide, animated, context, atomic)
  }
}

// MARK: - Live

extension NavigationWitness {
  /// The live NavigationWitness
  public static func live(dispatch: @escaping AnyDispatch) -> Self {
    return .init(
      show: { identifiersToShow, animated, context in
        dispatch(Show(identifiersToShow, animated: animated, context: context)).void
      },
      hide: { identifierToHide, animated, context, atomic in
        dispatch(Hide(identifierToHide, animated: animated, context: context, atomic: atomic)).void
      }
    )
  }
}

// MARK: - Mock

extension NavigationWitness {
  /// The mock NavigationWitness
  public static func mock(
    appendTo navigations: Wrapped<[NavigationRequest]> = .init(initialValue: []),
    showHandlers: [RouteElementIdentifier: (Bool, Any?) -> Void] = [:],
    hideHandlers: [RouteElementIdentifier: (Bool, Any?, Bool) -> Void] = [:]
  ) -> Self {
    return .init(
      show: { identifiersToShow, animated, context in
        navigations.value.append(contentsOf: identifiersToShow.map { .show($0) })
        
        identifiersToShow.forEach { showHandlers[$0]?(animated, context) }
        
        return Promise(resolved: ())
      },
      hide: { identifierToHide, animated, context, atomic in
        navigations.value.append(.hide(identifierToHide))
        
        hideHandlers[identifierToHide]?(animated, context, atomic)
                
        return Promise(resolved: ())
      }
    )
  }
}

// MARK: - Unimplemented

extension NavigationWitness {
  /// The unimplemented NavigationWitness
  public static func unimplemented(
    show: @escaping ([RouteElementIdentifier], Bool, Any?) -> Promise<Void> = { _, _, _ in fatalError() },
    hide: @escaping (RouteElementIdentifier, Bool, Any?, Bool) -> Promise<Void> = { _, _, _, _ in fatalError() }
  ) -> Self {
    return .init(
      show: show,
      hide: hide
    )
  }
}

// MARK: - Wrapped

/// Wraps any object into a reference-type object
public class Wrapped<T> {
  public var value: T

  public init(initialValue: T) {
    self.value = initialValue
  }
}
