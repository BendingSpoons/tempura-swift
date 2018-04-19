<p align="center">
  <img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/tempura_header.png" alt="Tempura by Bending Spoons" width="400" />
</p>

[![Build Status](https://travis-ci.org/BendingSpoons/tempura-swift.svg?branch=master)](https://travis-ci.org/BendingSpoons/katana-swift)
[![CocoaPods](https://img.shields.io/cocoapods/v/Tempura.svg)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=shields)](http://makeapullrequest.com)
[![Licence](https://img.shields.io/badge/Licence-MIT-lightgrey.svg)](https://github.com/BendingSpoons/tempura-swift/blob/master/LICENSE.md)

# 

Tempura is a holistic approach to iOS development, it borrows concepts from [Redux](https://redux.js.org/) (through [Katana](https://github.com/BendingSpoons/katana-swift)) and [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel).

1. Model your app state
2. Define the actions that can change it
3. Create the UI
4. Enjoy automatic sync between state and UI
5. Ship, iterate

## Why should I use this?

We started using Tempura in a small team inside [Bending Spoons](http://bndspn.com/2HOnxis). It worked so well for us, that we ended up developing and maintaining more than twenty high quality apps, with more than 10 million active users in the last year using this approach. Crash rates and development time went down, user engagement and quality went up. We are so satisfied that we wanted to share this with the iOS community, hoping that you will be as excited as we are. ❤️ 

<p align="center">
  <a href="https://itunes.apple.com/app/id1099771240"><img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/icon1.png" alt="Thirty Day Fitness" width="200" /></a>
  <a href="https://itunes.apple.com/it/app/id509987785"><img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/icon2.png" alt="Pic Jointer" width="200" /></a>
  <a href="https://itunes.apple.com/it/app/id1310491340"><img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/icon3.png" alt="Rized" width="200" /></a>
  <a href="https://itunes.apple.com/app/id1214593569"><img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/icon4.png" alt="ReadIt" width="200" /></a>
</p>

## Show me the code

Tempura uses [Katana](https://github.com/BendingSpoons/katana-swift) to handle the logic of your app.
Your app state is defined in a single struct.

```swift
struct AppState: State {

  var items: [Todo] = [
    Todo(text: "Pet my unicorn"),
    Todo(text: "Become a doctor.\nChange last name to Acula"),
    Todo(text: "Hire two private investigators.\nGet them to follow each other"),
    Todo(text: "Visit mars")
  ]
}
```

You can only manipulate state through [actions](https://github.com/BendingSpoons/katana-swift/blob/master/docs/1.0.0/Protocols/Action.html).

```swift
struct CompleteItem: AppAction {
  var index: Int

  func updatedState(currentState: inout AppState) {
    currentState.items[index].completed = true
  }
}
```

The part of the state needed to render the UI of a screen is selected by a [ViewModelWithState](http://tempura.bendingspoons.com/Protocols/ViewModelWithState.html).

```swift
struct ListViewModel: ViewModelWithState {
  var todos: [Todo]

  init(state: AppState) {
    self.todos = state.todos
  }
}
```

The UI of each screen of your app is composed in a [ViewControllerModellableView](http://tempura.bendingspoons.com/Protocols/ViewControllerModellableView.html). It exposes callbacks (we call them interactions) to signal that a user action occurred. It renders itself based on the ViewModelWithState.

```swift
class ListView: UIView, ViewControllerModellableView {
  // subviews
  var todoButton: UIButton = UIButton(type: .custom)
  var todoButton: UIButton = UIButton(type: .custom)
  var list: CollectionView<TodoCell, SimpleSource<TodoCellViewModel>>

  // interactions
  var didTapAddItem: ((String) -> ())?
  var didCompleteItem: ((String) -> ())?

  // update based on ViewModel
  func update(oldModel: ListViewModel?) {
    guard let model = self.model else { return }
    let todos = model.todos
    self.list.source = SimpleSource<TodoCellViewModel>(todos)
  }
}
```

Each screen of your app is managed by a [ViewController](http://tempura.bendingspoons.com/Classes/ViewController.html). Out of the box it will automatically listen for state updates and keep the UI in sync. The only other responsibility of a ViewController is to listen for interactions from the UI and dispatch actions to change the state.

```swift
class ListViewController: ViewController<ListView> {
  // listen for interactions from the view
  override func setupInteraction() {
    self.rootView.didCompleteItem = { [unowned self] index in
      self.dispatch(CompleteItem(index: index))
    }
  }
}
```

### Navigation

Real apps are made by more than one screen. If a screen needs to present another screen, its ViewController must conform to the [RoutableWithConfiguration](http://tempura.bendingspoons.com/Protocols/RoutableWithConfiguration.html) protocol.

```swift
extension ListViewController: RoutableWithConfiguration {
  var routeIdentifier: RouteElementIdentifier { return "list screen"}

  var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
    return [
      .show("add item screen"): .presentModally({ [unowned self] _ in
        let aivc = AddItemViewController(store: self.store)
        return aivc
      })
    ]
  }
}
```

You can then trigger the presentation using one of the navigation actions from the ViewController.

```swift
self.dispatch(Show("add item screen"))
```

Learn more about the navigation [here](http://tempura.bendingspoons.com/Classes/Navigator.html)

### UI Testing

Tempura has a UI testing system that can be used to take screenshots of your views in all possible states, with all devices and all supported languages.

#### Usage

You need to specify where the screenshots will be placed inside your `plist` :

```plist
UI_TEST_DIR: $(SOURCE_ROOT)/Demo/UITests
```

In Xcode, create a new UI test case class:

`File -> New -> File... -> UI Test Case Class ` 

Here you can use the `test` function to take a snapshot of a `ViewControllerModellableView`  with a specific `ViewModel`.

```swift
class UITests: XCTestCase {
  
  func testAddItemScreen() {
    test(AddItemView.self,
         with: AddItemViewModel(editingText: "this is a test"),
         container: .none,
         identifier: "addItem01")
  } 
}

```

You can also embed the View inside a specific container (UINavigationController or UITabBarController).
The identifier will define the name of the snapshot image in the file system.

The test will pass as soon as the snapshot is taken.

#### Multiple devices

By default, tests are run only in the device you have choose from xcode (or your device, or CI system). We can run the snapshotting in all the devices by using a script like the following one:

```bash
xcodebuild \
  -workspace <project>.xcworkspace \
  -scheme "<target name>" \
  -destination name="iPhone 5s" \
  -destination name="iPhone 6 Plus" \
  -destination name="iPhone 6" \
  -destination name="iPhone X" \
  -destination name="iPad Pro (12.9 inch)" \
  test
```

Tests will run in parallel on all the devices. If you want to change the behaviour, refer to the `xcodebuild` documentation



## Where to go from here

### Example application

This repository contains a demo of a todo list application done with Tempura. After a `pod install`, open the project and run the `Demo` target.

### Check out the documentation

[Documentation](http://tempura.bendingspoons.com)



## Installation

Tempura is available through [CocoaPods](https://cocoapods.org).

### Requirements

- iOS 9+
- Xcode 9.0+
- Swift 4.0+

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```shell
$ sudo gem install cocoapods
```

To integrate Tempura in your Xcode project using CocoaPods you need to create a `Podfile` with this content:

```ruby
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'MyApp' do
  pod 'Tempura'
end
```

Now you just need to run:

```shell
$ pod install
```

## Get in touch

If you have any **questions** or **feedback** we'd love to hear from you at [opensource@bendingspoons.com](mailto:opensource@bendingspoons.com)

## Contribute

- If you've **found a bug**, open an issue;
- If you have a **feature request**, open an issue;
- If you **want to contribute**, submit a pull request;
- If you **have an idea** on how to improve the framework or how to spread the word, please [get in touch](https://github.com/BendingSpoons/tempura-swift#get-in-touch);
- If you want to **try the framework** for your project or to write a demo, please send us the link of the repo.

## License

Tempura is available under the [MIT license](https://github.com/BendingSpoons/tempura-swift/blob/master/LICENSE).



## About

Tempura is maintained by [Bending Spoons](http://bndspn.com/2HOnxis).
We create our own tech products, used and loved by millions all around the world.
Sounds cool? [Check us out](http://bndspn.com/2ELtTxf)
