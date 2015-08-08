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

class LoginViewController: UIViewController, UITextFieldDelegate {

// Mark: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginView: FBSDKLoginButton!
    @IBOutlet weak var loadingView: LoadingView!
    
// Mark: - Variables
    var session: NSURLSession!
    var backgroundGradient: CAGradientLayer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    var blurView: UIVisualEffectView?
    
    // Text field delegate objects
    let textDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        self.configureUI()
        loadingView.hidden = true
        
        // Text field delegates
        self.usernameField.delegate = textDelegate
        self.passwordField.delegate = textDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
// MARK: - Actions
    
    // Sign up if user does not have an account.
    @IBAction func signUp(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/url?q=https%3A%2F%2Fwww.udacity.com%2Faccount%2Fauth%23!%2Fsignin&sa=D&sntz=1&usg=AFQjCNERmggdSkRb9MFkqAW_5FgChiCxAQ")!)
    }
    
    // Login with Udacity.
    @IBAction func userLogin(sender: AnyObject) {
        if usernameField.text.isEmpty {
            debugLabel.text = "Please enter your email."
        } else if passwordField.text.isEmpty {
            debugLabel.text = "Please enter your password."
        } else {
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
            self.blurLoading()
            loadingView.hidden = false
            loadingView.animateProgressView()
            OTMClient.sharedInstance().udacityLogin(usernameField.text, password: passwordField.text, completionHandler: { (success, errorString) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.hidden = true
                        self.blurView?.removeFromSuperview()
                        self.completeLogin()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                    self.loadingView.hidden = true
                    self.blurView?.removeFromSuperview()
                    self.displayError(errorString!)
                    })
                }
            })
        }
    }
    
    // Login using Facebook.
    @IBAction func facebookLogin(sender: AnyObject) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            self.debugLabel.text = ""
            if error != nil {
                self.viewWillAppear(true)
            } else if result.isCancelled {
                self.viewWillAppear(true)
            } else {
                self.blurLoading()
                NSUserDefaults.standardUserDefaults().setObject(FBSDKAccessToken.currentAccessToken().tokenString!, forKey: "FBAccessToken")
                OTMClient.sharedInstance().loginWithFacebook { success, errorString in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.loadingView.hidden = true
                            self.blurView?.removeFromSuperview()
                            self.completeLogin()
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.loadingView.hidden = true
                            self.blurView?.removeFromSuperview()
                            self.displayError(errorString!)
                        })
                    }
                }
            }
        })
    }
    

// MARK: - Additional methods
    
    
    // Clears text fields and gets MapViewController.
    func completeLogin() {
            self.usernameField.text = ""
            self.passwordField.text = ""
            self.getTabController()
    }
    
    // Gets MapViewController.
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
    
    // Blur background while login is loading
    func blurLoading() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView!.frame = self.view.bounds
            self.view.insertSubview(blurView!, belowSubview: loadingView)
        } else {
            self.view.backgroundColor = UIColor.blackColor()
        }
    }
}

// Mark: - Configure UI
extension LoginViewController {
    func configureUI() {
        
        // Configure background gradient
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