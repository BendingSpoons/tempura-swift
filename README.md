<p align="center">
  <img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/tempura_header.png" alt="Tempura by Bending Spoons" width="400" />
</p>

# 

Tempura is a pragmatic approach to app development, it borrows concepts from [Redux](https://redux.js.org/) (through [Katana](https://github.com/BendingSpoons/katana-swift)) and [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel).

1. Model your app state
2. Define the actions that can change it
3. Create the UI
4. Enjoy automatic sync between state and UI
5. Ship, iterate

## Why should I use this?

We started using Tempura in a small team inside [Bending Spoons](http://bndspn.com/2HOnxis). It worked so well for us that we ended up developing and maintaining more than twenty high quality apps with more than 10 millions of active users in the last year using this approach. Crash rates and development time went down, user engagement and quality went up. We were so satisfied that we wanted to share this with the iOS community, hoping that you would be as excited as us. ❤️ 

<p align="center">
  <a href="https://itunes.apple.com/app/id1099771240"><img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/icon1.png" alt="Thirty Day Fitness" width="200" /></a>
  <a href="https://itunes.apple.com/it/app/id509987785"><img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/icon2.png" alt="Pic Jointer" width="200" /></a>
  <a href="https://itunes.apple.com/it/app/id1310491340"><img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/icon3.png" alt="Rized" width="200" /></a>
  <a href="https://itunes.apple.com/app/id1214593569"><img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/icon4.png" alt="ReadIt" width="200" /></a>
</p>

## Show me the code

Tempura is using [Katana](https://github.com/BendingSpoons/katana-swift)) to handle the logic of your app.
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

You can only manipulate state through [actions](https://github.com/BendingSpoons/katana-swift).

```swift
struct CompleteItem: AppAction {
  var index: Int

  func updatedState(currentState: inout AppState) {
    currentState.items[index].completed = true
  }
}
```

The part of the state needed to render the UI of a screen is selected by a [ViewModelWithState](./docs/Protocols/ViewModelWithState.html).

```swift
struct ListViewModel: ViewModelWithState {
  var todos: [Todo]

  init(state: AppState) {
    self.todos = state.todos
  }
}
```

The UI of each screen of your app is composed in a [ViewControllerModellableView](./docs/Protocols/ViewControllerModellableView.html). It exposes callbacks (we call them interactions) to signal that a user action occurred. It renders itself based on the ViewModelWithState.

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

Each screen of your app is managed by a [ViewController](./docs/Classes/ViewController.html). Out of the box it will automatically listen for state updates and keep the UI in sync. The only other responsibility of a ViewController is to listen for interactions from the UI and dispatch actions to change the state.

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

Real apps are made by more than one screen. If a screen needs to present another screen, its ViewController must conform to the [RoutableWithConfiguration](./docs/Protocols/RoutableWithConfiguration.html) protocol.

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

Learn more about the navigation [here](./docs/Classes/Navigator.html)



## Where to go from here

### Example application

This repository contains a demo of a todo list application done with Tempura. After a `pod install`, open the project and run the `Demo` target.

### Check out the documentation

[Documentation](./docs/index.html)



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

We'd love to hear from you **any questions** or **feedback** at [opensource@bendingspoons.com](mailto:opensource@bendingspoons.com).

## Contribute

- If you've **found a bug**, open an issue;
- If you have a **feature request**, open an issue;
- If you **want to contribute**, submit a pull request;
- If you **have an idea** on how to improve the framework or how to spread the word, please [get in touch](https://github.com/BendingSpoons/tempura-swift#get-in-touch);
- If you want to **try the framework** for your project or to write a demo, please send us the link of the repo.

## License

Tempura is available under the [MIT license](https://github.com/BendingSpoons/tempura-swift/blob/master/LICENSE).



## About

Tempura is maintained by Bending Spoons.
We create our own tech products, used and loved by millions all around the world.
Interested? [Check us out](http://bndspn.com/2ELtTxf)
