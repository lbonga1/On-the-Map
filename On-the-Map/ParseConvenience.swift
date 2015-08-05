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
        
        // Set the variables
        let parameters = [String: AnyObject]()
        let baseURL = Constants.ParseBaseURLSecure
        let method = ""
        let key = ""
        
        self.taskForGETMethod(parameters, baseURL: baseURL, method: method, key: key) { result, error in
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(result: nil, errorString: "Please check your network connection, then tap refresh to try again.")
            } else {
                if let results = result.valueForKey(OTMClient.JsonResponseKeys.Results) as? [[String : AnyObject]] {
                    var studentLocations = StudentLocations.locationsFromResults(results)
                    completionHandler(result: studentLocations, errorString: "successful")
                } else {
                    completionHandler(result: nil, errorString: "Server error. Please tap refresh to try again.")
                }
            }
        }
    }
    
    // Post location to Parse.
    func postLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Set the variables
        var parameters = [String: AnyObject]()
        let baseURL = Constants.ParseBaseURLSecure
        let method = ""
        let jsonBody: [String: AnyObject] = [
            "unique key": NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!,
            "firstName": Data.sharedInstance().userFirstName,
            "lastName": Data.sharedInstance().userLastName,
            "mapString": Data.sharedInstance().mapString,
            "mediaURL": Data.sharedInstance().mediaURL,
            "latitude": Data.sharedInstance().region.center.latitude,
            "longitude": Data.sharedInstance().region.center.longitude
        ]
        
        self.taskForPOSTMethod(parameters, baseURL: baseURL, method: method, jsonBody: jsonBody) { result, error in
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandler(success: false, errorString: "Please check your network connection and try again.")
            } else {
                if let results = result.valueForKey(OTMClient.JsonResponseKeys.ObjectID) as? String {
                    Data.sharedInstance().objectID = results
                    completionHandler(success: true, errorString: "successful")
                } else {
                    completionHandler(success: false, errorString: "Please try again.")
                }
            }
        }
    }
}

