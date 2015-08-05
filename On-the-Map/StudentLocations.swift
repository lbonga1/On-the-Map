//
//  StudentLocations.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/3/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocations {
    
    var createdAt = ""
    var firstName = ""
    var lastName = ""
    var latitude = 0.0
    var longitude = 0.0
    var mapString = ""
    var mediaURL = ""
    var objectID = ""
    var uniqueKey = ""
    var updatedAt = ""
    
    //Construct a StudentLocation from a dictionary
    init(dictionary: [String : AnyObject]) {
        
        createdAt = dictionary[OTMClient.JsonResponseKeys.CreatedAt] as! String
        firstName = dictionary[OTMClient.JsonResponseKeys.FirstName] as! String
        lastName = dictionary[OTMClient.JsonResponseKeys.LastName] as! String
        latitude = dictionary[OTMClient.JsonResponseKeys.Latitude] as! Double
        longitude = dictionary[OTMClient.JsonResponseKeys.Longitude] as! Double
        mapString = dictionary[OTMClient.JsonResponseKeys.MapString] as! String
        mediaURL = dictionary[OTMClient.JsonResponseKeys.MediaURL] as! String
        objectID = dictionary[OTMClient.JsonResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[OTMClient.JsonResponseKeys.UniqueKey] as! String
        updatedAt = dictionary[OTMClient.JsonResponseKeys.UpdatedAt] as! String
        
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects */
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocations] {
        var locations = [StudentLocations]()
        
        for result in results {
            locations.append(StudentLocations(dictionary: result))
        }
        
        return locations
    }

}
