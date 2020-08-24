//
//  SwitchViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class SwitchViewController: UIViewController {
    
    enum TabIndex : Int {
        case firstChildTab = 0
        case secondChildTab = 1
    }

    @IBOutlet weak var vcContent: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewControllerId")
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewControllerId")
        
        return secondChildTabVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segment.selectedSegmentIndex = TabIndex.firstChildTab.rawValue
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    

    @IBAction func switchVC(_ sender: UISegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.vcContent.bounds
            self.vcContent.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.firstChildTab.rawValue :
            vc = firstChildTabVC
        case TabIndex.secondChildTab.rawValue :
            vc = secondChildTabVC
        default:
        return nil
        }
    
        return vc
    }

}
