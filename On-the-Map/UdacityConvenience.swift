//
//  UdacityConvenience.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 7/23/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    // Login to Udacity.
    func udacityLogin(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var parameters = [String: AnyObject]()
        
        let jsonBody = ["udacity": ["username" : username, "password" : password]]
        
        let baseURL = Constants.UdacityBaseURLSecure
        
        let request = NSMutableURLRequest()
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        /* 2. Make the request */
        self.taskForPOSTMethod(parameters, baseURL: baseURL, jsonBody: jsonBody, completionHandler: { (result, error) -> Void in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, errorString: "Please check your network connection and try again.")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let results = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.Registered) as? Int {
                            completionHandler(success: true, errorString: "successful")
                    }
                } else {
                    completionHandler(success: false, errorString: "Username or password is incorrect.")
                    println("Could not find \(JsonResponseKeys.Account) in \(result)")
                }
            }
        })
    }
    
    // Logout of Udacity.
    func udacityLogout(completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.UdacityBaseURLSecure)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: "Could not logout.")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandler(success: true, error: nil)
        }
        task.resume()
    }

}
