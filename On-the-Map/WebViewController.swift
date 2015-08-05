//
//  WebViewController.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 8/4/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

// MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillAppear(animated: Bool) {
        
        // Build the URL
        let url = NSURL(string: Data.sharedInstance().testLink)!
        let request = NSURLRequest(URL: url)
        
        // Make the request
        webView.loadRequest(request)
    }
    
// MARK: - Actions
    
    @IBAction func dismissWebView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
