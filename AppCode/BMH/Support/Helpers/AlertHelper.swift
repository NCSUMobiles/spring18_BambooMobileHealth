//
//  AlertHelper.swift
//  BMH
//
//  Created by Robert Dates on 4/21/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//


import UIKit

class AlertHelper {
    static func showBasicAlertInVC(_ vc:UIViewController, title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            //error occurred
        }
        alertController.addAction(okAction)
        vc.present(alertController, animated: true)
    }
}
