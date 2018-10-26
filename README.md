<p align="center">
  <img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/tempura_header.png" alt="Tempura by Bending Spoons" width="400" />
</p>

[![Build Status](https://travis-ci.org/BendingSpoons/tempura-swift.svg?branch=master)](https://travis-ci.org/BendingSpoons/tempura-swift)
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

### ViewController containment

You can have ViewControllers inside other ViewControllers, this is useful if you want to reuse portions of UI including the logic. To do that, in the parent ViewController you need to provide a `ContainerView` that will receive the view of the child ViewController as subview.

```swift
class ParentView: UIView, ViewControllerModellableView {
    var childView = ContainerView()
}
```

Then, in the parent ViewController you just need to add the child ViewController:

```swift
class ParentViewController: ViewController<ParentView> {
  let childVC: ChildViewController<ChildView>!
    
  override func setup() {
    childVC = ChildViewController(store: self.store)
    self.add(childVC, in: self.rootView.childView)  
  }
}
```

All of the automation will work out of the box.
You will now have a `ChildViewController` inside the `ParentViewController`, the ChildViewController's view will be hosted inside the `childView`.



### UI Testing

Tempura has a UI testing system that can be used to take screenshots of your views in all possible states, with all devices and all supported languages.

#### Usage

You need to include the `TempuraTesting` pod in the test target of your app:

```ruby
target 'MyAppTests' do
  pod 'TempuraTesting'
end
```

Specify where the screenshots will be placed inside your `plist` :

```plist
UI_TEST_DIR: $(SOURCE_ROOT)/Demo/UITests
```

In Xcode, create a new UI test case class:

`File -> New -> File... -> UI Test Case Class ` 

Here you can use the `test` function to take a snapshot of a `ViewControllerModellableView`  with a specific `ViewModel`.

```swift
import TempuraTesting

class UITests: XCTestCase, UITestCase {
  
  func testAddItemScreen() {
    self.uiTest(testCases: [
      "addItem01": AddItemViewModel(editingText: "this is a test")
    ])
  }
}

```
The identifier will define the name of the snapshot image in the file system.

You can also personalise how the view is rendered (for instance you can embed the view in an instance of UITabBar) using the context parameter. Here is an example that
embeds the view into a tabbar
```swift
import TempuraTesting

class UITests: XCTestCase, UITestCase {
  
  func testAddItemScreen() {
    var context = UITests.Context<AddItemView>()
    context.container = .tabBarController


    self.uiTest(testCases: [
      "addItem01": AddItemViewModel(editingText: "this is a test")
    ], context: context)
  }
}

```
If some important content inside a UIScrollView is not fully visibile, you can leverage the `scrollViewsToTest(in view: V, identifier: String)` method.
This will produce an additional snapshot rendering the full content of each returned UIScrollView instance.

In this example we use `scrollViewsToTest(in view: V, identifier: String)`  to take an extended snapshot of the *mood picker* at the bottom of the screen.
```swift
func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView] {
  return ["mood_collection_view": view.moodCollectionView]
}
```
<img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/screen1.png" height="400" />
<img src="https://raw.githubusercontent.com/BendingSpoons/tempura-swift/master/.github/Assets/screen2.png" />


In case you have to wait for asynchronous operations before rendering the UI and take the screenshot, you can leverage the `isViewReady(view:identifier:)` method.
For instance, here we wait until an hypotetical view that shows an image from a remote URL is ready. When the image is shown (that is, the state is `loaded`, then the snapshot is taken)
```swift
import TempuraTesting

class UITests: XCTestCase, UITestCase {
  
  func testAddItemScreen() {
    self.uiTest(testCases: [
      "addItem01": AddItemViewModel(editingText: "this is a test")
    ])
  }

  func isViewReady(_ view: AddItemView, identifier: String) -> Bool {
    return view.remoteImage.state == .loaded
  }
}
```

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

If you want to test a specific language in the ui test, you can replace the `test` command with the `-testLanguage <iso code639-1>`.
The app will be launched in that language and the UITests will be executed with that locale. An example:

```bash
xcodebuild \
  -workspace <project>.xcworkspace \
  -scheme "<target name>" \
  -destination name="iPhone 5s" \
  -destination name="iPhone 6 Plus" \
  -destination name="iPhone 6" \
  -destination name="iPhone X" \
  -destination name="iPad Pro (12.9 inch)" \
  -testLanguage it
```


#### Remote Resources

It happens often that the UI needs to show remote content (that is, remote images, remote videos, ...). While executing UITests this could be a problem as:
* tests may fail due to network or server issues
* system should take care of tracking when remote resources are loaded, put them in the UI and only then take the screenshots

To fix this issue, Tempura offers a [URLProtocol](https://developer.apple.com/documentation/foundation/urlprotocol) subclass named `LocalFileURLProtocol` that tries to load remote files from your local bundle.

The idea is to put in your (test) bundle all the resources that are needed to render the UI and `LocalFileURLProtocol` will try to load them instead of making the network request. 

Given an url, `LocalFileURLProtocol` matches the file name using the following rules:
* search a file that has the url as a name (e.g., http://example.com/image.png)
* search a file that has the last path component as file name (e.g., image.png)
* search a file that has the last path component without extension as file name (e.g., image)

if a matching file cannot be retrieved, then the network call is performed.

In order to register `LocalFileURLProtocol` in your application, you have to invoke the following API as soon as possible in your tests lifecycle:
```swift
URLProtocol.registerClass(LocalFileURLProtocol.self)
```

Note that if you are using [Alamofire](https://github.com/Alamofire/Alamofire/) this won't work. [Here](https://github.com/Alamofire/Alamofire/issues/1247) you can find a related issue and a link on how to configure Alamofire to deal with `URLProtocol` classes.


## Where to go from here

### Example application

This repository contains a demo of a todo list application done with Tempura. After a `pod install`, open the project and run the `Demo` target.

### Check out the documentation

[Documentation](http://tempura.bendingspoons.com)

## Swift Version
Certain versions of Tempura only support certain versions of Swift. Depending on wich version of Swift your project is using, you should use specific versions of Tempura.
Use this table in order to check which version of Tempura you need.

| Swift Version  | Tempura Version |
| ------------- | ------------- |
| Swift 4.2 | Tempura 2.0  |
| Swift 4 | Tempura 1.12 |

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
