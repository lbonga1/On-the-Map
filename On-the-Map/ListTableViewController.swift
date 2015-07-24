//
//  ListViewController.swift
//  On the Map
//
//  Created by Lauren Bongartz on 6/5/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var listView: UITableView!
    
    
    var locations = [StudentLocations]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButtonItems([refreshButton, postButton], animated: true)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        
//        ParseClient().getStudentLocations() { result in
//            switch result {
//            case let .Error(error):
//                // display error message
//                dispatch_async(dispatch_get_main_queue()) {
//                    let alertController = UIAlertController(title: "Could not fetch student locations", message: "Please tap refresh to try again.", preferredStyle: .Alert)
//                    let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//                    alertController.addAction(okAction)
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                }
//            default:
//                self.listView.reloadData()
//            }
//        }
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "Student List"
        let location = locations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        //
        let firstName = location.firstName
        let lastName = location.lastName
        let mediaURL = location.mediaURL
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(firstName) \(lastName)"
        cell.detailTextLabel?.text = mediaURL
        
        //cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = locations[indexPath.row]
        let mediaURL = location.mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
        
    }
    
    
}
