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
    
// MARK: - Variables
    var locations: [StudentLocations] = [StudentLocations]()
    
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
        self.getStudentLocations()
    }
    
// MARK: - Methods
    
    // Set up tableView cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "Student List"
        let location = locations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        let firstName = location.firstName
        let lastName = location.lastName
        let mediaURL = location.mediaURL
        
        cell.textLabel!.text = "\(firstName) \(lastName)"
        cell.detailTextLabel?.text = mediaURL
        
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    // Retrieves number of rows.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    // Opens URL in browser when row is tapped.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = locations[indexPath.row]
        let mediaURL = location.mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
        
    }
    
    // Retrieves student location data.
    func getStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { locations, errorString in
            if let locations = locations {
                self.locations = locations
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
    
// MARK: - Actions
    
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
    
}
