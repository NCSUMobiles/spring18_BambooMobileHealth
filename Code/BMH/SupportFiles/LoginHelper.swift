//
//  LoginHelper.swift
//  BMH
//
//  Created by Shreyas Zagade on 4/3/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import Foundation
import Locksmith

class LoginHelper{
    
    static let USER_ACCOUNT = "BMH"
    
    static func saveLogedInUser(userId : String){
        do{
            try Locksmith.saveData(data: ["logedInUser": userId], forUserAccount: USER_ACCOUNT)
        }catch{
            print(error)
        }
    }
    
    static func getLogedInUser() -> Any? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: USER_ACCOUNT)
        return dictionary?["logedInUser"]
    }
    
    static func logOut(){
        do{
            try Locksmith.deleteDataForUserAccount(userAccount: USER_ACCOUNT)
        }catch{
            print(error)
        }
        
    }
    
}
