//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    //Create reference to UI elements in storyboard
    @IBOutlet weak var studyLocationLabel: UILabel!
    @IBOutlet weak var studyLocationTextField: UITextField!
    @IBOutlet weak var studyLocationButton: UIButton!
    
    @IBOutlet weak var urlSubmitButton: UIButton!
    @IBOutlet weak var urlSubmitLabel: UILabel!
    @IBOutlet weak var urlSubmitTextField: UITextField!
    
    @IBOutlet weak var postMapView: MKMapView!
    
    //Need to research moving activity indicator programmatically, but for now we'll use two
    @IBOutlet weak var urlActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var geocodeActivityIndicator: UIActivityIndicatorView!
    
    
    //Configure initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postMapView.hidden = true
        urlSubmitButton.hidden = true
        urlSubmitLabel.hidden = true
        //urlSubmitLabel.adjustsFontSizeToFitWidth = true
        urlSubmitTextField.hidden = true
        
        studyLocationButton.hidden = false
        studyLocationLabel.hidden = false
        studyLocationTextField.hidden = false
        
        urlSubmitTextField.delegate = self
        studyLocationTextField.delegate = self
        
        
    }
    
    //If cancel button is pressed, return to main view
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Check to see if the user has entered a location, geolocate it, and reconfigure the view for entering a URL
    @IBAction func studyLocationButtonClicked(sender: UIButton) {
        
        geocodeActivityIndicator.startAnimating()

        if studyLocationTextField.text!.isEmpty {
            displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message: OnTheMapConstants.AlertKeys.ShareLocation, activityIndicator: geocodeActivityIndicator)
        } else {
            if OnTheMapConvenience.sharedInstance().isConnectedToNetwork() {
        
        let geocoder = CLGeocoder()
        let regionRadius: CLLocationDistance = 2000
            geocoder.geocodeAddressString(studyLocationTextField.text!) {locatedPlacemarks, error in
                if let placemark = locatedPlacemarks!.first as CLPlacemark! {
                    let calculatedRegion = MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, regionRadius, regionRadius)
                    self.postMapView.addAnnotation(MKPlacemark(placemark: placemark))
                    self.postMapView.setRegion(calculatedRegion, animated: true)
                    ParseClient.sharedInstance.mapString = self.studyLocationTextField.text
                    ParseClient.sharedInstance.longitude = placemark.location!.coordinate.longitude as Double
                    ParseClient.sharedInstance.latitude = placemark.location!.coordinate.latitude as Double
                    
                    self.geocodeActivityIndicator.stopAnimating()
                    
                    self.postMapView.hidden = false
                    self.urlSubmitButton.hidden = false
                    self.urlSubmitLabel.hidden = false
                    self.urlSubmitTextField.hidden = false
                    
                    self.studyLocationButton.hidden = true
                    self.studyLocationLabel.hidden = true
                    self.studyLocationTextField.hidden = true
                }
                }
            
            } else {
                displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message:OnTheMapConstants.AlertKeys.Offline, activityIndicator: geocodeActivityIndicator)
            }
        }
    }
    
    //Check if user has entered a URL, validate it, actually post the user info
    @IBAction func submitURL(sender: UIButton) {
        
        //Start activity indicator
        urlActivityIndicator.startAnimating()
        
        //Alert user if URL field is empty
        if urlSubmitTextField.text!.isEmpty {
            displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message: OnTheMapConstants.AlertKeys.ShareURL, activityIndicator: urlActivityIndicator)
            
        } else {
            
            //Disable user activity start activity indicator
            urlActivityIndicator.startAnimating()
            studyLocationButton.enabled = false
            
            //Verify URL
            if OnTheMapConvenience.sharedInstance().isConnectedToNetwork() {
            if OnTheMapConvenience.sharedInstance().verifyURL(self.urlSubmitTextField.text) {
            
            //If URL is valid, save URL and post the location and URL to Parse
            ParseClient.sharedInstance.mediaURL = urlSubmitTextField.text
            ParseClient.sharedInstance.postUserData(){(success, error) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message: error!, activityIndicator: self.urlActivityIndicator)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
        }
                //Alert user the url was not valid and give example of proper URL
            } else  {
                displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message: OnTheMapConstants.AlertKeys.ShareURL, activityIndicator: urlActivityIndicator)
            }
            } else {
                displayAlert(OnTheMapConstants.AlertKeys.SomeWrong, message: OnTheMapConstants.AlertKeys.Offline, activityIndicator: urlActivityIndicator)
            }
        }
    }
    
    //Convenience function for displaying alerts 
    func displayAlert(title: String, message: String, activityIndicator: UIActivityIndicatorView) {
        let alertView = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            let currentActivityIndicator = activityIndicator
            currentActivityIndicator.stopAnimating()
            self.presentViewController(alertView, animated: true, completion: nil)
        })
    }

    /*Keyboard functions */
    
    //Dismiss keyboard when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool //
    {
        studyLocationTextField.resignFirstResponder()
        urlSubmitTextField.resignFirstResponder()
        return true
    }
    
    
    
    
}