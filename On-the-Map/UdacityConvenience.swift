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
    
    // Login to Udacity and get User Id.
    func udacityLogin(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        // Set the variables
        var parameters = [String: AnyObject]()
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacitySession
        let jsonBody = ["udacity": ["username": username, "password" : password]]
        
        // Make the request
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody) { result, error in
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, errorString: "Please check your network connection and try again.")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let userID = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.UserID) as? String {
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "UdacityUserID")
                        completionHandler(success: true, errorString: "successful")
                    }
                } else {
                    completionHandler(success: false, errorString: "Username or password is incorrect.")
                    println("Could not find \(JsonResponseKeys.Account) in \(result)")
                }
            }
        }
    }
    
    // Login to Udacity using Facebook credentials.
    func loginWithFacebook(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Set the variables
        var parameters = [String: AnyObject]()
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacitySession
        let jsonBody = ["facebook_mobile": ["access_token": NSUserDefaults.standardUserDefaults().stringForKey("FBAccessToken")!]]
        
        // Make the request
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody) { result, error in
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, errorString: "Please check you network connection and try again.")
                println("error1")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let userID = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.UserID) as? String {
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "UdacityUserID")
                        completionHandler(success: true, errorString: "successful")
                        println("completed parse")
                    }
                } else {
                    completionHandler(success: false, errorString: "Server error: Please try again.")
                    println("error2")
                }
            }
        }
    }
    
    // Get user's public data from Udacity.
    func getUserData(completionHandler: (success: Bool, error: String) -> Void) {
        
        // Set the variables
        var parameters = [String: AnyObject]()
        let baseURL = Constants.UdacityBaseURLSecure
        let method = Methods.UdacityData
        let key = NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!
        
        // Make the request
        self.taskForGETMethod(parameters, baseURL: baseURL, method: method, key: key) { result, error in
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, error: "Please check your network connection and try again.")
            } else {
                if let userDictionary = result.valueForKey(OTMClient.JsonResponseKeys.User) as? NSDictionary {
                    if let firstName = userDictionary.valueForKey(OTMClient.JsonResponseKeys.UserFirstName) as? String {
                        Data.sharedInstance().userFirstName = firstName
                        if let lastName = userDictionary.valueForKey(OTMClient.JsonResponseKeys.UserLastName) as? String {
                            Data.sharedInstance().userLastName = lastName
                            completionHandler(success: true, error: "successful")
                        }
                    }
                } else {
                    completionHandler(success: false, error: "Server error. Please try again.")
                }
            }
        }
    }
    
    // Logout of Udacity.
    func udacityLogout(completionHandler: (success: Bool, error: String?) -> Void) {
        
        // Build the URL and configure the request
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
        
        // Make the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // Send the desired value(s) to completion handler
            if error != nil {
                completionHandler(success: false, error: "Could not logout.")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            completionHandler(success: true, error: nil)
        }
        task.resume()
    }

}
