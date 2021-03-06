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
    
    // Shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
// MARK: - Methods
    
    // Get type network call.
    func taskForGETMethod(parameters: [String : AnyObject], baseURL: String, method: String, key: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 2/3. Build the URL and configure the request
        let urlString = baseURL + method + key
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if baseURL == Constants.ParseBaseURLSecure {
            let parseID = Constants.ParseAppID
            let parseKey = Constants.ParseAPIKey
            
            request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(parseKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // 5/6. Parse the data and use the data (happens in completion handler)
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData : NSData?
                if baseURL == Constants.UdacityBaseURLSecure {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                } else {
                    newData = data
                }
                OTMClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }

    // Post type network call.
    func taskForPOSTMethod(parameters: [String: AnyObject], baseURL: String, method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. Set the parameters
        let parameters = [String: AnyObject]()
        
        // 2. Build the URL
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        
        if baseURL == Constants.ParseBaseURLSecure {
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
            } catch {
                request.HTTPBody = nil
            }
        } else {
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
            } catch {
                request.HTTPBody = nil
            }
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            // 5/6. Parse the data and use the data (happens in completion handler)
            if let _ = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData : NSData?
                if baseURL == Constants.UdacityBaseURLSecure {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                } else {
                    newData = data
                }
                OTMClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    func taskForPutMethod(parameters: [String: AnyObject], baseURL: String, method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. Set the parameters
        let parameters = [String: AnyObject]()
        
        // 2. Build the URL
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch {
            request.HTTPBody = nil
        }
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            // 5/6. Parse the data and use the data (happens in completion handler)
            if let _ = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        
        return task
        
    }
    
        
// MARK: - Helpers
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // Helper: Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let parsingError: NSError? = nil
        let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)as? NSDictionary
        
        if let _ = parsingError {
            completionHandler(result: nil, error: parsingError)
            print(parsingError)
        } else {
            //println(parsedResult)
            completionHandler(result: parsedResult as! [String: AnyObject], error: nil)
        }
    }
    
    // Helper: Substitute the key for the value that is contained within the method name
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

