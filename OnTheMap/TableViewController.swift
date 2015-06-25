//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Create references to UI elements in storyboard
    @IBOutlet weak var postLocation: UIBarButtonItem!
    @IBOutlet weak var refreshDataButton: UIBarButtonItem!
    @IBOutlet weak var studentDataTableView: UITableView!
    
    
    //Get data for manipulation from Parse and configure the UI
    override func viewDidLoad() {
        super.viewDidLoad()
        ParseClient.sharedInstance().getStudents() { (success, errorString) in
            if errorString != nil{
                dispatch_async(dispatch_get_main_queue()){
                    let alertView = UIAlertController(title: OnTheMapConstants.AlertKeys.SomeWrong, message: errorString!, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertView, animated: true, completion: nil)
                    })
                }
            }else{
                //Load student objects created from Parse data into table
                dispatch_async(dispatch_get_main_queue()){
                    self.studentDataTableView.reloadData()
                }
            }
        }
        
        //Configure UI and set delegates
        self.studentDataTableView.delegate = self
        self.studentDataTableView.dataSource = self
        self.navigationController!.toolbar.hidden = true
        self.refreshDataButton.action = "reloadTableData"
        self.navigationItem.setRightBarButtonItems([refreshDataButton,postLocation], animated: true)
           }
    
    //Get most recent student data
    override func viewWillAppear(animated: Bool) {
        self.studentDataTableView.reloadData()
    }

    
    //Get number of student objects
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
          println(ParseClient.sharedInstance().studentInfo.count)
          return ParseClient.sharedInstance().studentInfo.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //Create and configure table cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
        
        let student = ParseClient.sharedInstance().studentInfo[indexPath.row]
        cell.textLabel?.text = student.firstName + " " + student.lastName
        print (cell.textLabel?.text)
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    //If cells are selected, redirect to Safari and open specified URL
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        OnTheMapConvenience.sharedInstance().goToURL(ParseClient.sharedInstance().studentInfo[indexPath.row].mediaURL)
    }

    //Helper function for getting student data objects
    func reloadTableData() {
        self.studentDataTableView.reloadData()

}

}


