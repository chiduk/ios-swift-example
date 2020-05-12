//
//  WebViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 11/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class  WebViewController : UIViewController, UIWebViewDelegate {
    
    var url : URL?
    override func viewDidLoad() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 44)
        menuBtn.setImage(UIImage(named:"closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        menuBtn.tintColor = .white
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 50)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        //        setupWebView()
    }
    
    deinit {
        print("WebViewController denit successful")
    }
    
    var webView : UIWebView!
    func setupWebView() {
        webView = UIWebView(frame: self.view.bounds)
        webView.delegate = self
        if let link = url {
            let request = URLRequest(url: link)
            webView.loadRequest(request)
        }
        
        view.addSubview(webView)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true) {
            
        }
    }
    
}
