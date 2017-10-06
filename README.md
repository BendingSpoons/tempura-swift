<p align="center">
  <img src="https://github.com/BendingSpoons/tempura-lib-swift/blob/master/Assets/tempura_header.png" alt="Tempura by Bending Spoons"/>
</p>


Tempura is a UI (and Navigation) framework for Katana.
With Tempura you can use Katana to handle the logic part of your app while still using the native iOS navigation and UI elements, being able to leverage system features like peek and pop and automatic transitions between screens.

|      | Tempura                                  |
| ---- | ---------------------------------------- |
| 📱   | Use native UIKit elements                |
| 🚢   | Use iOS native navigation                |
| ✨    | Automatically update the UI based on state changes |
| 📐   | Layout agnostic, use your favorite layouting system |
| 🦄   | Detach from the state to handle complex scenarios |
| 🎩   | Supports Peek&Pop, 3D touch shortcuts    |
| 🐎   | Native Animations, including ViewControllers transitions |



# Anatomy of a Screen
In Tempura, a Screen is composed by three different elements that interoperate to get the actual pixels on screen and to keep them updated when the state changes.
These are: `ViewController`,`ViewModel` and `View`.

![AnatomyOfAScreen](./readme.png)


## ViewController

A ViewController manages the set of views that are shown in each screen of your UI.

Responsibilities of a ViewController are:

- listen for Katana state changes and propagate them to the view
- listen for user interactions and dispatch new Katana Actions

Tempura will handle the former for you, you will only need to address the latter



## ViewModel

The ViewModel is a lightweight object that selects part of the State for the View and transforms it to be easily consumed by the View itself.

This has some advantages:

- a ViewModel is easier to test than the UI
- the View becomes just a dumb presentation layer



## View

A view is a piece of UI that is visible on screen. It contains no business logic,  (it can contain UI logic, like handling a CollectionView delegate), it only presents itself based on the content of the viewModel. The lifecycle of a view contains:

- setup phase, when you create the children UI elements like buttons or labels
- style phase, when you define the cosmetics of the view and its children
- layout phase, when you layout the children of the view
- update phase, when you update the view and its children based on the properties of the view itself

To clearly separate these different phases we created the protocol **View**:

```swift
public protocol View: class {
  /// create, configure and add (using `addSubview()`) the children of the view
  func setup()
  /// configure all the style related properties of the view and its children
  func style()
  /// update the view and its children based on the relevant properties of the view
  func update()
  /// layout the children of the view using the layouting method that you want (frame based, autolayout, plastic-like libs)
  func layoutSubviews()
}
```



this protocol is not doing anything for us, it's just a way to enforce the SSUL phases.

Perfect candidates for this protocol are reusable UI components like buttons, sliders and so on, for instance for a switch button we would have written:

```swift
class Switch: UIView, View {
  // properties
  var isOn: Bool = false {
    didSet {
      guard self.isOn != oldValue else { return }
      self.update()
    }
  }
  
  // subview to draw the thumb of the switch
  private var thumb = UIView()
  
  // interactions
  var valueDidChange: ((Double) -> ())?
  
  func setup() {
    // define the subviews that will make up the UI
  }
  
  func style() {
    // define the default look and feel of the UI elements
    // please bear in mind that we consider style only the look and feel that is not
    // depending from the state
  }
  
  func update() {
    // update the UI based on the value of the properties
  }
  
  func layoutSubviews() {
    // layout the subviews, optionally considering the properties
  }
}
```

the interface that the View is exposing is composed by **properties** and **interactions**. The properties are the internal state of the element that can be manipulated from the outside, interactions are callbacks used to react after changes occurred inside the element itself (like user interacting with the element changing its value)

### ModellableView

The View protocol is good enough for reusable components that can be manipulated through **properties**. 

There are a couple of drawbacks though:

- it's not easy to test this component
- the fact that in the update we don't know the actual property that is changed doesn't allow us to reason in terms of differences from the old values
- changing two or more properties at the same time will trigger two or more updates

To solve all of these issues we've introduced the concept of **ViewModel**. A ViewModel is  a struct that contains all the properties that define the state of a specific **ModellableView**.

```swift
public protocol ModellableView: View {
  associatedtype VM: ViewModel
  
  /// the ViewModel of the View. Once changed, the `update(oldModel: VM?)` will be called
  var model: VM! { get set }
  
  /// the ViewModel is changed, update the View
  func update(oldModel: VM?)
}
```



All the properties defining the state of the View are grouped inside a ViewModel, for instance:

```swift
struct ContactViewModel: ViewModel {
  var name: String = "John"
  var lastName: String = "Doe"
}
```

```swift
struct ContactView: ModellableView {
  
  // subviews to create the UI
  private var title = UILabel()
  private var subtitle = UILabel()
  
  // interactions
  var nameDidChange: ((String) -> ())?
  var lastNameDidChange: ((String) -> ())?
  
  func setup() {
    // define the subviews that will make up the UI
    self.addSubview(self.title)
    self.addSubview(self.subtitle)
    self.title.on(.didEndEditing) { [weak self] label in
      self?.nameDidChange?(label.text)
    }
    self.subtitle.on(.didEndEditing) { [weak self] label in
      self?.lastNameDidChange?(label.text)
    }
  }
  
  func style() {
    // define the default look and feel of the UI elements
    // please bear in mind that we consider style only the look and feel that is not
    // depending from the state
  }
  
  func update(oldModel: ContactViewModel?) {
      // update the UI based on the value of `self.model`
      // you can use `oldModel` to reason about diffs
    self.title.text = self.model.name
    self.subtitle.text = self.model.lastname
  }
  
  func layoutSubviews() {
    // layout the subviews, optionally considering the properties
  }
}
```

Implementing the **ModellableView** protocol we get:

- the `model: ContactViewModel!` variable is automatically created for you. Swift is inferring the Type through the `oldModel: ContactViewModel?` parameter of the `update` method, and we are adding the var exploiting a feature of the Objective-C runtime called [Associated Objects](http://nshipster.com/associated-objects/).
- the `func update(oldModel: ContactViewModel?)` is automatically called every time the `self.model` variable is changed
- testing the `ViewModel` is the same as testing the entire `ModellableView` given that all the state of the element is defined by the ViewModel itself. Testing the ViewModel is easy, because there are no actual pixels to check, just a bunch of properties
- inside the `update` method we now have the previous ViewModel so that we can reason about diffs
- we can change more than one property of the ViewModel and trigger just one single update in response

### ViewControllerModellableView

A special case of ModellableView is the `ViewControllerModellableView`, this is the main View that compose a screen and the one the ViewController is directly talking to. The ViewControllerModellableView differs from a generic ModellableView only for a couple of computed variables used as syntactic sugar to access navigation items on the navigation bar (if present)



## Note on the layout

Tempura is not enforcing a specific layouting system, inside the `layoutSubviews()` method of the view you are free to use the solution you prefer. Bear in mind that if at some point you need to trigger a layout update (for instance when your model changes) you are responsible to call `setNeedsLayout()` or `layoutIfNeeded()` if you want it to be called synchronously.

 


# Cool, show me the code!



## Setup the katana Store

Your entire app state is defined as a single struct:

```swift
struct CounterState: State {
  var counter: Int = 0
}
```

In your `AppDelegate` you will instantiate the katana store using the CounterState

```swift
self.store = Store<CounterState>(middleware: [], dependencies: DependenciesContainer.self)
```



## Defining the actions

The Katana `state` can only be modified through `Actions` so let's define actions to Increment and Decrement the counter:

```
struct IncrementCounter: AppAction {
  func updatedState(state: inout CounterState) {
    state.counter = state.counter + 1
  }
}
```

```
struct DecrementCounter: AppAction {
  func updatedState(state: inout CounterState) {
    state.counter = state.counter - 1
  }
}
```



## Create your first screen

Let's start using `Tempura` to create our first screen, a screen where we can look at the value of the counter and increment and decrement it.

### Define the ViewModel

The property we need from the state is the value of the counter, we then transform it to be used by the View.

```swift
struct CounterViewModel: ViewModelWithState {
  var count: String = ""

  init(state: CounterState) {
    self.count = "the counter is at \(state.counter)"
  }

  init() {}
  }
```

Please note that the ViewModel is the place where we transform the `counter: Int` that we have in the state to a `count: String` that contains the description of the counter that the View wants to display.

Reasons for doing this are:

- the `count: String` is **easier for the view to be consumed**, this goes in the direction of having the **dumbest possible View layer**
- **testing** the ViewModel will let us test the UI



### Create the View

The view is what we will have on screen. We want a label to show the value of the counter and two buttons to increment and decrement the counter.

```swift
class CounterView: UIView, ViewControllerModellableView {
  typealias CounterViewModel
  
  // #1 define the children UI elements
  private var counter = UILabel()
  private var sub = UIButton(type: .custom)
  private var add = UIButton(type: .custom)

  // #2 Setup, here we add children elements to the view
  override func setup() {
    self.addSubview(self.counter)
    self.addSubview(self.sub)
    self.addSubview(self.add)
    self.sub.on(.touchUpInside) {[weak self] button in
    	self.subtractButtonDidTap?()
	}
    self.add.on(.touchUpInside) {[weak self] button in
    	self.addButtonDidTap?()
	}
  }

  // #3 Style, define the style of the view and the children elements
  override func style() {
    self.backgroundColor = .white
    self.counter.textAlignment = .center
    self.sub.backgroundColor = .red
    self.sub.setTitle("sub", for: .normal)
    self.add.backgroundColor = .blue
    self.add.setTitle("add", for: .normal)
  }

  // #4 Update, the state is changed, update the view accordingly
  override func update(oldModel: CounterViewModel?) {
    self.counter.text = self.model.count
  }

  // #5 Interaction, define callbacks for interactions
  var subtractButtonDidTap: Interaction?
  var addButtonDidTap: Interaction?

  // #6 Layout, layout the children elements
  override func layout() {
    ...
  }

}
```



### Create the ViewController

Every time the state changes, the ViewController will instantiate a ViewModel from the new app state and feed the View with that, triggering the `update(...)` method. The other responsibility of the ViewController is to listen to interaction callbacks from the View and trigger actions to change the state.

```swift
class CounterViewController: ViewController<CounterView, CounterViewModel, CounterState> {

  // #1 listen for interaction callbacks from the view
  override func setupInteraction() {
    self.rootView.addButtonDidTap = self.addButtonDidTap
    self.rootView.subtractButtonDidTap = self.subtractButtonDidTap
  }

  // #2 trigger actions
  func addButtonDidTap() {
    self.dispatch(action: IncrementCounter())
  }

  func subtractButtonDidTap() {
    self.dispatch(action: DecrementCounter())
  }
}
```

As you can see the only things we need to handle are the interactions from the view, **there is no boilerplate needed to handle the updates from the state**, everything comes for free subclassing `ViewController`



# Handling the navigation

So far we've shown how to handle a single UI screen and how to keep it updated when the state changes.
When it comes to create a real app, the way you handle the navigation between screens is an important factor on the final result.

We believe that relying on the native iOS navigation system is the right choice for our stack, because:

- no navigation code to write and maintain just to mimic the way native navigation works
- native navigation gestures will come for free and will stay up to date with new iOS releases
- the app will feel more "native"

For these reasons we found a way to reconcile the redux-like world of Katana with the imperative world of the iOS navigation.



## The Routable protocol

If a Screen (read ViewController) takes an active part on the navigation (i.e. needs to present another screen) it must conform to the `Routable` protocol:

```swift
protocol Routable {
  var routeIdentifier: RouteElementIdentifier { get }
}
```

```swift
typealias RouteElementIdentifier = String
```

Each `Routable ` can be asked by the navigation system to perform a specific navigation task (like present another ViewController) based on the navigation action you dispatch.

## The route

A route is an array that represents a navigation path to a specific screen:

```swift
typealias Route = [RouteElementIdentifier]
```

## The navigation actions

Suppose we have a current Route of ["ScreenA", "ScreenB"] (being ScreenB the topmost ViewController/Routable)

Tempura exposes two main navigation actions:

#### Show

```swift
Show("ScreenC", animated: true, context: nil)
```

When this action is dispatched Tempura will ask ScreenB (the topmost `Routable` visible on the screen) to handle that action invoking the method (from the Routable protocol):

```swift
func show(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             context: Any?,
                             completion: @escaping RoutingCompletion) -> Bool {}
```

In order to allow ScreenB to present ScreenC we need to implement this `show` method:

```
extension ScreenB: Routable {
  func show(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             context: Any?,
                             completion: @escaping RoutingCompletion) -> Bool {
    if identifier == "ScreenC" {
      let screenToPresent = ScreenC()
      self.tempuraPresent(screenToPresent, animated: true, completion: {
        completion()
      })
      return true
    }
    return false
  }
}
```

We check if the identifier corresponds to the Routable we want to present, we instantiate the ViewController and present it using the `tempuraPresent` method, this is only syntactic sugar on top of the UIKit `UIViewController.present()` method.
We need to return true in order to signal Tempura that we are handling that navigation task, otherwise the system will ask the next Routable in line (ScreenA) to handle that.

The method is passing a completion closure, we are responsible to call it as soon as the presentation is complete.

#### Hide

After we present ScreenC the current route would be ["ScreenA", "ScreenB", "ScreenC"]. If we dispatch a Hide action:

```swift
Hide("ScreenC", animated: true, context: nil)
```

Tempura will ask the topmost Routable ("ScreenC") to dismiss itself:

```
extension ScreenC: Routable {
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    if identifier == "ScreenC" {
      self.tempuraDismiss(animated: animated)
      completion()
      return true
    }
    return false
  }
}
```

We check if identifier is "ScreenC" and we call `tempuraDismiss` on ScreenC itself. TempuraDismiss is just syntactic sugar on top of the UIKit `UIViewController.dismiss()`.
Note that the dismiss function does not have a completion callback so we call completion() right after that.
We return true to signify that we are handling that navigation action.
If we return false (the default implementation) Tempura will ask the next Routable (ScreenB) to dismiss ScreenC.




## The AppNavigation file

We suggest to organize the navigation of the application in a single file `AppNavigation.swift` where you can place all the conformances to Routable for the screens that are actively partecipating to the navigation

```swift
extension ScreenB: Routable {
  var routeIdentifier: RouteElementIdentifier {
  return Screen.screenB.rawValue
}

extension ScreenC: Routable {
  var routeIdentifier: RouteElementIdentifier {
  return Screen.screenC.rawValue
}

  func show(identifier: RouteElementIdentifier,
                             from: RouteElementIdentifier,
                             animated: Bool,
                             context: Any?,
                             completion: @escaping RoutingCompletion) -> Bool {
    if identifier == "ScreenC" {
      let screenToPresent = ScreenC()
      self.tempuraPresent(screenToPresent, animated: true, completion: {
        completion()
      })
      return true
    }
    return false
  }
  
  func hide(identifier: RouteElementIdentifier,
            from: RouteElementIdentifier,
            animated: Bool,
            context: Any?,
            completion: @escaping RoutingCompletion) -> Bool {
    if identifier == "ScreenC" {
      self.tempuraDismiss(animated: animated)
      completion()
      return true
    }
    return false
  }
}
```
