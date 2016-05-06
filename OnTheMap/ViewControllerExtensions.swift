//
//  ViewControllerExtensions.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/5/16.
//  Copyright © 2016 Cody Fazio. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //Listen for calls to and dismissal of the keyboard
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Stop listening for keyboard calls
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Get keyboard size and move view up so as to obstruct it
    func keyboardWillShow(notification: NSNotification) {
        
        
            self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    //Get keyboard size and lower view back to its original state
    func keyboardWillHide(notification: NSNotification) {
                    self.view.frame.origin.y = 0
    }
    
    //Function for getting keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    
}