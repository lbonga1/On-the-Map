//
//  ParseConvenience.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 7/23/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    // Get student location data from Parse.
    func getStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: String?) -> Void) {
        
        /* 1. Set the parameters */
        let parameters = [String: AnyObject]()
        
        let baseURL = Constants.ParseBaseURLSecure
        let method = ""
        let key = ""
        
        let parseID = Constants.ParseAppID
        let parseKey = Constants.ParseAPIKey
        
        /* 2. Configure the request */
        let request = NSMutableURLRequest()
        request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        
        self.taskForGETMethod(parameters, baseURL: baseURL, method: method, key: key) { result, error in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                println("error 1")
                completionHandler(result: nil, errorString: "Please tap refresh to try again.")
            } else {
                if let results = result.valueForKey(OTMClient.JsonResponseKeys.Results) as? [[String : AnyObject]] {
                    var studentLocations = StudentLocations.locationsFromResults(results)
                    completionHandler(result: studentLocations, errorString: "successful")
                    println("Success")
                } else {
                    println("error 2")
                    completionHandler(result: nil, errorString: "Please tap refresh to try again.")
                }
            }
        }
    }
    
    // Post location
    func postLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var parameters = [String: AnyObject]()
        
        let jsonBody: [String: AnyObject] = [
            "unique key": JsonResponseKeys.UserID,
            "firstName": JsonResponseKeys.FirstName,
            "lastName": JsonResponseKeys.LastName,
            "mapString": JsonResponseKeys.MapString,
            "mediaURL": JsonResponseKeys.MediaURL,
            "latitude": JsonResponseKeys.Latitude,
            "longitude": JsonResponseKeys.Longitude
            ]
        
        let baseURL = Constants.ParseBaseURLSecure
        let method = ""
        
        let request = NSMutableURLRequest()
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(success: false, errorString: "Please check your network connection and try again.")
            } else {
                if let resultDictionary = result.valueForKey(OTMClient.JsonResponseKeys.Account) as? NSDictionary {
                    if let results = resultDictionary.valueForKey(OTMClient.JsonResponseKeys.ObjectID) as? String {
                        completionHandler(success: true, errorString: "successful")
                    }
                } else {
                    completionHandler(success: false, errorString: "Please try again.")
                }
            }
        })
    }
}

