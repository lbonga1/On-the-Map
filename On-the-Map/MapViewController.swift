//
//  MapViewController.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/1/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
// MARK: - Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!

// MARK: - Variables
    var locations = Data.sharedInstance().locations
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up bar button items.
        if FBSDKAccessToken.currentAccessToken() != nil {
            navigationItem.leftBarButtonItem = closeButton
        } else {
            navigationItem.leftBarButtonItem = logoutButton
        }
        
        self.navigationItem.setRightBarButtonItems([refreshButton, postButton], animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gets student locations.
        self.getStudentLocations()
        }
    
// MARK: - MKMapViewDelegate
    
    // Creates a view with a "right callout accessory view".
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Opens the pin's URL in browser when tapped.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
// MARK: - Actions:
    
    // Gets post view controller
    @IBAction func postUserLocation(sender: AnyObject) {
        OTMClient.sharedInstance().getUserData { (success: Bool, error: String) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                let storyboard = self.storyboard
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Post View") as! PostViewController
        
                self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                self.displayError("Could not handle request.", errorString: error)
            }
        }
    }
        
    // Refresh student location pins.
    @IBAction func refreshMap(sender: AnyObject) {
        self.getStudentLocations()
    }
    
    
    // Returns user to Login View.
    @IBAction func returnToLoginVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
     // Logs user out of Udacity.
    @IBAction func userLogout(sender: AnyObject) {
        OTMClient.sharedInstance().udacityLogout { (success: Bool, error: String?) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.displayError("Could not log out", errorString: "Please check your network connection and try again.")
            }
        }
    }
    
    // MARK: - Additional methods
    
    // Gets student location pins.
    func getStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { locations, errorString -> Void in
            if let locations = locations {
                self.locations = locations
                self.displayMap()
            } else {
                self.displayError("Error fetching locations", errorString: errorString!)
            }
        }
    }
    
    // Displays error message alert view.
    func displayError(title: String, errorString: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Add annotations to the map.
    func displayMap() {
        dispatch_async(dispatch_get_main_queue()) {
            
            for dictionary in self.locations {
                
                let lat = CLLocationDegrees(dictionary.latitude as Double)
                let long = CLLocationDegrees(dictionary.longitude as Double)
                
                // Create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = dictionary.firstName as String
                let last = dictionary.lastName as String
                let mediaURL = dictionary.mediaURL as String
                
                // Create the annotation and set its properties.
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Place the annotation in an array of annotations.
                self.annotations.append(annotation)
            }
            
            // Add the annotations to the map.
            self.mapView.addAnnotations(self.annotations)
        }
    }
}



