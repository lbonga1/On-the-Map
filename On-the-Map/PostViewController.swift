//
//  PostViewController.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 7/25/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController {
    
// MARK: -Outlets
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var enterLocationLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
// MARK: - Actions
    
    // Locates the address provided by user and adds a pin to the map.
    @IBAction func findLocation(sender: AnyObject) {
        var location = locationTextField.text
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                self.secondView.hidden = true
                self.thirdView.hidden = true
                
//                //Zoom in to the results
//                let extent = self.graphicLayer.fullEnvelope.mutableCopy() as AGSMutableEnvelope
//                extent.expandByFactor(1.5)
//                self.mapView.zoomToEnvelope(extent, animated: true)
            } else {
                self.displayError("Could not find location", errorString: "Please try again.")
            }
        })
    
    }
    

// MARK: - Additional methods
    
    // Displays error message alert view.
    func displayError(title: String, errorString: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }



}
