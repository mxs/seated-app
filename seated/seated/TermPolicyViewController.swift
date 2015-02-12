//
//  TermPolicyViewController.swift
//  seated
//
//  Created by Michael Shang on 11/02/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit
import WebKit

class TermPolicyViewController: UIViewController {

    var webView: WKWebView?
    var urlString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = NSURL(string:urlString!)
        var req = NSURLRequest(URL: url!)
        let source = "jQuery('#header').hide(); jQuery('#footer').hide()"
        let userScript = WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        
        var userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        var configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.view = self.webView
        self.webView!.loadRequest(req)
        // Do any additional setup after loading the view.
    }

}
