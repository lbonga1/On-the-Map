//
//  Data.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 8/2/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class Data: NSObject {
   
    var locations: [StudentLocations]!
   
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> Data {
        
        struct Singleton {
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }

}
