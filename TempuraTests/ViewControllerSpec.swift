@testable import Tempura
import Katana
import Quick
import Nimble

class ViewControllerSpec: QuickSpec {
  override func spec() {
    describe("a ViewController") {
      
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
        
        init(state: AppState) {
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
      
      class TestViewController: ViewController<TestView> {
        var numberOfTimesWillUpdateIsCalled: Int = 0
        var viewModelWhenWillUpdateHasBeenCalled: TestViewModel?
        var numberOfTimesDidUpdateIsCalled: Int = 0
        var viewModelWhenDidUpdateHasBeenCalled: TestViewModel?
        
        override func willUpdate() {
          self.numberOfTimesWillUpdateIsCalled += 1
          self.viewModelWhenWillUpdateHasBeenCalled = self.viewModel
        }
        
        override func didUpdate() {
          self.numberOfTimesDidUpdateIsCalled += 1
          self.viewModelWhenDidUpdateHasBeenCalled = self.viewModel
        }
      }
      
      var store: Store<AppState>!
      var testVC: TestViewController!
      
      beforeEach {
        store = Store<AppState>(middleware: [], dependencies: EmptySideEffectDependencyContainer.self)
        testVC = TestViewController(store: store)
      }
      
      
      it("call view.setup() and view.style() methods exactly once") {
        expect(testVC.rootView.numberOfTimesSetupIsCalled).to(equal(1))
        expect(testVC.rootView.numberOfTimesStyleIsCalled).to(equal(1))
      }
      
      it("when viewModel is updated, view.update() method is called with the correct model and oldModel") {
        let viewModel = TestViewModel(counter: 100)
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
        testVC.viewModel = viewModel
        expect(testVC.rootView.lastOldModel?.counter).to(equal(0))
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(2))
        expect(testVC.rootView.model.counter).to(equal(100))
        let newViewModel = TestViewModel(counter: 200)
        testVC.viewModel = newViewModel
        expect(testVC.rootView.lastOldModel?.counter).to(equal(100))
        expect(testVC.rootView.numberOfTimesUpdateIsCalled).to(equal(3))
        expect(testVC.rootView.model.counter).to(equal(200))
      }
      
      it("when an action is dispatched, the viewModel is updated if the ViewController is connected") {
        testVC.viewWillAppear(true)
        expect(testVC.rootView.model.counter).to(equal(0))
        store.dispatch(Increment())
        expect(testVC.rootView.model.counter).toEventually(equal(1))
      }
      
      it("when an action is dispatched, the viewModel is not updated if the ViewController is not connected") {
        testVC.viewWillAppear(true)
        testVC.connected = false
        expect(testVC.rootView.model.counter).to(equal(0))
        store.dispatch(Increment())
        expect(testVC.rootView.model.counter).toNotEventually(equal(1))
      }
      
      it("when a disconnected ViewController is created, the update is never called. It will be called on the first connect") {
        let vc = TestViewController(store: store, connected: false)
        expect(vc.rootView.numberOfTimesUpdateIsCalled).to(equal(0))
        vc.connected = true
        expect(vc.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
        vc.connected = false
        expect(vc.rootView.numberOfTimesUpdateIsCalled).to(equal(1))
      }
      
      it("before and after the viewModel is updated willUpdate() and didUpdate() are called") {
        testVC.viewWillAppear(true)
        expect(testVC.numberOfTimesWillUpdateIsCalled).to(equal(1))
        expect(testVC.numberOfTimesDidUpdateIsCalled).to(equal(1))
        store.dispatch(Increment())
        expect(testVC.numberOfTimesWillUpdateIsCalled).toEventually(equal(2))
        expect(testVC.numberOfTimesDidUpdateIsCalled).toEventually(equal(2))
        expect(testVC.viewModelWhenWillUpdateHasBeenCalled?.counter).toNotEventually(equal(1))
        expect(testVC.viewModelWhenDidUpdateHasBeenCalled?.counter).toEventually(equal(1))
      }
      
      
    }
  }
}
