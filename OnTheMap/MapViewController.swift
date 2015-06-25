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
    
    
    //Get data from Parse and load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        studentMapView.delegate = self
        self.navigationController!.toolbar.hidden = true
        refreshDataButton.action = "refreshData"
        self.navigationItem.setRightBarButtonItems([refreshDataButton,postLocation], animated: true)
    }
    
    //Get most current data from Parse
     override func viewWillAppear(animated: Bool) {
        refreshData()
}

    //This was adapted from the MapKit example on Udacity
    //Create map pins from individual Parse data elements
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //This was adapted from the MapKit example on Udacity
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    //A function that uses Parse to get the individual Student objects for creating pins
    func refreshData () {
        ParseClient.sharedInstance().getStudents() { (success, errorString) in
            if errorString != nil{
                    let alertView = UIAlertController(title: OnTheMapConstants.AlertKeys.SomeWrong, message: errorString!, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertView, animated: true, completion: nil)
                    })
                
            }else{
                //Create and call a function in our shared instance to annotate Map Data
                ParseClient.sharedInstance().buildAnnotations()
                
                dispatch_async(dispatch_get_main_queue()){
                    self.studentMapView.addAnnotations(ParseClient.sharedInstance().annotations)
                }
            }
        }

    }
}