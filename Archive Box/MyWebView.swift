//
//  MyWebView.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class MyWebView: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView : WKWebView?
    var link: String? {
        didSet {
            if let url = URL(string: link!){
                setupWebView()
//                webView?.loadRequest(URLRequest(url: url))
                webView?.load(URLRequest(url: url))
//                let web = WKWebView()
                webView?.allowsLinkPreview = true
//                web.load(URLRequest(url: url))
                webView?.evaluateJavaScript("document.querySelector('meta[property='og:url']').getAttribute('content')") { (result, error) in
                    if error != nil {
                        print("document.getElementsByTagName \(result)")
                    }
                }
                webView?.allowsBackForwardNavigationGestures = true
                webView?.navigationDelegate = self
                webView?.uiDelegate = self
            }else{
                let alert = UIAlertController(title:"The URL is invalid", message: nil, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissView))
        
        self.navigationItem.rightBarButtonItem = closeButton
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    override func viewDidLoad() {
       
        
        
        
        //webView.loadRequest(URLRequest(url: URL(string: "http://www.dogeartravel.com/eula.html")!))
        
       
        
        self.edgesForExtendedLayout = []
        
        
    }
    
    func setupWebView() {
        webView = WKWebView()
        self.view.addSubview(webView!)
        webView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
}
