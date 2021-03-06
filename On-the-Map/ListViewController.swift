//
//  ListViewController.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/5/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class ListViewController: UITableViewController {
    
// MARK: - Outlets
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var listView: UITableView!
    
    
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
        
        // Loads tableView data.
        listView.reloadData()
    }
    
    
// MARK: - Actions
    
    // Gets post view controller.
    @IBAction func postUserLocation(sender: AnyObject) {
        if Data.sharedInstance().objectID != nil {
            self.displayErrorWithHandler("Location exists.", errorString: "Do you want to update your location or link?")
        } else {
            OTMClient.sharedInstance().getUserData { (success: Bool, error: String) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Post View") as! PostViewController
                        
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                    self.displayError("Could not handle request.", errorString: error)
                }
            }
        }
    }
    
    // Refreshes student location data.
    @IBAction func refreshLocations(sender: AnyObject) {
        self.getStudentLocations()
    }
    
    // Logout of Udacity.
    @IBAction func udacityLogout(sender: AnyObject) {
        OTMClient.sharedInstance().udacityLogout { (success: Bool, error: String?) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.displayError("Could not log out", errorString: "Please check your network connection and try again.")
            }
        }
    }
    
    // Returns to Login View.
    @IBAction func returnToLoginVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - TableView Methods
    
    // Set up tableView cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "Student List"
        let location = Data.sharedInstance().locations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        let firstName = location.firstName
        let lastName = location.lastName
        let mediaURL = location.mediaURL
        
        cell!.textLabel!.text = "\(firstName) \(lastName)"
        cell!.detailTextLabel?.text = mediaURL
        
        cell!.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell!
    }
    
    // Retrieves number of rows.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Data.sharedInstance().locations == nil {
            self.getStudentLocations()
        }
        return Data.sharedInstance().locations.count
    }
    
    // Opens URL in browser when row is tapped.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = Data.sharedInstance().locations[indexPath.row]
        let mediaURL = location.mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
        
    }
    
// MARK: - Additional Methods
    
    // Retrieves student location data.
    func getStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { locations, errorString in
            if let locations = locations {
                Data.sharedInstance().locations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.listView.reloadData()
                }
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
    
    // Displays error message alert view with completion handler.
    func displayErrorWithHandler(title: String, errorString: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Post View") as! PostViewController
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction (title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
