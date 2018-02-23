<p align="center">
  <img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/tempura_header.png" alt="Tempura by Bending Spoons"/>
</p>

# 

Tempura is the framework we use at [Bending Spoons](www.bendingspoons.com) to power all our apps, used by millions of users.
It is a pragmatic Redux + MVVM approach at architecting applications.



## Show me the code

Your app state is defined in a [single struct](https://github.com/BendingSpoons/katana-swift).

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

Tempura is available through [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### Requirements

- iOS 9+
- Xcode 8.0+
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

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa projects. You can install Carthage downloading and running the `Carthage.pkg` file from [here](https://github.com/Carthage/Carthage/releases) or you can install it using [Homebrew](http://brew.sh/) simply by running:

```
$ brew update
$ brew install carthage
```

To integrate Tempura into your Xcode project using Carthage, add it to your `Cartfile`:

```Shell
github "Bendingspoons/tempura-swift"
```

And Run:

```shell
$ carthage update
```

Then drag the build `Tempura.framework` into your Xcode project.

## Get in touch

We'd love to hear from you **any questions** or **feedback** at [opensource@bendingspoons.com](mailto:opensource@bendingspoons.com).

## Contribute

- If you've **found a bug**, open an issue;
- If you have a **feature request**, open an issue;
- If you **want to contribute**, submit a pull request;
- If you **have an idea** on how to improve the framework or how to spread the word, please [get in touch](https://github.com/BendingSpoons/katana-swift#get-in-touch);
- If you want to **try the framework** for your project or to write a demo, please send us the link of the repo.

## License

Tempura is available under the [MIT license](https://github.com/BendingSpoons/tempura-swift/blob/master/LICENSE).



## About

Tempura is maintained by Bending Spoons.
We create our own tech products, used and loved by millions all around the world.
Interested? [Check us out]()
