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
    
    
    //MARK Properties
    var session: NSURLSession
    var convenience: OnTheMapConvenience!
    
    var sessionID: AnyObject? = nil
    var userKey: String? = nil
    
    var userInfo : Student?
    var firstName: String?
    var lastName: String?
    var studentInfo: [Student] = [Student]()
    var annotations = [MKPointAnnotation]()
    
    //MARK: Initialization
    override init() {
        session = NSURLSession.sharedSession()
        convenience = OnTheMapConvenience()
        super.init()
        
    }
    
    //MARK: Shared Instance 
    static let sharedInstance = UdacityClient()

    //MARK: Udacity API Functions
    /*Login function that returns sessionID and userID */
    func attemptLoginWithUdacity(username: String?, password: String?, completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        let userName = username
        let passWord = password
        
        getSessionAndUserID (userName, password: passWord) { (success: Bool, errorString: String?) in
            guard success else {
                completionHandler(success: false, errorString: errorString)
                return }
            completionHandler(success: true, errorString: nil)
        }
    }
    
    //Function called by Login to pass in username and password and return sessionID and userID
    func getSessionAndUserID (username: String?, password: String?, completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        var userName = username
        var passWord = password
        var headers : [String : AnyObject]?
        var mutableParameters : [String :AnyObject]? = [
            OnTheMapConstants.Methods.Limit : 100,
            OnTheMapConstants.Methods.Order : "-updatedAt"
        ]
        var request : NSMutableURLRequest?
        request = convenience.buildPostRequest(OnTheMapConstants.Constants.BaseURLSecure, method: OnTheMapConstants.Methods.Session, passedBody: self.loginInfo(username!, password: password!), headers: headers, mutableParameters: mutableParameters)
        guard request != nil  else { return } //Todo: Handle error

        convenience.buildTask(request!) {(success, result, response, errorString) in
            
            guard success else {
                    completionHandler(success: false, errorString: errorString)
                    return }

            self.convenience.checkResponse(response!) { success, responseCode in
                guard success else {
                    
                    guard responseCode == 403 else {
                        completionHandler(success: false, errorString: String(responseCode))
                        return
                    }

                    let errorMessage = OnTheMapConstants.AlertKeys.Credentials
                    completionHandler(success: false, errorString: (errorMessage))
                    return
                    }

                    
                let newData = self.convenience.subset(result)
                self.convenience.parseJSONWithCompletionHandler(newData) { (parsedData, parsedError) in
                    
                    guard parsedError ==  nil else {
                        completionHandler(success: false, errorString: parsedError?.localizedDescription)
                        return }
                    guard let parsedUdacitySession = parsedData["session"] as? NSDictionary else {
                        completionHandler(success: false, errorString: "Failed to get Account Info")
                        return }

                    self.sessionID = parsedUdacitySession["id"] as? String
                        
                    guard let parsedAccountResult = parsedData["account"] as? NSDictionary else {
                        completionHandler(success: false, errorString: "Failed to get Account Info")
                        return }

                    self.userKey = parsedAccountResult["key"] as? String
                    self.getUserInfo(){(success, errorString) in
                        guard errorString == nil else {
                            completionHandler(success: false, errorString: errorString)
                            return }
                        
                        completionHandler(success: true, errorString: nil)
                        }
                }
            }
        }
    }
    
    //Get information about ourself from Udacity
    func getUserInfo(completionHandler: (success:Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapConstants.Constants.BaseURLSecure + OnTheMapConstants.Methods.Users + self.userKey!)!)
            let task = session.dataTaskWithRequest(request) {data, response, error in
                guard error == nil else {
                    completionHandler(success: false, errorString: error?.localizedDescription)
                    return }
                let newData = self.convenience.subset(data!)
                
                self.convenience.parseJSONWithCompletionHandler(newData) { (parsedData, parsedError) in
                    guard parsedError ==  nil else {
                            completionHandler(success: false, errorString: parsedError?.localizedDescription)
                            return }
                    guard let parsedUserData = parsedData["user"] as? NSDictionary else {
                        completionHandler(success: false, errorString: "Could not find user in parsed data.")
                        return }
                    guard let parsedLastName = parsedUserData["last_name"] as? String else {
                        completionHandler(success: false, errorString: "Could not find last name in parsed data.")
                        return }
                    
                    guard let parsedFirstName = parsedUserData["first_name"] as? String else {
                        completionHandler(success: false, errorString: "Could not find first name in parsed data.")
                        return }
                    UdacityClient.sharedInstance.lastName = parsedLastName
                    UdacityClient.sharedInstance.firstName = parsedFirstName
                    completionHandler(success: true, errorString: nil)

                    }
                }
        task.resume()
    }
    
    //Log out of the current Udacity Session
    func attemptUdacityLogout(completionHandler: (success:Bool, errorString: String?) -> Void) {
        let request = OnTheMapConvenience.sharedInstance().buildDeleteRequest()
        OnTheMapConvenience.sharedInstance().buildTask(request) {(success, result, response, errorString) in
            guard success else {
                completionHandler(success: false, errorString: errorString)
                return}
                
            self.convenience.checkResponse(response!) { success, responseCode in
                guard success else {
                    completionHandler(success: false, errorString: "Error logging out.")
                    return }
                let newData = self.convenience.subset(result)
                
                self.convenience.parseJSONWithCompletionHandler(newData) { (parsedData, parsedError) in
                    guard parsedError ==  nil else {
                        completionHandler(success: false, errorString: parsedError?.localizedDescription)
                        return }
                    completionHandler(success: true, errorString: nil)
                }
            }
        }
    }

    //Helper function for passing username and password to build requests
    func loginInfo(username: String, password: String) -> [String: AnyObject] {
        
        let credentialArray = [
            "udacity" : [
                "username": username,
                "password": password ]
        ]
        return credentialArray
    }
}

