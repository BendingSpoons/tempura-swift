//
//  ViewControllerWithLocalState.swift
//  TempuraTests
//
//  Created by Andrea De Angelis on 17/10/2017.
//

@testable import Tempura
import Katana
import Quick
import Nimble

class ViewControllerWithLocalStateSpec: QuickSpec {
  override func spec() {
    describe("a ViewControllerWithLocalState") {
      
      struct AppState: State {
        var counter: Int = 0
      }
      
      struct Increment: StateUpdater {
        func updateState(_ currentState: inout AppState) {
          currentState.counter += 1
        }
      }
      
      struct TestLocalState: LocalState {
        var localCounter: Int = 0
      }
      
      struct TestViewModelWithLocalState: ViewModelWithLocalState {
        var counter: Int? = nil
        var localCounter: Int = 0
        
        init(state: AppState?, localState: TestLocalState) {
          self.counter = state?.counter
          self.localCounter = localState.localCounter
        }
        
        init(counter: Int?, localCounter: Int) {
          self.counter = counter
          self.localCounter = localCounter
        }
      }
      
      class TestView: UIView, ViewControllerModellableView {
        var numberOfTimesSetupIsCalled: Int = 0
        var numberOfTimesStyleIsCalled: Int = 0
        var numberOfTimesUpdateIsCalled: Int = 0
        var lastOldModel: TestViewModelWithLocalState?
        
        typealias VM = TestViewModelWithLocalState
        func setup() {
          self.numberOfTimesSetupIsCalled += 1
        }
        
        func style() {
          self.numberOfTimesStyleIsCalled += 1
        }
        
        func update(oldModel: TestViewModelWithLocalState?) {
          self.numberOfTimesUpdateIsCalled += 1
          self.lastOldModel = oldModel
        }
        
        override func layoutSubviews() {
          
        }
      }
      
      class TestViewControllerWithLocalState: ViewControllerWithLocalState<TestView> {
        var numberOfTimesWillUpdateIsCalled: Int = 0
        var viewModelWhenWillUpdateHasBeenCalled: TestViewModelWithLocalState?
        var newViewModelWhenWillUpdateHasBeenCalled: TestViewModelWithLocalState?
        var numberOfTimesDidUpdateIsCalled: Int = 0
        var viewModelWhenDidUpdateHasBeenCalled: TestViewModelWithLocalState?
        var oldViewModelWhenDidUpdateHasBeenCalled: TestViewModelWithLocalState?
        
        override func willUpdate(new: TestViewModelWithLocalState?) {
          self.numberOfTimesWillUpdateIsCalled += 1
          self.viewModelWhenWillUpdateHasBeenCalled = self.viewModel
          self.newViewModelWhenWillUpdateHasBeenCalled = new
        }
        
        override func didUpdate(old: TestViewModelWithLocalState?) {
          self.numberOfTimesDidUpdateIsCalled += 1
          self.viewModelWhenDidUpdateHasBeenCalled = self.viewModel
          self.oldViewModelWhenDidUpdateHasBeenCalled = old
        }
        
        init(store: PartialStore<V.VM.S>, connected: Bool = false) {
          let localState = TestLocalState()
          super.init(store: store, localState: localState, connected: connected)
        }
        
        required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
        }
      }
      
      var store: Store<AppState, EmptySideEffectDependencyContainer>!
      var testVC: TestViewControllerWithLocalState!
      
      beforeEach {
        store = Store<AppState, EmptySideEffectDependencyContainer>()
        expect(store.isReady).toEventually(beTrue())

        testVC = TestViewControllerWithLocalState(store: store)
      }
      
      it("when localViewModel is updated, view.update() method is called the right amount of times and with the correct model and oldModel") {
        let viewModel = TestViewModelWithLocalState(counter: 100, localCounter: 200)
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
        testVC.viewModel = viewModel
        expect(testVC.rootView.lastOldModel?.counter).to(beNil())
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(2))
        expect(testVC.rootView.model?.counter).to(equal(100))
        expect(testVC.rootView.model?.localCounter).to(equal(200))
        let newViewModel = TestViewModelWithLocalState(counter: 101, localCounter: 201)
        testVC.viewModel = newViewModel
        expect(testVC.rootView.lastOldModel?.counter).to(equal(100))
        expect(testVC.rootView.lastOldModel?.localCounter).to(equal(200))
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(3))
        expect(testVC.rootView.model?.counter).to(equal(101))
        expect(testVC.rootView.model?.localCounter).to(equal(201))
      }
      
      it("when localState is changed, the viewModel is updated") {
        testVC.viewWillAppear(true)
        expect(testVC.rootView.model?.localCounter).to(equal(0))
        testVC.localState.localCounter = 11
        expect(testVC.rootView.model?.localCounter).to(equal(11))
      }
      
      it("when localState is changed, the ViewModel is updated, if the ViewController is not connected the global state part of the ViewModel is not updated") {
        testVC.viewWillAppear(true)
        expect(testVC.rootView.model?.localCounter).to(equal(0))
        testVC.localState.localCounter = 11
        testVC.dispatch(Increment())
        expect(testVC.rootView.model?.localCounter).to(equal(11))
        // check if the dispatch of the Increment is not resetting the local state
        expect(testVC.rootView.model?.localCounter).toNotEventually(equal(0))
        expect(testVC.rootView.model?.counter).toEventually(equal(1))
      }
      
      it("when the ViewControllerWithLocalState appears on screen, the update is called exactly once") {
        let vc = TestViewControllerWithLocalState(store: store, connected: false)
        // ViewControllerWithLocalState will trigger an update upon creation even if it's disconnected
        // because it needs to update thw ViewModel based on the localState
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
        vc.connected = true
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
        testVC.viewWillAppear(true)
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(2))
      }
      
      it("when a ViewControllerWithLocalState is not connected and we update the local state, the AppState part of the ViewModel must be nil") {
        let disconnectedVC = TestViewControllerWithLocalState(store: store, connected: false)
        disconnectedVC.shouldConnectWhenVisible = false
        expect(disconnectedVC.viewModel?.counter).to(beNil())
        disconnectedVC.viewWillAppear(true)
        disconnectedVC.localState.localCounter = 3
        expect(disconnectedVC.viewModel?.localCounter).to(equal(3))
        expect(disconnectedVC.viewModel?.counter).to(beNil())
      }
    }
  }
}

