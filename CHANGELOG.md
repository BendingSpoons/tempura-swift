## unreleased
* Added `localStateDidChange` hook to `ViewControllerWithLocalState`

## 2.1.0
* Add support for ViewController containment

## 2.0.0
* Add support for Swift 4.2

## 1.12.0

- Added completion callbacks for `UINavigationController` methods like `pushViewController`, `popViewController`,  `popToRootViewController`,  `popToViewController`

## 1.11.0

- Added ability to create UI tests for scrollViews content
- Fixed issue with UI tests of ViewControllers inside other controllers

## 1.10.0

* Add support for orientation change in `UITestCase`

## 1.9.0

* UI tests folder structure uses the locale of the app to support multiple language UITests
* Introduces new `UITestCase` API that are easier to use and unify various approaches that used to coexist until now
* Deprecates UITest APIs

## 1.8.2

* UI tests folders are consistent when landscape screenshots are involved. A screenshot from an iPhone X in portrait will be in the same directory of a screenshot of an iPhone X in landscape

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

* Simplified generics for `ViewController`, now it is only generic for the `ModellableView`

* Deprecated `action` label in `dispatch()` method

* Removed forced unwrapping inside `Navigator`

* Fixed `willSet` method invocation

* Added tests

* Improved the connect inner workings for `ViewController` and `ViewControllerWithLocalState`

* Fixed disconnected ViewControllersWithLocalState that were connecting on localState change

* Fixed ViewController unsubscribing triggering updates

* Improved type safety on ViewController Store and View

* viewModel is now optional in ModellableView and ViewController

* willUpdate and didUpdate methods are now returning new and old viewModels as parameters

* Implemented Style Standardisation. See [this pr](https://github.com/BendingSpoons/tempura-swift/pull/14) for more information

  ​

## 0.5.0

* Update to swift 4.0
* Adds `tempuraSafeAreaInsets` and `statusBarHeight` as view's properties. See [this pr](https://github.com/BendingSpoons/tempura-swift/pull/7) for more information
* Fix Main Thread issue with Hide navigation action
