# Changelog

## 9.0.3

- TempuraTesting: Fix device orientation for Xcode 13.0 also for ViewTestCase and UIViewControllerTestCase. [#130](https://github.com/BendingSpoons/tempura-swift/pull/130)

## 9.0.2

- TempuraTesting: Fix orientation for Xcode 13.0. [#129](https://github.com/BendingSpoons/tempura-swift/pull/129)

## 9.0.0
- Add support for `Swift Package Manager`. [#127](https://github.com/BendingSpoons/tempura-swift/pull/127)
- Align `Tempura` and `TempuraTesting` versions. [#127](https://github.com/BendingSpoons/tempura-swift/pull/127)

## Tempura 7.1.0

- Allow to init Navigation with custom `RoutableProvider`. [#125](https://github.com/BendingSpoons/tempura-swift/pull/125)

## Tempura 7.0.1

- Fix possible initialization of the ViewModel with an older state.

## TempuraTesting 8.0.1

- Support for Tempura 7. [#122](https://github.com/BendingSpoons/tempura-swift/pull/122)

## TempuraTesting 8.0.0

- [BREAKING] Remove deprecated global `test` functions. The `ViewTestCase` API should be used instead. [#114](https://github.com/BendingSpoons/tempura-swift/pull/114)
- [BREAKING] Remove `UITestCase` typealias. `ViewTestCase` should be used instead. No other changes should be necessary. [#114](https://github.com/BendingSpoons/tempura-swift/pull/114)
- [BREAKING] Use correct screen size on orientation change. This is a breaking change that makes screenSize of Context and VCContext optional. [#110](https://github.com/BendingSpoons/tempura-swift/pull/110)
- Make TempuraTesting build on Xcode 12.5 [#111](https://github.com/BendingSpoons/tempura-swift/pull/111)
- Migrate from Xcake to Tuist. [#117](https://github.com/BendingSpoons/tempura-swift/pull/117)
- Replace `UIGraphicsBeginImageContextWithOptions` with `UIGraphicsImageRenderer`. [#108](https://github.com/BendingSpoons/tempura-swift/pull/108)

## Tempura 7.0.0

- [BREAKING] Bump to Katana 6. [#112](https://github.com/BendingSpoons/tempura-swift/pull/112)
- [BREAKING] Add Hydra (`>= 2.0.6`) as an explicit dependency. [#113](https://github.com/BendingSpoons/tempura-swift/pull/113)
- [BREAKING] Remove deprecated `dispatch` and `unsafeDispatch` for `NavigationSideEffect` on `AnyStore` and `AnySideEffectContext`. Katana's normal dispatch accepting `Dispatchable`s should be used instead. [#114](https://github.com/BendingSpoons/tempura-swift/pull/114)
- [BREAKING] Remove `UIView.universalSafeAreaInsets` in favor of `UIView.safeAreaInsets`. [#118](https://github.com/BendingSpoons/tempura-swift/pull/118)
- [BREAKING] Remove deprecated `__unsafeDispatch` and `__unsafeAwaitDispatch` for `NavigationSideEffect` on `ViewController`. The base methods accepting `Dispatchable`s should be used instead. [#114](https://github.com/BendingSpoons/tempura-swift/pull/114)
- Migrate from Xcake to Tuist. [#117](https://github.com/BendingSpoons/tempura-swift/pull/117)

## Tempura 6.2.0

- Add validation of UITests keys uniqueness [#103](https://github.com/BendingSpoons/tempura-swift/pull/103)
- Fix possible exception when a state update is triggered while a view controller is being dismissed [#104](https://github.com/BendingSpoons/tempura-swift/pull/104)

## Tempura 6.1.0

- Add NavigationWitness [#99](https://github.com/BendingSpoons/tempura-swift/pull/99)

## TempuraTesting 7.0.0

- Update to Tempura 6
- [BREAKING] bumped minDeploymentTarget from `9.0` to `11.0`

## Tempura 6.0.0

- Update to Katana 5
- [BREAKING] bumped minDeploymentTarget from `9.0` to `11.0`
- Add CustomDebugStringConvertible extension to navigation actions
- Reverse `.popToViewController` NavigationInstruction to find the last `Routable` instead of the first (in case the same `routeIdentifier` is present in the stack)

## Tempura 5.1.0

- Deprecated all dispatch helpers to `AnyStore` and `AnySideEffectContext` for `NavigationSideEffect`s
- Deprecated `__unsafeAwaitDispatch` from `ViewController` for `NavigationSideEffect`s
- Added `__unsafeDispatch` for non-returning sideeffects in `ViewController`

## TempuraTesting 6.0.0

- Update to Katana 4

## Tempura 5.0.0

- Update to Katana 4
- Make the ViewController `dispatch` method returns Void
- Add to the ViewController `__unsafe_dispatch` method that returns a promise
- Expose a non-generic dispatch for ViewController

## TempuraTesting 5.0.2

- Fix issue with `screenSize` not set on the View being tested.

## TempuraTesting 5.0.1

- Fix issue with `configure(:::)` being called too early for `ViewControllerTestCase`s with a `ViewControllerWithLocalState`.

## Tempura 4.4.0

- Add `optionalCustom` to `NavigationInstruction`. With `optionalCustom` you can specify to handle a navigation instruction only if some conditions are matched.

## TempuraTesting 5.0.0

- `ViewControllerTestCase` will now wait for view to be ready after configure
- `ViewControllerTestCase` will now let you test `UIViewController`s with a `ModellableView` other than `ViewController`s.
- Introduce `UIViewControllerTestCase` to test `UIViewController`s with `UIView`s.

## 4.3.1

- Make `CustomRouteInspectables` and `RouteInspectable` public

## 4.3.0

- Add support for rendering Safe Area Insets in UITests

## 4.2.0

- Add transition method to the Containment API

## 4.1.3

- Remove defaults from `UITestCase`

## 4.1.2

- Make closure in `installRoot` escaping

## 4.1.1

- Added `popToRootViewController` and `popToViewController` to Navigation Instructions
- Fixed broken UITest filename for a scrollable content's snapshot

## 4.0.1

- Fixed unresolving promise if calling `hide` on a view that is not in the `currentRoutables`
- `ViewControllerWithLocalState.init(store:connected:)` is now private

## 4.0.0

- Add support for Swift 5.0
- Remove `init()` requirement for `LocalState` protocol
- Force `ViewControllerWithLocalState` to specify a `LocalState` in the `init(...)`
- `RootInstaller`'s `installRoot(identifier:context:completion)` now returns a `Bool` value
- If there are no Routables handing a `Show()` with a specific identifier, the `Navigator` will ask the `RootInstaller` before raising a fatalError().

## 3.0.1

- Fix UITests by using the `collatorIdentifier` instead of the `languageCode`

## 3.0.0

- Use Katana 3.0
- Add support for UITests with ViewController containment

## 2.1.0

- Add support for ViewController containment

## 2.0.0

- Add support for Swift 4.2

## 1.12.0

- Added completion callbacks for `UINavigationController` methods like `pushViewController`, `popViewController`,  `popToRootViewController`,  `popToViewController`

## 1.11.0

- Added ability to create UI tests for scrollViews content
- Fixed issue with UI tests of ViewControllers inside other controllers

## 1.10.0

- Add support for orientation change in `UITestCase`

## 1.9.0

- UI tests folder structure uses the locale of the app to support multiple language UITests
- Introduces new `UITestCase` API that are easier to use and unify various approaches that used to coexist until now
- Deprecates UITest APIs

## 1.8.2

- UI tests folders are consistent when landscape screenshots are involved. A screenshot from an iPhone X in portrait will be in the same directory of a screenshot of an iPhone X in landscape

## 1.8.1

- fixed LocalURLProtocol implementation to support DownloadTask and similar approaches

## 1.8.0

- Implementation of the universalSafeAreaInsets for every UIView and not only for ViewControllerModellableView.
 In case of a UIView down in the hierarchy, the universalSafeAreaInsets will be the intersection between the main safeArea and the actual frame of the view.

## 1.7.2

- UITests snapshots are now saved under resolution subdir

## 1.3.0

- Added failable init for ViewModelWithState and ViewModelWithLocalState
- Added Navigation Helpers
- Removed unused Live Reload feature

## 1.2.2

- Improve code for connect

## 1.2.1

- Fix issues with ViewControllerWithLocalState

## 1.2.0

- Introduce 'shouldConnectWhenVisible' and 'shouldDisconnectWhenInvisible' properties for ViewController

## 1.1.2

- Prevent the View from loading before it's actually needed

## 1.1.1

- Fix bug in tempuraDismiss

## 1.0.0

- Simplified generics for `ViewController`, now it is only generic for the `ModellableView`
- Deprecated `action` label in `dispatch()` method
- Removed forced unwrapping inside `Navigator`
- Fixed `willSet` method invocation
- Added tests
- Improved the connect inner workings for `ViewController` and `ViewControllerWithLocalState`
- Fixed disconnected ViewControllersWithLocalState that were connecting on localState change
- Fixed ViewController unsubscribing triggering updates
- Improved type safety on ViewController Store and View
- viewModel is now optional in ModellableView and ViewController
- willUpdate and didUpdate methods are now returning new and old viewModels as parameters
- Implemented Style Standardisation. See [this pr](https://github.com/BendingSpoons/tempura-swift/pull/14) for more information

## 0.5.0

- Update to swift 4.0
- Adds `tempuraSafeAreaInsets` and `statusBarHeight` as view's properties. See [this pr](https://github.com/BendingSpoons/tempura-swift/pull/7) for more information
- Fix Main Thread issue with Hide navigation action
