//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Create reference ot UI elements in storyboard
    @IBOutlet weak var postLocation: UIBarButtonItem!
    @IBOutlet weak var refreshDataButton: UIBarButtonItem!
    @IBOutlet weak var studentMapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    //Get data from Parse and load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        studentMapView.delegate = self
        self.navigationController!.toolbar.hidden = true
        refreshDataButton.action = #selector(MapViewController.refreshData)
        self.navigationItem.setRightBarButtonItems([refreshDataButton,postLocation], animated: true)
        self.navigationItem.setLeftBarButtonItem(logoutButton, animated: true)
    }
    
    //Get most current data from Parse
     override func viewWillAppear(animated: Bool) {
        refreshData()
}

    //Logout of the current Udacity session and return to login screen
    @IBAction func logoutButtonClicked(sender: UIBarButtonItem) {
        logoutButton.enabled = false
        UdacityClient.sharedInstance.attemptUdacityLogout{success, errorString in
            if let errorString = errorString {
                let alertView = UIAlertController(title: "\(OnTheMapConstants.AlertKeys.SomeWrong)", message: "\(OnTheMapConstants.AlertKeys.LogoutFailed)", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertView, animated: true, completion: nil)
                    self.logoutButton.enabled = true
                })
            } else  {
                dispatch_async(dispatch_get_main_queue(), {
                    self.logoutButton.enabled = true
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") 
                    self.presentViewController(controller, animated: true, completion: nil)
                } )
            }
        }
    }
    
    //This was adapted from the MapKit example on Udacity
    //Create map pins from individual Parse data elements
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //This was adapted from the MapKit example on Udacity
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    //A function that uses Parse to get the individual Student objects for creating pins
    func refreshData () {
        ParseClient.sharedInstance.getStudents() { (success, errorString) in
            guard errorString != nil else {
                let alertView = UIAlertController(title: OnTheMapConstants.AlertKeys.SomeWrong, message: errorString!, preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
            //Create and call a function in our shared instance to annotate Map Data
            ParseClient.sharedInstance.refreshAnnotationsForMap()
            dispatch_async(dispatch_get_main_queue()){
                self.studentMapView.removeAnnotations(self.studentMapView.annotations)
                self.studentMapView.addAnnotations(ParseClient.sharedInstance.annotations)
            }
        }
    }
}