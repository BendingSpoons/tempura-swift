//
//  NavigationSpec.swift
//  TempuraTests
//
//  Created by Andrea De Angelis on 13/02/2018.
//

@testable import Tempura
import Katana
import Quick
import Nimble

class NavigationSpec: QuickSpec, RootInstaller {
  
  var store: Store<AppState> = Store<AppState>(middleware: [], dependencies: AppDependencyContainer.self)
  var window: UIWindow! = UIWindow(frame: UIScreen.main.bounds)
  
  enum Screen: String {
    case a
    case b
    case c
    case d
  }
  
  struct AppState: State {
    var counter: Int = 0
  }
  
  class AppDependencyContainer: NavigationProvider {
    required init(dispatch: @escaping StoreDispatch, getState: @escaping () -> State) {}
    var navigator = Navigator()
  }
  
  struct AViewModel: ViewModelWithState {
    init(state: AppState) {
    }
  }
  
  class AView: UIView, ViewControllerModellableView {
    typealias VM = AViewModel
    
    func setup() {}
    func style() {}
    func update(oldModel: AViewModel?) {}
  }
  
  class AViewController: ViewController<AView> {
    
  }
  
  func installRoot(identifier: RouteElementIdentifier, context: Any?, completion: () -> ()) {
    let a = AViewController(store: self.store)
    self.window.rootViewController = a
    self.window.makeKeyAndVisible()
    print(UIApplication.shared.currentRoutables)
  }
  
  
  override func spec() {
    describe("a ViewController") {
      
      
      
      struct TestViewModel: ViewModelWithState {
        var counter: Int = 0
        
        init(state: AppState) {
          self.counter = state.counter
        }
        
        init(counter: Int) {
          self.counter = counter
        }
      }
      
      beforeEach {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        self.continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        (self.store.dependencies as? AppDependencyContainer)?.navigator.setupWith(rootInstaller: self, window: self.window, rootElementIdentifier: Screen.a.rawValue)
      }
      
      
      it("call view.setup() and view.style() methods exactly once") {
        //expect(testVC.rootView.numberOfTimesSetupIsCalled).to(equal(1))
        //expect(testVC.rootView.numberOfTimesStyleIsCalled).to(equal(1))
      }
    }
  }
}



