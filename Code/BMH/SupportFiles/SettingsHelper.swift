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
        
        var goalsAndVaules = [[String:Int]]()
        for i in 0..<activityExerciseAndGoals.count{
            var dict = [String:Int]()
            for element in activityExerciseAndGoals[i]{
                dict[element.name] = element.goalValue
            }
            goalsAndVaules.append(dict)
        }
        do{
            
            var dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT) as! [String:Any]
            dictionary["activityExerciseGoalValues"] = goalsAndVaules
            try Locksmith.updateData(data: dictionary, forUserAccount: USER_ACCOUNT)
        }catch{
            print(error)
        }
    }
    
    static func getActivityExerciseGoalValues() -> Any? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        return dictionary?["activityExerciseGoalValues"]
    }    
}
