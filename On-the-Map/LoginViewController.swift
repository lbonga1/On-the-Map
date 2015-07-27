//
//  LoginViewController.swift
//  On the Map
//
//  Created by Lauren Bongartz on 5/28/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
// Mark: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginView: FBSDKLoginButton!
    
// Mark: - Variables
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var backgroundGradient: CAGradientLayer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        self.configureUI()
        
        //self.loginView.delegate = self
    }
    
// MARK: - Actions
    
    // Sign up if user does not have an account.
    @IBAction func signUp(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/url?q=https%3A%2F%2Fwww.udacity.com%2Faccount%2Fauth%23!%2Fsignin&sa=D&sntz=1&usg=AFQjCNERmggdSkRb9MFkqAW_5FgChiCxAQ")!)
    }
    
    // Login button action
    @IBAction func userLogin(sender: AnyObject) {
        if usernameField.text.isEmpty {
            debugLabel.text = "Please enter your email."
        } else if passwordField.text.isEmpty {
            debugLabel.text = "Please enter your password."
        } else {
            OTMClient.sharedInstance().udacityLogin(usernameField.text, password: passwordField.text, completionHandler: { (success, errorString) -> Void in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString!)
                }
            })
        }
    }

// MARK: - Additional methods
    
    // Clears text fields and gets MapViewController.
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.usernameField.text = ""
            self.passwordField.text = ""
            //self.debugLabel.text = ""
            self.getTabController()
        })
    }
    
    // Required Facebook method.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            self.getTabController()
        }
    }
    
    // Required Facebook method.
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    //Gets MapViewController.
    func getTabController() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Error alert notification.
    func displayError(errorString: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "Could not log in.", message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}


// Mark: - Configure UI
extension LoginViewController {
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.973, green: 0.514, blue: 0.055, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.965, green: 0.353, blue: 0.027, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)}
}

// Mark: - Keyboard Methods
extension LoginViewController {
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
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