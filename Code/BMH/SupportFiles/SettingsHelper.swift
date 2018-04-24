//
//  SettingsHelper.swift
//  BMH
//
//  Created by Shreyas Zagade on 4/18/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import Locksmith

class SettingsHelper{
    
    static let USER_ACCOUNT = "BMH"
    
    static func saveActivityExerciseGoalValues(activityExerciseAndGoals : [[ActEx]]){
        
        var actGoals = [String:Int]()
        var exGoals = [String:Int]()
        
        for element in activityExerciseAndGoals[0]{
            actGoals[element.name] = element.goalValue
        }
        
        for element in activityExerciseAndGoals[1]{
            exGoals[element.name] = element.goalValue
        }
        
        do{
            var dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
            
            // get the user record for the currently logged in user
            var userRecord = (dictionary![(dictionary!["loggedInUser"] as? String)!] as? UserRecord)
            
            // update the goals and values
            userRecord?.actGoals = actGoals
            userRecord?.exGoals = exGoals
            
            // and save it to the dictionary again
            dictionary![(dictionary!["loggedInUser"] as? String)!] = userRecord
            
            // try to update the data into locksmith once again
            try Locksmith.updateData(data: dictionary!, forUserAccount: USER_ACCOUNT)
        }
        catch {
            print(error)
        }
    }
    
    static func getActivityExerciseGoalValues() -> [[String:Int]] {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        guard dictionary != nil && (dictionary!["loggedInUser"] as? String) != nil &&
            (dictionary![(dictionary!["loggedInUser"] as? String)!] as? UserRecord) != nil
            else {
                return [[String:Int]]()
        }
        return [((dictionary![(dictionary!["loggedInUser"] as? String)!] as? UserRecord)?.actGoals)!, ((dictionary![(dictionary!["loggedInUser"] as? String)!] as? UserRecord)?.exGoals)!]
    }    
}
