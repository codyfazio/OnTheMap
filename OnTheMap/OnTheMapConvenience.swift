//
//  OnTheMapConvenience.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit
import Foundation

class OnTheMapConvenience: NSObject {
    
    //Create variables
    var session: NSURLSession
    
    var sessionID: AnyObject? = nil
    var userID: String? = nil

    //Initialize session
      override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    //Helper function for building tasks
    func buildTask(request: NSMutableURLRequest, completionHandler: (success: Bool, result: NSData!, response: NSURLResponse? , errorString: String?) -> Void) -> NSURLSessionDataTask  {
        
        //session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            
            
            if downloadError != nil {
                //let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(success: false, result: nil, response: nil, errorString: String(stringInterpolationSegment: downloadError.localizedDescription))
            } else {
                completionHandler(success: true, result: data, response: response, errorString: nil)
                
            }
        }
        
        task.resume()
        return task
    }

    //Builds get request to pass into build task function
    func buildGetRequest(urlBaseString : String!, method : String!, passedBody : [String : AnyObject]?, headers: [String: AnyObject]?, mutableParameters: [String: AnyObject]?) -> NSMutableURLRequest? {
        
        let result = buildURL(urlBaseString, method: method, mutableParameters: mutableParameters)
        var jsonifyError: NSError? = nil
        let request = NSMutableURLRequest(URL: result)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if headers != nil
        {for (key, value) in headers! {
            request.addValue(value as? String, forHTTPHeaderField: key)
            
            }
        }
        return request
    }

    
    //Builds Post request from Get request and returns it for building tasks
    func buildPostRequest(urlBaseString : String!, method : String!, passedBody : [String : AnyObject], headers: [String : AnyObject]?, mutableParameters: [String: AnyObject]?) -> NSMutableURLRequest?  {
        
        var jsonifyError: NSError? = nil
        let request = buildGetRequest(urlBaseString, method: method, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)
        
        request!.HTTPMethod = "POST"
        request!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request!.HTTPBody = NSJSONSerialization.dataWithJSONObject(passedBody, options: nil, error: &jsonifyError)
        
        
        return request!
    }
    
    //Create URL for making requests
    func buildURL (urlBaseString: String, method: String, mutableParameters: [String: AnyObject]?) -> NSURL {
        
        var url : NSURL!
        if (mutableParameters != nil) {
            let urlString = urlBaseString + method + escapedParameters(mutableParameters!)
            url = NSURL(string: urlString)
            
        } else {
            let urlString = urlBaseString + method
            url = NSURL(string: urlString) }
        return url
    }
    
    func subset(data: NSData) -> NSData{
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        return newData
    }
    
    //Read data returned from network into a usable form
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //Open a URL string in Safari
    func goToURL(url: String) {
        var link = NSURL(string: url)
        UIApplication.sharedApplication().openURL(link!)
    }
    
    //Test a URL string
    func verifyURL(urlString: String?) ->Bool{
        //Check for nil
        if let urlString = urlString{
            //Create NSURL instance
            if let url = NSURL(string: urlString){
                //Check if your application can open the NSURL instance
                if UIApplication.sharedApplication().canOpenURL(url){
                    return true
                } else { return false }
            }else { return false }
        } else { return false }
    }
    func checkResponse(response: NSURLResponse, completionHandler:(success:Bool, responseCode: Int?)->Void) {
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                completionHandler(success: true, responseCode: nil)
            } else {
                completionHandler(success: false, responseCode: httpResponse.statusCode)
            }
        }
    }
   
   
   //Function for texting network connection
    func isConnectedToNetwork()->Bool{
            
        var status: Bool?
        let urlPath: String = "http://www.google.com"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
    
        if let data = data {
        checkResponse(response!) { success, responseCode in
            if success {
                status = true
            } else {
                status = false
            }
        }
        } else {
            status = false 
        }
        return status!
    }

    //Helper function for escaping necessary data into a form usable in creating a URL
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    //Create a globle instance of this class
    class func sharedInstance() -> OnTheMapConvenience {
        
        struct Singleton {
            static var sharedInstance = OnTheMapConvenience()
        }
        
        return Singleton.sharedInstance
    }

}




