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

* Implemented Style Standardisation. See [this pr](https://github.com/BendingSpoons/tempura-lib-swift/pull/14) for more information

  ​

## 0.5.0

* Update to swift 4.0
* Adds `tempuraSafeAreaInsets` and `statusBarHeight` as view's properties. See [this pr](https://github.com/BendingSpoons/tempura-lib-swift/pull/7) for more information
* Fix Main Thread issue with Hide navigation action
