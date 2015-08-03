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
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var section1: UIView!
    @IBOutlet weak var section2: UIView!
    @IBOutlet weak var section3: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set up UI.
        self.mapView.hidden = true
        self.submitButton.hidden = true
        self.linkTextField.hidden = true
    
        // Activity indicator
        activityIndicator.hidesWhenStopped = true
    }

    
// MARK: - Actions
    
    // Locates the address provided by user and adds a pin to the map.
    @IBAction func findLocation(sender: AnyObject) {
        self.makeTransparent()
        activityIndicator.startAnimating()
        
        var location = locationTextField.text
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                self.makeSecondView()
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                self.activityIndicator.stopAnimating()
                self.returnTransparency()
            } else {
                self.displayError("Could not find location", errorString: "Enter location as City, State, Country or Zipcode.")
                self.activityIndicator.stopAnimating()
                self.returnTransparency()
            }
        })
    }
    
    // Dismiss post view controller
    @IBAction func cancelPost(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    @IBAction func postLocation(sender: AnyObject) {
//        if linkTextField.text != "" {
//        }
//    }

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

    // Sets up UI after geocoding location.
    func makeSecondView() {
        self.mapView.hidden = false
        self.submitButton.hidden = false
        self.section2.hidden = true
        self.section3.hidden = true
        self.studyingLabel.text = "Enter a link to share:"
        self.linkTextField.hidden = false
        self.findButton.hidden = true
        self.section1.backgroundColor = UIColor(red: 0.325, green: 0.318, blue: 0.529, alpha: 1)
    }
    
    // Makes map transparent while geocoding
    func makeTransparent(){
        self.mapView.alpha = 0.5
        submitButton.alpha = 0.5
    }
    
    // Makes map visible when geocoding is complete.
    func returnTransparency() {
        self.mapView.alpha = 1.0
        submitButton.alpha = 1.0
    }

}
