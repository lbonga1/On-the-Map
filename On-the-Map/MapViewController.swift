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
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up bar button items.
        if FBSDKAccessToken.currentAccessToken() != nil {
            navigationItem.leftBarButtonItem = closeButton
        } else {
            navigationItem.leftBarButtonItem = logoutButton
        }
        
        self.navigationItem.setRightBarButtonItems([refreshButton, postButton], animated: true)
        
        self.getStudentLocations()
    
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    func getStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            if (success != nil) {
                self.displayMap()
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    func displayError(errorString: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "Could not fetch student locations.", message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func displayMap() {
        dispatch_async(dispatch_get_main_queue()) {
            var locations = [StudentLocations]()
            var annotations = [MKPointAnnotation]()
        
            for dictionary in locations {
            
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(dictionary.latitude as Double)
                let long = CLLocationDegrees(dictionary.longitude as Double)
            
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
                let first = dictionary.firstName as String
                let last = dictionary.lastName as String
                let mediaURL = dictionary.mediaURL as String
            
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
            
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        }
    }
    
    //MARK: - Actions:
    
    // Returns user to Login View.
    @IBAction func returnToLoginVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Logs user out of Udacity.
    //    @IBAction func userLogout(sender: AnyObject) {
    //        OTMClient.sharedInstance().udacityLogout({ (success: Bool, error: String?) -> Void in
    //            println("logging out")
    //            if error != nil {
    //                println("display error")
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    let alertController = UIAlertController(title: "Network error", message: "Please check your network connection and try again.", preferredStyle: .Alert)
    //                    let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
    //                        alertController.addAction(okAction)
    //                    self.presentViewController(alertController, animated: true, completion: nil)
    //                }
    //                    return
    //            }
    //        })
    //        self.dismissViewControllerAnimated(true, completion: nil)
    //    }
}



