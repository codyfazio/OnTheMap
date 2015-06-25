//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Cody Fazio on 5/18/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation

class OnTheMapConstants {
    
    
    
//Declare the constants we'll need across our app!
    
    //MARK: - Constants
    struct Constants {
        
        // MARK: App ID
        static let AppID : String = "365362206864879"
        
        //MARK: - URLs
        static let BaseURL : String = "http://www.udacity.com/api/"
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let BaseParseURLSecure : String = "https://api.parse.com/"
        static let UdacitySignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
        
        //MARK: - PARSE KEYS
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    }
    
    //MARK: - Methods
    struct Methods {
        
        //MARK: Accounts
        static let Users = "users/"
        
        //MARK: Authentication
        static let Session = "session"
        
        static let StudentLocation = "1/classes/StudentLocation"
    }
    //MARK: - JSON Response Keys
    struct AlertKeys {
        
        // MARK: General
        static let SomeWrong = "Something's wrong..."
        static let SomeMiss = "Something's missing.."
        static let LoginFail = "Login failed..."
        static let Offline = "The Internet connection appears to be offline."
        static let ShareURL = "Please enter the full url you want to share, like http://www.udacity.com."
        static let ShareLocation = "Please enter the location you would like to share!"
        static let Password = "Please enter your password!"
        static let Username = "Please enter your username!"
        static let Credentials = "Please check your credentials and try again"
        
    }
   }

