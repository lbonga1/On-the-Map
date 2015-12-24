//
//  PostViewController.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 7/25/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITextFieldDelegate {
    
// MARK: - Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var section1: UIView!
    @IBOutlet weak var section2: UIView!
    @IBOutlet weak var section3: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
// MARK: - Variables
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    //Text field delegate objects
    let textDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set up UI.
        self.mapView.hidden = true
        self.submitButton.hidden = true
        self.verifyButton.hidden = true
        self.linkTextField.hidden = true
        self.linkLabel.hidden = true
    
        // Activity indicator
        activityIndicator.hidesWhenStopped = true
        
        //Text field delegates
        self.locationTextField.delegate = textDelegate
        self.linkTextField.delegate = textDelegate
    }

    
// MARK: - Actions

    // Allows user to verify their web link
    @IBAction func verifyLink(sender: AnyObject) {
        Data.sharedInstance().testLink = linkTextField.text
        
        let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WebView") 
        
        presentViewController(webViewController, animated: true, completion: nil)
    }
    
    // Locates the address provided by user and adds a pin to the map.
    @IBAction func findLocation(sender: AnyObject) {
        Data.sharedInstance().mapString = locationTextField.text
        self.makeTransparent()
        activityIndicator.startAnimating()
        
        let location = locationTextField.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if error != nil {
                self.displayError("Could not find location", errorString: "Enter location as City, State, Country or Zipcode.")
                self.activityIndicator.stopAnimating()
                self.returnTransparency()
            } else {
                self.addUserLocation(placemarks!)
                self.activityIndicator.stopAnimating()
                self.returnTransparency()
            }
        })
    }
    
    // Posts user location to Parse server.
    @IBAction func postLocation(sender: AnyObject) {
        if linkTextField.text!.isEmpty {
            displayError("Link required", errorString: "Please enter a website link to share.")
        } else if Data.sharedInstance().objectID != nil {
            OTMClient.sharedInstance().updateLocation { (success, error) -> Void in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayError("Could not post location", errorString: error!)
                }
            }
        } else {
            Data.sharedInstance().mediaURL = linkTextField.text
            OTMClient.sharedInstance().postLocation { (success, error) -> Void in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayError("Could not post location", errorString: error!)
                }
            }
        }
    }
    
    // Dismiss post view controller
    @IBAction func cancelPost(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
// MARK: - Additional methods
    
    // Drops pin on the map for user provided location.
    func addUserLocation(placemarks: [AnyObject]) {
        
        let placemarks = placemarks as! [CLPlacemark]
        Data.sharedInstance().region = self.setRegion(placemarks)
        self.makeSecondView()
        
        let annotation = MKPointAnnotation()
        let latitude = Data.sharedInstance().region.center.latitude
        let longitude = Data.sharedInstance().region.center.longitude
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        mapView.setRegion(Data.sharedInstance().region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    // Zooms into the provided location.
    func setRegion(placemarks: [CLPlacemark]) -> MKCoordinateRegion? {
        
        var regions = [MKCoordinateRegion]()
        
        for placemark in placemarks {
            
            let coordinate: CLLocationCoordinate2D = placemark.location!.coordinate
            //let latitude: CLLocationDegrees = placemark.location!.coordinate.latitude
            //let longitude: CLLocationDegrees = placemark.location!.coordinate.longitude
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            regions.append(MKCoordinateRegion(center: coordinate, span: span))
        }
        
        return regions.first
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

    // Sets up UI after geocoding location.
    func makeSecondView() {
        self.mapView.hidden = false
        self.submitButton.hidden = false
        self.verifyButton.hidden = false
        self.section2.hidden = true
        self.section3.hidden = true
        self.studyingLabel.hidden = true
        self.linkLabel.hidden = false
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

// MARK: - Keyboard Methods
extension PostViewController {
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
