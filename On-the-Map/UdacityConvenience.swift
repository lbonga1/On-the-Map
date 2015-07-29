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
        
        self.getUserID(username, password: password, completionHandler: { userID, errorString in
            if let userID = userID {
                NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "UdacityUserID")
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Could not complete request")
            }
        })
    }
    
    // Get user ID.
    func getUserID(username: String, password: String, completionHandler: (userID: String?, errorString: String?) -> Void) {
        
        var parameters = [String: AnyObject]()
        let jsonBody = ["udacity": ["username": username, "password" : password]]
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacitySession
        
        let request = NSMutableURLRequest()
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 2. Make the request */
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody, completionHandler: { (result, error) -> Void in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(userID: nil, errorString: "Please check your network connection and try again.")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let userID = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.UserID) as? String {
                        completionHandler(userID: userID, errorString: "successful")
                    }
                } else {
                    completionHandler(userID: nil, errorString: "Username or password is incorrect.")
                    println("Could not find \(JsonResponseKeys.Account) in \(result)")
                }
            }
        })
    }
    
    // Login to Udacity using Facebook credentials.
    func loginWithFacebook(completionHandler: (success: Bool, errorString: String?) -> Void) {
        var parameters = [String: AnyObject]()
        let jsonBody = ["facebook_mobile": ["access_token": NSUserDefaults.standardUserDefaults().stringForKey("FBAccessToken")!]]
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacitySession
        
        let request = NSMutableURLRequest()
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        println("start taskforpost")
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: "Please try again.")
                println("error1")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let results = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.UserID) as? String {
                        completionHandler(success: true, errorString: "successful")
                        println("completed parse")
                    }
                } else {
                    completionHandler(success: false, errorString: "Please try again.")
                    println("error2")
                }
            }
        })
    }
    
    // Get user's public data from Udacity.
    func getUserData(completionHandler: (success: Bool, error: String) -> Void) {
        
        var parameters = [String: AnyObject]()
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacityData
        let key = NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!
        
        self.taskForGETMethod(parameters, baseURL: baseURL, method: method, key: key) { result, error in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                println("user data error 1")
                completionHandler(success: false, error: "Please check your network connection and try again.")
            } else {
                if let userDictionary = result.valueForKey(OTMClient.JsonResponseKeys.User) as? NSDictionary {
                    if let firstName = result.valueForKey(OTMClient.JsonResponseKeys.UserFirstName) as? String {
                        if let lastName = result.valueForKey(OTMClient.JsonResponseKeys.UserLastName) as? String {
                            completionHandler(success: true, error: "successful")
                            println("Success, user data")
                        }
                    }
                } else {
                    println("user data error 2")
                    completionHandler(success: false, error: "Please try again.")
                }
            }
        }
    }
    
    // Logout of Udacity.
    func udacityLogout(completionHandler: (success: Bool, error: String?) -> Void) {
        let method = Methods.UdacitySession
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.UdacityBaseURLSecure + method)!)
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
