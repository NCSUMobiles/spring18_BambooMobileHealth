//
//  LoginHelper.swift
//  BMH
//
//  Created by Shreyas Zagade on 4/3/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import Locksmith

class UserRecord : NSObject, NSCoding {
    var username : String = ""
    var loginCount : Int = 1
    var actGoals : [String : Int] = [:]
    var exGoals : [String : Int] = [:]
    
    init(username: String, loginCount: Int, actGoals: [String:Int], exGoals: [String:Int]) {
        self.username = username
        self.loginCount = loginCount
        self.actGoals = actGoals
        self.exGoals = exGoals
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(loginCount, forKey: "loginCount")
        aCoder.encode(actGoals, forKey: "actGoals")
        aCoder.encode(exGoals, forKey: "exGoals")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.username = (aDecoder.decodeObject(forKey: "username") as? String)!
        self.loginCount = Int(aDecoder.decodeCInt(forKey: "loginCount"))
        self.actGoals = (aDecoder.decodeObject(forKey: "actGoals") as? [String : Int])!
        self.exGoals = (aDecoder.decodeObject(forKey: "exGoals") as? [String : Int])!
    }
}


class LoginHelper{
    
    static let USER_ACCOUNT = "BMH"
    
    static func saveLoggedInUser(userId : String){
        do{
            // some data already exists
            var dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
            var user : UserRecord
            
            if dictionary != nil {
                // this user already exists
                if dictionary![userId] != nil {
                    user = (dictionary![userId] as? UserRecord)!
                    user.loginCount += 1
                } else {
                    // this user came for the first time
                    user = UserRecord(username: userId, loginCount: 1, actGoals: [:], exGoals: [:])
                }
            }
            else {
                // very first time, first user
                dictionary = [String : Any]()
                
                // create the user record
                user = UserRecord(username: userId, loginCount: 1, actGoals: [:], exGoals: [:])
                
            }
            // save this user as logged-in
            dictionary!["loggedInUser"] = userId
            
            // save this user's (updated) record
            dictionary![userId] = user
            
            // now try to update the data into locksmith
            try Locksmith.updateData(data: dictionary!, forUserAccount: USER_ACCOUNT)
            
        }
        catch {
            print("Locksmith.saveData error: ", error)
        }
    }
    
    static func getLoginCount(userId : String) -> Int {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        return ((dictionary?[userId] as? UserRecord)?.loginCount)!
    }
    
    static func setLoginCount(userId : String, loginCount : Int) {
        var dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        let userRecord = (dictionary?[userId] as? UserRecord)
        userRecord?.loginCount = loginCount
        dictionary?[userId] = userRecord
        do {
            try Locksmith.updateData(data: dictionary!, forUserAccount: USER_ACCOUNT)
        }
        catch {
            print("Locksmith.saveData error: ", error)
        }
        
    }
    
    static func getLoggedInUser() -> Any? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        
        if (dictionary != nil && (dictionary!["loggedInUser"]) != nil) {
            // return the user record for the logged in user
            return (dictionary!["loggedInUser"] as! String)
        }
        else {
            // since no body is logged in, return nil
            return nil
        }
    }
    
    static func logOut() {
        do{
            if var dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT){
                // set nobody as logged in.
                dictionary["loggedInUser"] = nil
                try Locksmith.updateData(data: dictionary, forUserAccount: USER_ACCOUNT)
            }
        }
        catch {
            print(error)
        }
        
    }
    
}
