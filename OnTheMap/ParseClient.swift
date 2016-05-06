//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject {
    
    //Create variables
    var session: NSURLSession
    var convenience: OnTheMapConvenience = OnTheMapConvenience()
    var constants: OnTheMapConstants = OnTheMapConstants()
    
    var sessionID: AnyObject? = nil
    var userID: String? = nil
    
    var studentInfo: [Student] = [Student]()
    var annotations = [MKPointAnnotation]()
    
    var mapString : String?
    var longitude : Double?
    var latitude : Double?
    var mediaURL : String?
    
    //Create a session
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
  
    }

    //Functioning for getting student data from Parse
    func getStudents(completionHandler: (success: Bool, error: String?) -> Void) {
        let headers = self.buildHeaders()
        var passedBody : [String : AnyObject]?
        var mutableParameters : [String : AnyObject]?
        
        let getStudentRequest = convenience.buildGetRequest(OnTheMapConstants.Constants.BaseParseURLSecure, method: OnTheMapConstants.Methods.StudentLocation, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)
        if getStudentRequest != nil {
            
            convenience.buildTask(getStudentRequest!) {success, data, response, downloadError in
            if downloadError != nil {completionHandler(success: false, error: downloadError!)}
            else {
                self.convenience.checkResponse(response!) {success, responseCode in
                    
                    if success {
                        self.convenience.parseJSONWithCompletionHandler(data) {(parsedData, parsedError) in
                            
                            if parsedError != nil {completionHandler(success: false, error: parsedError!.localizedDescription)}
                            else {
                                let result = parsedData["results"] as? NSArray
                                
                                self.studentInfo.removeAll()
                                self.studentInfo = Student.studentInfoFromData(result!)
                                completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                                completionHandler(success: false, error: String(responseCode))
                                }
                            }
                    }
                }
            }
        }

    //Function that takes users location and specified URL and posts them to Parse
    func postUserData(completionHandler: (success: Bool, error: String?) -> Void) {
    
        let headers = self.buildHeaders()
        let passedBody = buildUserDataPassedBody()
        var mutableParameters : [String : AnyObject]?
        
        let postUserDataRequest = convenience.buildPostRequest(OnTheMapConstants.Constants.BaseParseURLSecure, method: OnTheMapConstants.Methods.StudentLocation, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)
        
        if postUserDataRequest != nil {
            
            let task = convenience.buildTask(postUserDataRequest!) {success, data, resposne, downloadError in
                if downloadError != nil {completionHandler(success: false, error: downloadError!)}
                else {
                    completionHandler(success: true, error: nil)
                }
            }
                task.resume()
        }
    }
    
    //Necessary userInfo for posting to Parse
    func buildUserDataPassedBody() -> [String : AnyObject] {
        
        let passedBody : [String : AnyObject] = [
            
            "uniqueKey" : UdacityClient.sharedInstance().userKey!,
            "firstName" : UdacityClient.sharedInstance().firstName!,
            "lastName"  : UdacityClient.sharedInstance().lastName!,
            "mapString" : ParseClient.sharedInstance().mapString!,
            "mediaURL"  : ParseClient.sharedInstance().mediaURL!,
            "latitude"  : ParseClient.sharedInstance().latitude! ,
            "longitude" : ParseClient.sharedInstance().longitude!
            ]
        
        return passedBody
        
        
    }
    
    
    //Helper function for validation when making request with Parse
    func buildHeaders() -> [String: String] {
        return [
            "X-Parse-Application-Id": OnTheMapConstants.Constants.ParseAppID,
            "X-Parse-REST-API-Key": OnTheMapConstants.Constants.ParseKey       ]
    }
    
    
    //Helper function for creating an individual student object
    func buildStudent(jsonResponse: [String: AnyObject]) -> Student {
        let student = Student(dictionary: jsonResponse)
        return student
    }

    //Function that takes the student data objects created from Parse and packages them for making map pins
    
    func refreshAnnotationsForMap() {
        annotations = studentInfo.map({buildAnnotation($0)})
    }
    
    func buildAnnotation(student: Student) -> MKPointAnnotation {
        
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let annotation = MKPointAnnotation()
            let title = student.firstName + " " + student.lastName
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = title
            annotation.subtitle = student.mediaURL
            
            return annotation
    }
    
    //Create global instance of Parse client
    class func sharedInstance() -> ParseClient {
    
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
    
        return Singleton.sharedInstance
    }

    }







