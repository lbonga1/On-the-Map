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
    
    func getStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        let request = NSMutableURLRequest()
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        
        self.taskForGETMethod(parameters) { result, error in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, errorString: "Could not complete request.")
            } else {
                if let results = result.valueForKey(OTMClient.JsonResponseKeys.Results) as?
                    [[String : AnyObject]] {
                        var studentLocations = StudentLocations.locationsFromResults(results)
                        completionHandler(result: studentLocations, errorString: "successful")
                        println("Success")
                } else {
                    completionHandler(result: nil, errorString: "unsuccessful")
                }
            }
        }
    }
}

