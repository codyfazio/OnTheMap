//
//  HarvestedData.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//


// Struct for housing student info
import Foundation

struct Student {
    var firstName = ""
    var lastName = ""
    var latitude = 0.0
    var longitude = 0.0
    var mapString = ""
    var mediaURL = "http//www.udacity.com"
    var objectID = ""
    var uniqueKey = ""
    
    init(dictionary: [String: AnyObject]) {
        if let first = dictionary["firstName"] as? String {
            firstName = first
        }
        if let last = dictionary["lastName"] as? String {
            lastName = last
        }
        if let lat = dictionary["latitude"] as? Double {
            latitude = lat
        }
        if let long = dictionary["longitude"] as? Double {
            longitude = long
        }
        if let location = dictionary["mapString"] as? String {
            mapString = location
        }
        if let url = dictionary["mediaURL"] as? String {
            mediaURL = url
        }
        if let id = dictionary["objectID"] as? String {
            objectID = id
        }
        if let key = dictionary["uniqueKey"] as? String {
            uniqueKey = key
        }
    }
    
    
    //Function for creating an array of student structs
    static func studentInfoFromData(results: NSArray) -> [Student]{
        var students = [Student]()
        
        for result in results {
            students.append(Student(dictionary: result as! [String : AnyObject]))
        }
        return students
    }
    
}