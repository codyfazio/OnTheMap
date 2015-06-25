//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import MapKit

class UdacityClient: NSObject {
    
    
    //Create variables
    var session: NSURLSession
    var convenience: OnTheMapConvenience!
    
    var sessionID: AnyObject? = nil
    var userKey: String? = nil
    
    var userInfo : Student?
    var firstName: String?
    var lastName: String?
    var studentInfo: [Student] = [Student]()
    var annotations = [MKPointAnnotation]()
    
    //Initialize session and create instance of OnTheMpa Convenience class
    override init() {
        session = NSURLSession.sharedSession()
        convenience = OnTheMapConvenience()
        super.init()
        
}

    //Login function that returns sessionID and userID
    func attemptLoginWithUdacity(username: String?, password: String?, completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        var userName = username
        var passWord = password
        
        getSessionAndUserID (userName, password: passWord) { (success: Bool, errorString: String?) in
            if success {
                completionHandler(success: true, errorString: "No errors!")
                println("getSessionAndUserID success")
            }   else {
                completionHandler(success: false, errorString: errorString)
                println(errorString)
            }
        }
    }
    
    //Function called by Login to pass in username and password and return sessionID and userID
    func getSessionAndUserID (username: String?, password: String?, completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        var userName = username
        var passWord = password
        var headers : [String : AnyObject]?
        var mutableParameters : [String :AnyObject]?
        var request : NSMutableURLRequest?
        request = convenience.buildPostRequest(OnTheMapConstants.Constants.BaseURL, method: OnTheMapConstants.Methods.Session, passedBody: self.loginInfo(username!, password: password!), headers: headers, mutableParameters: mutableParameters)
        if request != nil {
        
            convenience.buildTask(request!) {(success, result, response, errorString) in
                
                if success {
                    self.convenience.checkResponse(response!) { success, responseCode in
                        if success {
                            
                            var newData = self.convenience.subset(result)
                            self.convenience.parseJSONWithCompletionHandler(newData) { (parsedData, parsedError) in
                                
                                if parsedError !=  nil {
                                    completionHandler(success: false, errorString: parsedError?.localizedDescription)
                                    
                                } else {
                                    if let parsedUdacitySession = parsedData["session"] as? NSDictionary {
                                        self.sessionID = parsedUdacitySession["id"] as? String
                                        
                                        if let parsedAccountResult = parsedData["account"] as? NSDictionary {
                                            self.userKey = parsedAccountResult["key"] as? String
                                            println(self.userKey)
                                            
                                            self.getUserInfo(){(success, errorString) in
                                                if success {
                                                    println(UdacityClient.sharedInstance().firstName)
                                                    println(UdacityClient.sharedInstance().lastName)
                                                }
                                                else {
                                                    //Todo: Do something with string?
                                                }
                                            }
                                            
                                            completionHandler(success: true, errorString: "nil")
                                        } else {
                                            //Todo: Handle error
                                        }
                                    }
                                }
                            }
                        } else {
                            
                            if responseCode == 403 {
                                let errorMessage = OnTheMapConstants.AlertKeys.Credentials
                                completionHandler(success: false, errorString: (errorMessage))
                            } else {
                            completionHandler(success: false, errorString: toString(responseCode))
                            }
                        }
                }
                   
        } else {
            completionHandler(success: false, errorString: errorString)
        }
        
    }
        } else {
            //Todo: Handle error
        }
    }
    
    //Get information about ourself from Udacity
    func getUserInfo(completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapConstants.Constants.BaseURLSecure + OnTheMapConstants.Methods.Users + self.userKey!)!)
            let task = session.dataTaskWithRequest(request) {data, response, error in
                if error != nil {
                    //Todo: Error handling!
                    return
                } else {
                     var newData = self.convenience.subset(data)
                    self.convenience.parseJSONWithCompletionHandler(newData) { (parsedData, parsedError) in
                        
                        if parsedError !=  nil {
                            completionHandler(success: false, errorString: parsedError?.localizedDescription)
                        } else {
                            if let parsedUserData = parsedData["user"] as? NSDictionary {
                                if let parsedLastName = parsedUserData["last_name"] as? String
                                    {UdacityClient.sharedInstance().lastName = parsedLastName
                                    println(parsedLastName)
                                    }
                                if let parsedFirstName = parsedUserData["first_name"] as? String
                                    {UdacityClient.sharedInstance().firstName = parsedFirstName
                                    println(UdacityClient.sharedInstance().firstName)
                                }
                                   }
                                }
                            }
                        }
                }
            task.resume()
            }

    //Helper function for passing username and password to build requests
    func loginInfo(username: String, password: String) -> [String: AnyObject] {
        
        var credentialArray = [
            "udacity" : [
                "username": username,
                "password": password ]
        ]
        return credentialArray
    }

    
    //Creating a global shared instance of the Udacity Client class
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
}

}

