//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //Create variables
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var username : String?
    var password : String?
    var usernameEdited : Bool?
    var passwordEdited : Bool?
    
    //Create references to storyboard UI Elements
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountSignUpButton: UIButton!
    @IBOutlet weak var loginWithUdacityButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
    super.viewDidLoad()
    
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
    
        // Configure UI elements and set delegates
        self.configureUI()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    
}
    
    override func viewWillAppear(animated: Bool) {
        
        //Begin listening for keyboard notifications to properly adjust view while keyboard is active
        //subscribeToKeyboardNotifications()
        
        //Reset UI Elements in case they have changed
        configureUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Stop monitoring keyboard actions
       // unsubscribeFromKeyboardNotifications()
    }


    @IBAction func loginWithUdacityButtonClicked(sender: UIButton) {
    
        //Disable login button
        loginWithUdacityButton.enabled = false
        
        //Get username and password from textfields
        username = usernameTextField.text
        password = passwordTextField.text
        
        //Start animating activity indicator
        activityIndicator.startAnimating()
        
        //Check to see if the user has entered a username and password
        if (usernameEdited != nil && username?.isEmpty == false) && (passwordEdited != nil && password?.isEmpty == false) {
        
        //If so, pass username and password into function and attempt login
        UdacityClient.sharedInstance.attemptLoginWithUdacity(username, password: password) { (success, errorString) -> Void in
            
            //If login is successful, segue to tab controller with Table and Map
            if success {
                self.activityIndicator.stopAnimating()
                self.segueToMainView() }
             
            //If login fails, return alert to user telling them to try again, and reset the login view
            else {
                self.displayAlert(OnTheMapConstants.AlertKeys.LoginFail, message: errorString!)
                }
            }
                
        //Handle case for missing password
        } else if (self.passwordEdited == nil) {
            self.displayAlert(OnTheMapConstants.AlertKeys.SomeMiss, message: OnTheMapConstants.AlertKeys.Password)
        
        //Handle case for missing username
        } else  {
            self.displayAlert(OnTheMapConstants.AlertKeys.SomeMiss, message: OnTheMapConstants.AlertKeys.Username)
            }
        
        }
    
    //Redirect user through Safari to Udacity homepage to sign up
    @IBAction func accountSignUpButtonClicked(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: OnTheMapConstants.Constants.UdacitySignUpURL)!)
        
    }
    
    //Convenience function for displaying alerts
    func displayAlert(title: String, message: String) {
        let alertView = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertView, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.loginWithUdacityButton.enabled = true
        })
    }

    
    //Function for transitioning to the main views in the TabBarController
    func segueToMainView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        } )
    }

    //Function for configure UI elements
    func configureUI() {
        usernameTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        usernameTextField.textColor = UIColor.whiteColor()
        passwordTextField.textColor = UIColor.whiteColor()
        passwordTextField.secureTextEntry = false
        passwordTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        accountSignUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    /*Keyboard functions */
    
    //Set secure text entry in password field
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == passwordTextField {
            passwordTextField.secureTextEntry = true
            passwordEdited = true
        }
        if textField == usernameTextField {
            usernameEdited = true
        }
    }
    
    //Dismiss keyboard when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool //
    {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
       



}

