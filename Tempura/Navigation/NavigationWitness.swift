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
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self.hide(identifierToHide.rawValue, animated, context, atomic)
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
  /// The live NavigationWitness.
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

#if DEBUG
  // MARK: - Mock

  extension NavigationWitness {
    /// The mocked NavigationWitness.
    public static func mocked(
      appendTo navigations: NavigationRequests = [],
      showHandlers: [RouteElementIdentifier: (Bool, Any?) -> Promise<Void>] = [:],
      hideHandlers: [RouteElementIdentifier: (Bool, Any?, Bool) -> Promise<Void>] = [:]
    ) -> Self {
      return .init(
        show: { identifiersToShow, animated, context in
          navigations.append(contentsOf: identifiersToShow.map { .show($0) })
          return all(identifiersToShow.compactMap { showHandlers[$0]?(animated, context) }).void
        },
        hide: { identifierToHide, animated, context, atomic in
          navigations.append(.hide(identifierToHide))
          return hideHandlers[identifierToHide]?(animated, context, atomic) ?? Promise(resolved: ())
        }
      )
    }
  }

  // MARK: - Spy

  /// A navigation witness that expends the live one, adding the functionalities of the mocked one.
  extension NavigationWitness {
    public static func spy(
      dispatch: @escaping AnyDispatch,
      appendTo navigations: NavigationRequests = [],
      showHandlers: [RouteElementIdentifier: (Bool, Any?) -> Promise<Void>] = [:],
      hideHandlers: [RouteElementIdentifier: (Bool, Any?, Bool) -> Promise<Void>] = [:]
    ) -> Self {
      let live: NavigationWitness = .live(dispatch: dispatch)
      let mocked: NavigationWitness = .mocked(appendTo: navigations, showHandlers: showHandlers, hideHandlers: hideHandlers)

      return .unimplemented(
        show: { identifiersToShow, animated, context in
          return live.show(identifiersToShow, animated: animated, context: context)
            .then {
              mocked.show(identifiersToShow, animated: animated, context: context)
            }
        },
        hide: { identifierToHide, animated, context, atomic in
          return live.hide(identifierToHide, animated: animated, context: context, atomic: atomic)
            .then {
              mocked.hide(identifierToHide, animated: animated, context: context, atomic: atomic)
            }
        }
      )
    }
  }

  // MARK: - Unimplemented

  extension NavigationWitness {
    /// The unimplemented NavigationWitness.
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

  // MARK: - NavigationRequests

  /// Wraps any object into a reference-type object
  public class NavigationRequests: Equatable, ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    public internal(set) var requests: [NavigationRequest]

    public init(_ initialValue: [NavigationRequest] = []) {
      self.requests = initialValue
    }

    required public init(arrayLiteral elements: NavigationRequest...) {
      self.requests = elements
    }

    func append(_ request: NavigationRequest) {
      self.requests.append(request)
    }

    func append<S>(contentsOf requests: S) where S: Sequence, S.Element == NavigationRequest {
      self.requests.append(contentsOf: requests)
    }

    public static func == (lhs: NavigationRequests, rhs: NavigationRequests) -> Bool {
      return lhs.requests == rhs.requests
    }

    public var debugDescription: String {
      return self.requests.debugDescription
    }
  }
#endif
