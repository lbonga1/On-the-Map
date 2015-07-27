//
//  OTMClient.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

class OTMClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
// MARK: - Methods
    
    // Get type network call.
    func taskForGETMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parameters = [String: AnyObject]()
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.ParseBaseURLSecure + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // Post type network call.
    func taskForPOSTMethod(parameters: [String: AnyObject], baseURL: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parameters = [String: AnyObject]()
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURL + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData : NSData?
                
                if baseURL.rangeOfString(Constants.UdacityBaseURLSecure) != nil{
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                }else{
                    newData = data
                }
                OTMClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
        
// MARK: - Helpers
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)as? NSDictionary
        
        if let error = parsingError {
            completionHandler(result: nil, error: parsingError)
            println(parsingError)
        } else {
            println(parsedResult)
            completionHandler(result: parsedResult as! [String: AnyObject], error: nil)
        }
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
}

