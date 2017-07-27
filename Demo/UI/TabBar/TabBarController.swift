//
//  TabViewController.swift
//  Tempura
//
//  Created by Andrea De Angelis on 24/07/2017.
//
//

import Foundation
import UIKit
import Katana
import Tempura

class TabBarController: UITabBarController {
  var store: AnyStore
  
  init(store: AnyStore) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
    self.setupChildren()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupChildren() {
    // HOME
    let home = HomeViewController(store: self.store)
    let homeNavigationController = RoutableNavigationController(rootViewController: home)
    homeNavigationController.isHeroEnabled = true
    homeNavigationController.heroNavigationAnimationType = .fade
    homeNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
    homeNavigationController.setNavigationBarHidden(true, animated: false)
    
    // DEPENDENCIES TEST
    guard let fakeManager = App.dependencies?.fakeManager else { fatalError("fakeManager is needed") }
    let dependenciesTest = DependenciesTestViewController(dependency: fakeManager)
    dependenciesTest.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)
    
    // MODAL TEST
    let modalTest = ModalTestViewController(store: self.store)
    modalTest.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 4)
    
    self.viewControllers = [homeNavigationController,
                            dependenciesTest,
                            modalTest
                          ]
  }

}

class RoutableNavigationController: UINavigationController {}
