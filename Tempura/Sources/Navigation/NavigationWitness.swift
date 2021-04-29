//
//  NavigationWitness.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Hydra
import Katana

// MARK: - Protocol Witness

/// Tempura navigation protocol witness.
public struct NavigationWitness {
  /// @see Tempura.Show
  public func show(
    _ identifiersToShow: [RouteElementIdentifier],
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void> {
    return self._show(identifiersToShow, animated, context)
  }

  /// @see Tempura.Show
  public func show(
    _ identifierToShow: RouteElementIdentifier,
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void> {
    return self._show([identifierToShow], animated, context)
  }

  /// @see Tempura.Show
  public func show<I>(
    _ identifiersToShow: [I],
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self._show(identifiersToShow.map { $0.rawValue }, animated, context)
  }

  /// @see Tempura.Show
  public func show<I>(
    _ identifiersToShow: I,
    animated: Bool = false,
    context: Any? = nil
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self._show([identifiersToShow.rawValue], animated, context)
  }

  /// @see Tempura.Hide
  public func hide(
    _ identifierToHide: RouteElementIdentifier,
    animated: Bool = false,
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void> {
    return self._hide(identifierToHide, animated, context, atomic)
  }

  /// @see Tempura.Hide
  public func hide<I>(
    _ identifierToHide: I,
    animated: Bool = false,
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void>
    where I: RawRepresentable, I.RawValue == RouteElementIdentifier {
    return self._hide(identifierToHide.rawValue, animated, context, atomic)
  }

  /// @see Tempura.Hide
  public func hide(
    animated: Bool = false,
    context: Any? = nil,
    atomic: Bool = false
  ) -> Promise<Void> {
    return self._hide(nil, animated, context, atomic)
  }

  // MARK: Internal closures

  // swiftlint:disable identifier_name
  var _show: ([RouteElementIdentifier], Bool, Any?) -> Promise<Void>
  var _hide: (RouteElementIdentifier?, Bool, Any?, Bool) -> Promise<Void>
  // swiftlint:enable identifier_name
}

// MARK: - Live

extension NavigationWitness {
  /// The live NavigationWitness.
  public static func live(dispatch: @escaping AnyDispatch) -> Self {
    return .init(
      _show: { identifiersToShow, animated, context in
        dispatch(Show(identifiersToShow, animated: animated, context: context)).void
      },
      _hide: { identifierToHide, animated, context, atomic in
        if let identifierToHide = identifierToHide {
          return dispatch(Hide(identifierToHide, animated: animated, context: context, atomic: atomic)).void
        } else {
          return dispatch(Hide(animated: animated, context: context, atomic: atomic)).void
        }
      }
    )
  }
}

// MARK: - Mock

#if DEBUG
  extension NavigationWitness {
    /// The mocked NavigationWitness.
    public static func mocked(
      appendTo navigations: NavigationRequests = [],
      showHandlers: [RouteElementIdentifier: (Bool, Any?) -> Promise<Void>] = [:],
      hideHandlers: [RouteElementIdentifier: (Bool, Any?, Bool) -> Promise<Void>] = [:]
    ) -> Self {
      return .init(
        _show: { identifiersToShow, animated, context in
          navigations.append(contentsOf: identifiersToShow.map { .show($0) })
          return all(identifiersToShow.compactMap { showHandlers[$0]?(animated, context) }).void
        },
        _hide: { identifierToHide, animated, context, atomic in
          let identifier = identifierToHide ?? "nil"
          navigations.append(.hide(identifier))
          return hideHandlers[identifier]?(animated, context, atomic) ?? Promise(resolved: ())
        }
      )
    }
  }

  /// Wraps an array of NavigationRequest into a reference-type object
  public class NavigationRequests: Equatable, ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    public internal(set) var requests: [NavigationRequest]

    public init(_ initialValue: [NavigationRequest] = []) {
      self.requests = initialValue
    }

    public required init(arrayLiteral elements: NavigationRequest...) {
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

// MARK: - Unimplemented

#if DEBUG
  extension NavigationWitness {
    /// The unimplemented NavigationWitness.
    public static func unimplemented(
      show: @escaping ([RouteElementIdentifier], Bool, Any?) -> Promise<Void> = { _, _, _ in fatalError() },
      hide: @escaping (RouteElementIdentifier?, Bool, Any?, Bool) -> Promise<Void> = { _, _, _, _ in fatalError() }
    ) -> Self {
      return .init(
        _show: show,
        _hide: hide
      )
    }
  }
#endif
