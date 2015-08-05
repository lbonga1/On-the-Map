//
//  Data.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 8/2/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class Data: NSObject {
   
    // Data for posting user location
    var userFirstName: String!
    var userLastName: String!
    var mapString: String!
    var mediaURL: String!
    var region: MKCoordinateRegion!
    
    // Data for testing mediaURL
    var testLink: String!
    
    // Data for updating user location
    var objectID: String!
    
    // Student locations array
    var locations: [StudentLocations]!
    
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> Data {
        
        struct Singleton {
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }
}
