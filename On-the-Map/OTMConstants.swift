//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

extension OTMClient {
    
    struct Constants {
        static let UdacityBaseURLSecure: String = "https://www.udacity.com/api/session"
        static let ParseBaseURLSecure: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct JsonResponseKeys {
        // General
        static let Account = "account"
        static let Results = "results"
        
        // Student locations
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
}
