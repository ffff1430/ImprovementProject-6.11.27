//
//  TabViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/27.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    lazy var page1ViewController: UIViewController = {
        let viewcontroller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstViewControllerId")
        return viewcontroller
    }()
    
    lazy var page2ViewController: UIViewController = {
        let viewcontroller = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "Discover")
        return viewcontroller
    }()
    
    lazy var page3ViewController: UIViewController = {
        let viewcontroller = UIStoryboard(name: "About", bundle: nil).instantiateViewController(withIdentifier: "About")
        return viewcontroller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let page1Navigation = UINavigationController(rootViewController: page1ViewController)
        page1Navigation.navigationBar.topItem?.title = "FoodPin"
        page1Navigation.tabBarItem.image = UIImage(named: "favorite")
        page1Navigation.tabBarItem.title = "Favorite"
        page1Navigation.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.tabBarItemColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.tabBarItemColor]
        
        page1Navigation.navigationBar.tintColor = .red
        page1Navigation.navigationBar.standardAppearance = appearance
        page1Navigation.navigationBar.compactAppearance = appearance
        page1Navigation.navigationBar.scrollEdgeAppearance = appearance
        
        let page2Navigation = UINavigationController(rootViewController: page2ViewController)
        page2Navigation.tabBarItem.image = UIImage(named: "discover")
        page2Navigation.navigationBar.topItem?.title = "Discover"
        page2Navigation.tabBarItem.title = "Discover"
        
        let page3Navigation = UINavigationController(rootViewController: page3ViewController)
        page3Navigation.tabBarItem.image = UIImage(named: "about")
        page3Navigation.tabBarItem.title = "About"
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tabBarItemColor], for: .normal)
        UITabBar.appearance().tintColor = UIColor.tabBarItemColor
        
        viewControllers = [page1Navigation, page2Navigation, page3Navigation]
    }
}
