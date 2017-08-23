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
  var dependencies: DependenciesContainer
  
  init(store: AnyStore, dependencies: DependenciesContainer) {
    self.store = store
    self.dependencies = dependencies
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
    let fakeManager = self.dependencies.fakeManager
    let dependenciesTest = DependenciesTestViewController(dependency: fakeManager, store: self.store)
    dependenciesTest.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
    
    // LOCAL STATE TEST
    let localStateTest = LocalStateTestViewController(store: self.store)
    localStateTest.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 2)
    
    // MODAL TEST
    let modalTest = ModalTestViewController(store: self.store)
    modalTest.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 3)
    
    // ANIMATION TEST
    let animationTest = AnimationTestViewController(store: self.store)
    animationTest.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 4)
    
    self.viewControllers = [homeNavigationController,
                            dependenciesTest,
                            localStateTest,
                            modalTest,
                            animationTest
                          ]
  }

}

class RoutableNavigationController: UINavigationController {}
