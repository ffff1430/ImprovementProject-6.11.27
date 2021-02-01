//
//  DiscoverViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/27.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import WebKit

class DiscoverViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goWeb()
    }
    
    private func goWeb() {
        if let url = URL(string: "https://developer.apple.com/programs/"){
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
