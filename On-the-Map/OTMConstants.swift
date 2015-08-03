//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

extension OTMClient {
    
    struct Constants {
        static let UdacityBaseURLSecure: String = "https://www.udacity.com/api"
        static let ParseBaseURLSecure: String = "https://api.parse.com/1/classes/StudentLocation"
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Methods {
        static let UdacitySession: String = "/session"
        static let FacebookSession: String = "/session"
        static let UdacityData: String = "/users/"
    }
    
    struct JsonResponseKeys {
        // Udacity General
        static let Account = "account"
        static let Results = "results"
        static let UserID = "key"
        
        // Facebook Login
        static let FBAccount = "account"
        static let Key = "key"
        
        // Udacity User
        static let User = "user"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        
        // Student Locations
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
