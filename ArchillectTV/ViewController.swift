//
//  ViewController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/24/15.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var webview: WKWebView = WKWebView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let request = NSURLRequest(URL: NSURL(string: "http://archillect.com/tv")!)
        self.webview.loadRequest(request)
        self.view.addSubview(self.webview)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        self.webview.frame = bounds
    }
}
