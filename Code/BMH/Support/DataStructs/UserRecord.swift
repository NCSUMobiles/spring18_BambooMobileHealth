//
//  UserRecord.swift
//  BMH
//
//  Created by Kalpesh Padia on 4/25/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation

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
