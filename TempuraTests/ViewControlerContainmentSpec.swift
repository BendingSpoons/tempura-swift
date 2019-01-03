//
//  ViewControlerContainmentSpec.swift
//  TempuraTests
//
//  Created by Andrea De Angelis on 26/10/2018.
//

@testable import Tempura
import Katana
import Quick
import Nimble

class ViewControllerContainmentSpec: QuickSpec {
  override func spec() {
    describe("ViewController containment") {
      
      struct AppState: State {
        var counter: Int = 0
      }
      
      struct Increment: Action {
        func updatedState(currentState: State) -> State {
          guard var state = currentState as? AppState else {
            fatalError()
          }
          state.counter += 1
          return state
        }
      }
      
      
      struct TestViewModel: ViewModelWithState {
        var counter: Int = 0
        
        init?(state: AppState) {
          self.counter = state.counter
        }
        
        init(counter: Int) {
          self.counter = counter
        }
      }
      
      class TestView: UIView, ViewControllerModellableView {
        var numberOfTimesSetupIsCalled: Int = 0
        var numberOfTimesStyleIsCalled: Int = 0
        var numberOfTimesUpdateIsCalled: Int = 0
        var lastOldModel: TestViewModel?
        
        typealias VM = TestViewModel
        func setup() {
          self.numberOfTimesSetupIsCalled += 1
        }
        
        func style() {
          self.numberOfTimesStyleIsCalled += 1
        }
        
        func update(oldModel: TestViewModel?) {
          self.numberOfTimesUpdateIsCalled += 1
          self.lastOldModel = oldModel
        }
        
        override func layoutSubviews() {
          
        }
      }
      
      class MainView: TestView {
        var container: ContainerView = ContainerView()
        
        override func setup() {
          super.setup()
          self.addSubview(self.container)
        }
        
        override func layoutSubviews() {
          super.layoutSubviews()
          self.container.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
      }
      
      class ChildView: TestView {}
      
      class TestViewController<V: UIView & ViewControllerModellableView>: ViewController<V> {
        var numberOfTimesWillUpdateIsCalled: Int = 0
        var viewModelWhenWillUpdateHasBeenCalled: V.VM?
        var newViewModelWhenWillUpdateHasBeenCalled: V.VM?
        var numberOfTimesDidUpdateIsCalled: Int = 0
        var viewModelWhenDidUpdateHasBeenCalled: V.VM?
        var oldViewModelWhenDidUpdateHasBeenCalled: V.VM?
        
        override func willUpdate(new: V.VM?) {
          self.numberOfTimesWillUpdateIsCalled += 1
          self.viewModelWhenWillUpdateHasBeenCalled = self.viewModel
          self.newViewModelWhenWillUpdateHasBeenCalled = new
        }
        
        override func didUpdate(old: V.VM?) {
          self.numberOfTimesDidUpdateIsCalled += 1
          self.viewModelWhenDidUpdateHasBeenCalled = self.viewModel
          self.oldViewModelWhenDidUpdateHasBeenCalled = old
        }
      }
      
      class MainViewController: TestViewController<MainView> {}
      
      class ChildViewController: TestViewController<ChildView> {}
      
      var store: PartialStore<AppState>!
      var mainVC: MainViewController!
      var childVC: ChildViewController!
      
      beforeEach {
        store = Store<AppState, EmptySideEffectDependencyContainer>()
        mainVC = MainViewController(store: store, connected: true)
      }
      
      
      it("will call update on the Child VC when the state is changed") {
        childVC = ChildViewController(store: store, connected: true)
        mainVC.add(childVC, in: mainVC.rootView.container)
        mainVC.viewWillAppear(true)
        expect(mainVC.rootView.model?.counter).to(equal(0))
        expect(childVC.rootView.model?.counter).to(equal(0))
        store.dispatch(Increment())
        expect(mainVC.rootView.model?.counter).toEventually(equal(1))
        expect(childVC.rootView.model?.counter).toEventually(equal(1))
      }
      
      it("will have the childView as child of the parentView") {
        childVC = ChildViewController(store: store, connected: true)
        mainVC.add(childVC, in: mainVC.rootView.container)
        expect(childVC.rootView.superview).to(equal(mainVC.rootView.container))
      }
      
      it("will not receive updates once disconnected") {
        childVC = ChildViewController(store: store, connected: true)
        mainVC.add(childVC, in: mainVC.rootView.container)
        mainVC.viewWillAppear(true)
        expect(mainVC.rootView.model?.counter).to(equal(0))
        expect(childVC.rootView.model?.counter).to(equal(0))
        childVC.connected = false
        store.dispatch(Increment())
        expect(mainVC.rootView.model?.counter).toEventually(equal(1))
        expect(childVC.rootView.model?.counter).toNotEventually(equal(1))
      }
      
      it("will be removed from the View hierarchy when removed from the parent VC") {
        childVC = ChildViewController(store: store, connected: true)
        mainVC.add(childVC, in: mainVC.rootView.container)
        expect(childVC.rootView.superview).to(equal(mainVC.rootView.container))
        childVC.remove()
        expect(childVC.rootView.superview).to(beNil())
      }
      
      it("will not receive updates when removed from the parent VC") {
        childVC = ChildViewController(store: store, connected: true)
        mainVC.add(childVC, in: mainVC.rootView.container)
        mainVC.viewWillAppear(true)
        expect(mainVC.rootView.model?.counter).to(equal(0))
        expect(childVC.rootView.model?.counter).to(equal(0))
        childVC.remove()
        store.dispatch(Increment())
        expect(mainVC.rootView.model?.counter).toEventually(equal(1))
        expect(childVC.rootView.model?.counter).toNotEventually(equal(1))
      }
    }
  }
}
